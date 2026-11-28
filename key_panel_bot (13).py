import base64
import json
import asyncio
import os
import secrets
import time
from threading import Lock, Thread

import discord
import urllib.request
import urllib.error
from discord import app_commands
from discord.ext import commands
from flask import Flask, Response, request

# ---- سيرفر ويب صغير عشان Render ما يوقف الخدمة ----
_web = Flask(__name__)

@_web.route("/")
def _home():
    return "asta key-panel bot is running ✅"

# ============================================================
#                        الإعدادات
# ============================================================
TOKEN           = os.environ["DISCORD_TOKEN"]
OWNER_IDS       = {int(x) for x in os.environ.get("OWNER_IDS", "1441717777558798397,1521996879473283271").replace(" ", "").split(",") if x.isdigit()}
ALLOWED_GUILDS  = {int(x) for x in os.environ.get("GUILD_IDS", "").replace(" ", "").split(",") if x.isdigit()}
BUYER_ROLE_ID   = int(os.environ.get("BUYER_ROLE_ID", "0"))
PROJECT_NAME    = os.environ.get("PROJECT_NAME", "asta")
PUBLIC_URL      = os.environ.get("PUBLIC_URL", "").rstrip("/")   # مثال: https://xxx.onrender.com
RESET_COOLDOWN  = int(os.environ.get("RESET_COOLDOWN", str(24 * 3600)))

# السكربت/اللودر الحقيقي (يُبنى ديناميكياً مع key في /script)
# اضبط LOADER_TEMPLATE على شكل Lua تحتوي فيه على {key} و {hwid_line}
# مثال: loadstring(game:HttpGet("https://api.luarmor.net/..."))()
# إذا تركت فارغ يُستخدم asta loader افتراضي
LOADER_TEMPLATE = os.environ.get("LOADER_TEMPLATE", "")

DATA_FILE = "keys_data.json"
BLUE, GREEN, RED = 0x5865F2, 0x57F287, 0xED4245

# ============================================================
#                   GitHub Storage
# ============================================================
GH_TOKEN = os.environ.get("GITHUB_TOKEN", "")
GH_REPO  = os.environ.get("GITHUB_REPO", "")
GH_PATH  = os.environ.get("GITHUB_DATA_PATH", "keys_data.json")
GH_API   = ("https://api.github.com/repos/" + GH_REPO + "/contents/" + GH_PATH) if GH_REPO else ""

_save_lock = Lock()
_gh_sha    = None


def _gh_headers():
    return {
        "Authorization": "Bearer " + GH_TOKEN,
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
    }


def load() -> dict:
    global _gh_sha
    d = {}
    if GH_TOKEN and GH_API:
        try:
            req = urllib.request.Request(GH_API, headers=_gh_headers())
            with urllib.request.urlopen(req, timeout=10) as r:
                resp = json.loads(r.read())
            _gh_sha = resp.get("sha")
            d = json.loads(base64.b64decode(resp["content"]).decode("utf-8"))
            print("✅ GitHub data loaded, sha=" + str(_gh_sha))
        except urllib.error.HTTPError as e:
            if e.code == 404:
                print("⚠️ keys_data.json مو موجود على GitHub، ينشئه عند أول save")
            else:
                print("GitHub load error:", e.code, e.reason)
        except Exception as e:
            print("GitHub load error:", repr(e))
    else:
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                d = json.load(f)
        except Exception:
            pass
    d.setdefault("keys", {})
    d.setdefault("users", {})
    return d


def save():
    global _gh_sha
    with _save_lock:
        raw = json.dumps(DATA, ensure_ascii=False, indent=2).encode()
        b64 = base64.b64encode(raw).decode()
        if GH_TOKEN and GH_API:
            try:
                payload: dict = {"message": "update keys_data", "content": b64}
                if _gh_sha:
                    payload["sha"] = _gh_sha
                req = urllib.request.Request(
                    GH_API, data=json.dumps(payload).encode(),
                    headers=_gh_headers(), method="PUT"
                )
                with urllib.request.urlopen(req, timeout=10) as r:
                    resp = json.loads(r.read())
                _gh_sha = resp["content"]["sha"]
            except Exception as e:
                print("GitHub save error:", repr(e))
        else:
            tmp = DATA_FILE + ".tmp"
            with open(tmp, "w", encoding="utf-8") as f:
                json.dump(DATA, f, ensure_ascii=False, indent=2)
            os.replace(tmp, DATA_FILE)


DATA = load()


# ============================================================
#                   أدوات مساعدة
# ============================================================
def is_owner(user: discord.User | discord.Member) -> bool:
    return user.id in OWNER_IDS


def active_license(uid: int) -> dict | None:
    u = DATA["users"].get(str(uid))
    if not u:
        return None
    if u["expires"] and u["expires"] < time.time():
        return None
    return u


def fmt_expiry(u: dict) -> str:
    return "مدى الحياة ♾️" if not u["expires"] else "<t:" + str(int(u["expires"])) + ":R>"


def build_loader(key: str) -> str:
    """يبني سطر Lua يُرسل للمشتري. KEY مضمّن في الـ URL."""
    base = PUBLIC_URL or "https://YOUR-RENDER-URL.onrender.com"
    hwid_expr = 'game:GetService("RbxAnalyticsService"):GetClientId()'
    if LOADER_TEMPLATE:
        # المستخدم كتب template خاص فيه {key} و/أو {hwid}
        return (
            LOADER_TEMPLATE
            .replace("{key}", key)
            .replace("{hwid}", '" .. ' + hwid_expr + ' .. "')
        )
    # افتراضي: asta loader يرفع key+hwid لـ /script
    return (
        'local _k="' + key + '"\n'
        'local _h=' + hwid_expr + '\n'
        'loadstring(game:HttpGet("' + base + '/script?key=".._k.."&hwid=".._h))()'
    )


async def give_role(member: discord.Member | discord.User) -> bool:
    if BUYER_ROLE_ID and isinstance(member, discord.Member):
        role = member.guild.get_role(BUYER_ROLE_ID)
        if role:
            try:
                await member.add_roles(role, reason="تفعيل مفتاح")
                return True
            except Exception as e:
                print("تعذر إعطاء الرتبة:", repr(e))
    return False


# notify_owners آمن: يستخدم bot.loop بعد on_ready
async def notify_owners(text: str):
    for oid in OWNER_IDS:
        try:
            user = await bot.fetch_user(oid)
            await user.send(text)
        except Exception as e:
            print("تعذر إرسال إشعار:", repr(e))


# ============================================================
#   /script  — نقطة تسليم السكربت للودر (HWID-locked)
# ============================================================
@_web.route("/script")
def serve_script():
    key  = (request.args.get("key")  or "").strip().upper()
    hwid = (request.args.get("hwid") or "").strip()

    # تحقق من HWID
    if len(hwid) < 8 or len(hwid) > 128 or not hwid.replace("-", "").isalnum():
        return Response('warn("[asta] invalid device id")', 400, mimetype="text/plain")

    info = DATA["keys"].get(key)
    if not info or not info.get("used_by"):
        return Response('warn("[asta] invalid key")', 403, mimetype="text/plain")

    u = DATA["users"].get(str(info["used_by"]))
    if not u or u.get("key") != key:
        return Response('warn("[asta] key mismatch")', 403, mimetype="text/plain")

    if u["expires"] and u["expires"] < time.time():
        return Response('warn("[asta] key expired")', 403, mimetype="text/plain")

    # ربط HWID أول مرة
    if not u.get("hwid"):
        u["hwid"] = hwid
        save()
    elif u["hwid"] != hwid:
        return Response('warn("[asta] key locked to another device")', 403, mimetype="text/plain")

    # تسليم السكربت
    # الأولوية: متغير SCRIPT_BODY ← ملف protected_script.lua ← رسالة افتراضية
    body = os.environ.get("SCRIPT_BODY", "")
    if not body:
        try:
            with open("protected_script.lua", "r", encoding="utf-8") as f:
                body = f.read()
        except FileNotFoundError:
            # لو ما في ملف، ابنِ ملف ووديه من LOADER_TEMPLATE أو stub
            body = (
                '-- asta script\n'
                'print("asta loaded | key: ' + key + '")\n'
            )
    return Response(body, mimetype="text/plain")


# ============================================================
#                        الواجهة
# ============================================================
class RedeemModal(discord.ui.Modal, title="🔑 تفعيل المفتاح"):
    key_input = discord.ui.TextInput(
        label="المفتاح",
        placeholder="XXXX-XXXX-XXXX",
        min_length=6,
        max_length=40,
    )

    async def on_submit(self, interaction: discord.Interaction):
        k    = self.key_input.value.strip().upper()
        info = DATA["keys"].get(k)

        if info is None:
            await interaction.response.send_message("❌ المفتاح غير صحيح.", ephemeral=True)
            return
        if info["used_by"]:
            await interaction.response.send_message("❌ هذا المفتاح مستخدم من قبل.", ephemeral=True)
            return
        if active_license(interaction.user.id):
            await interaction.response.send_message("⚠️ عندك ترخيص فعّال بالفعل.", ephemeral=True)
            return

        now = time.time()
        info["used_by"] = interaction.user.id
        expires_ts = (now + info["days"] * 86400) if info["days"] else 0
        DATA["users"][str(interaction.user.id)] = {
            "key":        k,
            "redeemed":   now,
            "expires":    expires_ts,
            "resets":     0,
            "last_reset": 0,
            "hwid":       None,
        }
        await asyncio.to_thread(save)

        got_role = await give_role(interaction.user)
        exp_str  = ("مدى الحياة ♾️" if not info["days"]
                    else "<t:" + str(int(expires_ts)) + ":R>")

        # ── رسالة تأكيد مع السكربت مباشرة (زي Luarmor) ──
        loader = build_loader(k)
        script_msg = (
            "✅ **تم تفعيل المفتاح!**\n\n"
            "**🔑 مفتاحك:** `" + k + "`\n"
            "**⏳ ينتهي:** " + exp_str + "\n\n"
            "**📜 السكربت الخاص بك** (مربوط بجهازك الأول):\n"
            "```lua\n" + loader + "\n```\n"
            "⚠️ لا تعطيه لأحد — مربوط بجهازك."
            + ("\n\n👤 تم إعطاؤك رتبة المشتري." if got_role else "")
        )

        # أرسل في DM إذا قدر، وإلا ephemeral في القناة
        sent_dm = False
        try:
            await interaction.user.send(script_msg)
            sent_dm = True
        except Exception:
            pass

        await interaction.response.send_message(
            "✅ تم تفعيل المفتاح!"
            + (" راجع رسائلك الخاصة 📩" if sent_dm else
               "\n\n" + script_msg),
            ephemeral=True,
        )

        await notify_owners(
            "🔑 **تفعيل مفتاح**\n"
            "المشتري: " + interaction.user.mention + " (`" + str(interaction.user.id) + "`)\n"
            "المفتاح: `" + k + "`\n"
            "الصلاحية: " + exp_str
        )


class PanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    # ── Redeem Key ──
    @discord.ui.button(label="Redeem Key", emoji="🔑",
                       style=discord.ButtonStyle.success, custom_id="kp:redeem", row=0)
    async def redeem(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_modal(RedeemModal())

    # ── Get Script ──
    @discord.ui.button(label="Get Script", emoji="📜",
                       style=discord.ButtonStyle.primary, custom_id="kp:script", row=0)
    async def get_script(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = active_license(interaction.user.id)
        if not u:
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال. فعّل مفتاحك أول.", ephemeral=True)
            return
        loader = build_loader(u["key"])
        await interaction.response.send_message(
            "📜 **سكربتك** (مربوط بجهازك الأول):\n```lua\n" + loader + "\n```\n"
            "⚠️ لا تعطيه لأحد — مربوط بجهازك.",
            ephemeral=True,
        )

    # ── Get Role ──
    @discord.ui.button(label="Get Role", emoji="👤",
                       style=discord.ButtonStyle.primary, custom_id="kp:role", row=1)
    async def get_role(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not active_license(interaction.user.id):
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال.", ephemeral=True)
            return
        ok = await give_role(interaction.user)
        await interaction.response.send_message(
            "✅ تم إعطاؤك الرتبة." if ok
            else "⚠️ ما قدرت أعطيك الرتبة (تأكد من BUYER_ROLE_ID وصلاحيات البوت).",
            ephemeral=True,
        )

    # ── Reset HWID ──
    @discord.ui.button(label="Reset HWID", emoji="⚙️",
                       style=discord.ButtonStyle.secondary, custom_id="kp:reset", row=1)
    async def reset(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = active_license(interaction.user.id)
        if not u:
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال.", ephemeral=True)
            return
        left = u["last_reset"] + RESET_COOLDOWN - time.time()
        if left > 0:
            hrs = int(left // 3600) + 1
            await interaction.response.send_message(
                "⏳ تقدر تعمل Reset بعد **" + str(hrs) + "** ساعة.", ephemeral=True
            )
            return
        u["resets"]    += 1
        u["last_reset"] = time.time()
        u["hwid"]       = None
        await asyncio.to_thread(save)
        await interaction.response.send_message(
            "✅ تم تصفير ربط الجهاز. أول جهاز تشغّل عليه السكربت بعد الآن يتسجّل.", ephemeral=True
        )
        await notify_owners(
            "⚙️ **Reset HWID**\nالمشتري: " + interaction.user.mention
            + " (`" + str(interaction.user.id) + "`)\n"
            "عدد المرات الكلي: **" + str(u["resets"]) + "**"
        )

    # ── Stats ──
    @discord.ui.button(label="My Stats", emoji="📊",
                       style=discord.ButtonStyle.secondary, custom_id="kp:stats", row=2)
    async def stats(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = DATA["users"].get(str(interaction.user.id))
        if not u:
            await interaction.response.send_message("ما عندك ترخيص مسجّل.", ephemeral=True)
            return
        e = discord.Embed(title="📊 إحصائياتك — " + PROJECT_NAME, color=BLUE)
        e.add_field(name="الحالة",        value="فعّال ✅" if active_license(interaction.user.id) else "منتهي ❌", inline=True)
        e.add_field(name="ينتهي",         value=fmt_expiry(u), inline=True)
        e.add_field(name="تاريخ التفعيل", value="<t:" + str(int(u["redeemed"])) + ":D>", inline=True)
        e.add_field(name="عدد الـ Reset",  value=str(u["resets"]), inline=True)
        e.add_field(name="HWID مسجّل",    value="✅ نعم" if u.get("hwid") else "⬜ لا", inline=True)
        await interaction.response.send_message(embed=e, ephemeral=True)


# ============================================================
#                        البوت
# ============================================================
intents = discord.Intents.default()


class KeyBot(commands.Bot):
    def __init__(self):
        super().__init__(
            command_prefix="!",
            intents=intents,
            status=discord.Status.invisible,
        )

    async def setup_hook(self):
        self.add_view(PanelView())   # persistent views بعد restart
        await self.tree.sync()
        print("✅ Slash commands synced")


bot = KeyBot()


@bot.event
async def on_ready():
    print("✅ شغّال كـ", bot.user)
    if ALLOWED_GUILDS:
        for g in list(bot.guilds):
            if g.id not in ALLOWED_GUILDS:
                await g.leave()
    # notify_owners آمن الآن لأن on_ready = bot جاهز
    await notify_owners(
        "🟢 **البوت شغال**\n"
        "الوقت: <t:" + str(int(time.time())) + ":F>\n"
        "السيرفرات: **" + str(len(bot.guilds)) + "**"
    )


@bot.event
async def on_guild_join(guild: discord.Guild):
    if ALLOWED_GUILDS and guild.id not in ALLOWED_GUILDS:
        await guild.leave()


# ============================================================
#                     أوامر الأونر
# ============================================================
@bot.tree.command(name="panel", description="انشر لوحة التحكم (للأونر)")
async def cmd_panel(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    e = discord.Embed(
        title="🔐 " + PROJECT_NAME + " — لوحة التحكم",
        description=(
            "مرحباً بك في لوحة التحكم.\n\n"
            "**🔑 Redeem Key** — فعّل مفتاحك\n"
            "**📜 Get Script** — استلم السكربت\n"
            "**👤 Get Role** — احصل على الرتبة\n"
            "**⚙️ Reset HWID** — صفّر ربط الجهاز (مرة كل 24 ساعة)\n"
            "**📊 My Stats** — شوف إحصائياتك"
        ),
        color=BLUE,
    )
    e.set_footer(text=PROJECT_NAME + " Key System")
    await interaction.response.send_message(embed=e, view=PanelView())


@bot.tree.command(name="genkey", description="توليد مفاتيح جديدة (للأونر)")
@app_commands.describe(
    count="عدد المفاتيح (1-100)",
    days="مدة الصلاحية بالأيام (0 = مدى الحياة)",
)
async def cmd_genkey(
    interaction: discord.Interaction,
    count: app_commands.Range[int, 1, 100] = 1,
    days:  app_commands.Range[int, 0, 3650] = 30,
):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    keys = []
    for _ in range(count):
        k = "-".join(secrets.token_hex(3).upper() for _ in range(3))
        DATA["keys"][k] = {"days": days, "used_by": None}
        keys.append(k)
    await asyncio.to_thread(save)
    dur = "مدى الحياة ♾️" if not days else str(days) + " يوم"
    await interaction.followup.send(
        "🔑 **" + str(count) + " مفتاح** (" + dur + "):\n```\n" + "\n".join(keys) + "\n```",
        ephemeral=True,
    )
    await notify_owners(
        "🗝️ **توليد مفاتيح**\n"
        "بواسطة: " + interaction.user.mention + "\n"
        "العدد: **" + str(count) + "** | المدة: " + dur + "\n```\n" + "\n".join(keys) + "\n```"
    )


@bot.tree.command(name="revoke", description="سحب ترخيص مشتري (للأونر)")
async def cmd_revoke(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].pop(str(member.id), None)
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    # أُلغِ المفتاح كذلك عشان ما يُعاد استخدامه
    key = u.get("key")
    if key and key in DATA["keys"]:
        DATA["keys"][key]["used_by"] = None
    await asyncio.to_thread(save)
    if BUYER_ROLE_ID and interaction.guild:
        role = interaction.guild.get_role(BUYER_ROLE_ID)
        if role:
            try:
                await member.remove_roles(role, reason="سحب ترخيص")
            except Exception as e:
                print("تعذر سحب الرتبة:", repr(e))
    await interaction.response.send_message(
        "✅ تم سحب الترخيص من " + member.mention + " وإعادة المفتاح للمخزون.", ephemeral=True
    )


@bot.tree.command(name="listkeys", description="عرض كل المفاتيح (للأونر)")
async def cmd_listkeys(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    lines = []
    for k, info in DATA["keys"].items():
        status = ("✅ مستخدم (ID:" + str(info["used_by"]) + ")") if info["used_by"] else "🟢 متاح"
        dur    = "∞" if not info["days"] else str(info["days"]) + "d"
        lines.append(k + "  [" + dur + "]  " + status)
    if not lines:
        await interaction.followup.send("لا يوجد مفاتيح.", ephemeral=True)
        return
    # Discord limit: 2000 chars per message
    chunk, out = [], []
    for l in lines:
        chunk.append(l)
        if len("\n".join(chunk)) > 1800:
            out.append("\n".join(chunk[:-1]))
            chunk = [chunk[-1]]
    if chunk:
        out.append("\n".join(chunk))
    for part in out:
        await interaction.followup.send("```\n" + part + "\n```", ephemeral=True)


@bot.tree.command(name="resetuser", description="تصفير HWID مشتري يدوياً (للأونر)")
async def cmd_resetuser(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("ما عنده ترخيص.", ephemeral=True)
        return
    u["hwid"]       = None
    u["last_reset"] = 0   # يخليه يعمل reset فوراً كذلك
    await asyncio.to_thread(save)
    await interaction.response.send_message(
        "✅ تم تصفير HWID لـ " + member.mention, ephemeral=True
    )


# ============================================================
#                        تشغيل
# ============================================================
if __name__ == "__main__":
    Thread(
        target=lambda: _web.run(host="0.0.0.0", port=int(os.environ.get("PORT", 10000))),
        daemon=True,
    ).start()
    bot.run(TOKEN)
