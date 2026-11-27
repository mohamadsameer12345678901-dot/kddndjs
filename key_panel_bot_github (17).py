import asyncio
import base64
import io
import json
import os
import secrets
import time
from collections import defaultdict
from threading import Lock, Thread

import discord
import urllib.request
import urllib.error
from discord import app_commands
from discord.ext import commands
from flask import Flask, Response, request

_web = Flask(__name__)


@_web.route("/")
def _home():
    return "Key panel bot is running"


# ============================================================
#                        الإعدادات
# ============================================================
TOKEN = os.environ["DISCORD_TOKEN"]
OWNER_IDS = {1441717777558798397, 1521996879473283271}
ALLOWED_GUILDS = {int(x) for x in os.environ.get("GUILD_IDS", "").replace(" ", "").split(",") if x.isdigit()}
BUYER_ROLE_ID = int(os.environ.get("BUYER_ROLE_ID", "0"))
PROJECT_NAME = os.environ.get("PROJECT_NAME", "My Project")
PUBLIC_URL = os.environ.get("PUBLIC_URL", "https://kddndjs-1.onrender.com").rstrip("/")
# اسم ملف السكربت (المشفّر مسبقاً بـ Luraph). يُسلَّم كما هو بدون أي تعديل.
SCRIPT_FILE = os.environ.get("SCRIPT_FILE", "protected_script.lua")
SCRIPT_FALLBACKS = ["protected_script.lua", "ASTA_Pro_v12.obf.luau", "ASTA_Pro_v12.obf.luau.txt"]
RESET_COOLDOWN = 24 * 3600

DATA_FILE = "keys_data.json"
BLUE, GREEN, RED = 0x5865F2, 0x57F287, 0xED4245

# rate limiting: 10 طلبات بالدقيقة لكل IP
_rate_data = defaultdict(list)
_rate_lock = Lock()
RATE_LIMIT = 10
RATE_WINDOW = 60

_hwid_blacklist = set()

# قفل شامل للسكربت
_script_locked = False
_script_lock_reason = ""

# حماية من التخمين
BRUTEFORCE_LIMIT = 5
BRUTEFORCE_WINDOW = 300
_bf_attempts = defaultdict(list)
_bf_lock = Lock()


def _record_failed_attempt(hwid):
    now = time.time()
    with _bf_lock:
        hits = [t for t in _bf_attempts[hwid] if now - t < BRUTEFORCE_WINDOW]
        hits.append(now)
        _bf_attempts[hwid] = hits
        if len(hits) >= BRUTEFORCE_LIMIT:
            _hwid_blacklist.add(hwid)
            DATA["blacklist"] = list(_hwid_blacklist)
            return True
    return False


def is_rate_limited(ip):
    now = time.time()
    with _rate_lock:
        hits = [t for t in _rate_data[ip] if now - t < RATE_WINDOW]
        if len(hits) >= RATE_LIMIT:
            _rate_data[ip] = hits
            return True
        hits.append(now)
        _rate_data[ip] = hits
        return False


# ============================================================
#                   GitHub Storage
# ============================================================
GH_TOKEN = os.environ.get("GITHUB_TOKEN", "")
GH_REPO = os.environ.get("GITHUB_REPO", "alsalehsamer2022-code/hxxfddhdj")
GH_PATH = os.environ.get("GITHUB_DATA_PATH", "keys_data.json")
GH_API = "https://api.github.com/repos/" + GH_REPO + "/contents/" + GH_PATH

_save_lock = Lock()
_gh_sha = None


def _gh_headers():
    return {
        "Authorization": "Bearer " + GH_TOKEN,
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
    }


def load():
    global _gh_sha
    d = {}
    if GH_TOKEN:
        try:
            req = urllib.request.Request(GH_API, headers=_gh_headers())
            with urllib.request.urlopen(req, timeout=10) as r:
                resp = json.loads(r.read())
            _gh_sha = resp.get("sha")
            content = base64.b64decode(resp["content"]).decode("utf-8")
            d = json.loads(content)
            print("GitHub data loaded, sha=" + str(_gh_sha))
        except urllib.error.HTTPError as e:
            if e.code == 404:
                print("keys_data.json not found on GitHub, will create on first save")
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
    d.setdefault("blacklist", [])
    return d


def save():
    global _gh_sha
    with _save_lock:
        content_b64 = base64.b64encode(json.dumps(DATA, ensure_ascii=False).encode()).decode()
        if GH_TOKEN:
            try:
                payload = {"message": "update keys_data", "content": content_b64}
                if _gh_sha:
                    payload["sha"] = _gh_sha
                data_bytes = json.dumps(payload).encode()
                req = urllib.request.Request(GH_API, data=data_bytes, headers=_gh_headers(), method="PUT")
                with urllib.request.urlopen(req, timeout=10) as r:
                    resp = json.loads(r.read())
                _gh_sha = resp["content"]["sha"]
            except Exception as e:
                print("GitHub save error:", repr(e))
        else:
            tmp = DATA_FILE + ".tmp"
            with open(tmp, "w", encoding="utf-8") as f:
                json.dump(DATA, f, ensure_ascii=False)
            os.replace(tmp, DATA_FILE)


def save_bg():
    asyncio.get_running_loop().run_in_executor(None, save)


try:
    DATA = load()
except Exception as e:
    print("load failed:", repr(e))
    DATA = {"keys": {}, "users": {}, "blacklist": []}

_hwid_blacklist = set(DATA.get("blacklist", []))


# ============================================================
#     قراءة السكربت (يُسلَّم كما هو، بدون أي تشفير إضافي)
# ============================================================
def script_body():
    names = [SCRIPT_FILE] + [n for n in SCRIPT_FALLBACKS if n != SCRIPT_FILE]
    for name in names:
        try:
            with open(name, "r", encoding="utf-8") as f:
                body = f.read()
            if body.strip():
                return body
        except Exception:
            continue
    return None


# ============================================================
#     التحقق من الجهاز وتسليم السكربت
# ============================================================
def _txt(code, msg):
    return Response('warn("[license] ' + msg + '")', code, mimetype="text/plain")


@_web.route("/script")
def serve_script():
    ip = (request.headers.get("X-Forwarded-For") or request.remote_addr or "?").split(",")[0].strip()
    if is_rate_limited(ip):
        return _txt(429, "too many requests")
    key = (request.args.get("key") or "").strip().upper()
    hwid = (request.args.get("hwid") or "").strip()
    if len(hwid) < 3 or len(hwid) > 128:
        return _txt(400, "invalid device id")
    if hwid in _hwid_blacklist:
        return _txt(403, "device banned")
    if _script_locked:
        return _txt(503, _script_lock_reason or "script temporarily unavailable")
    info = DATA["keys"].get(key)
    if not info or not info.get("used_by"):
        if _record_failed_attempt(hwid):
            try:
                asyncio.run_coroutine_threadsafe(
                    notify_owners("Auto-Ban HWID (brute force)\nHWID: `" + hwid + "`"), bot.loop
                )
            except Exception:
                pass
            save()
        return _txt(403, "invalid key")
    u = DATA["users"].get(str(info["used_by"]))
    if not u or u.get("key") != key:
        return _txt(403, "invalid key")
    if u["expires"] and u["expires"] < time.time():
        return _txt(403, "key expired")
    if u.get("paused"):
        return _txt(403, "key paused by admin")
    bound = u.get("hwid")
    if not bound:
        u["hwid"] = hwid
        save()
    elif bound != hwid:
        return _txt(403, "this key is locked to another device")
    body = script_body()
    if body is None:
        return _txt(503, "script not available yet")
    u["runs"] = u.get("runs", 0) + 1
    u["last_run"] = time.time()
    save()
    try:
        asyncio.run_coroutine_threadsafe(
            notify_owners(
                "▶️ **تشغيل سكربت**\n"
                "المشتري: <@" + str(info["used_by"]) + ">\n"
                "المفتاح: `" + key + "`\n"
                "HWID: `" + hwid + "`\n"
                "عدد مرات التشغيل: **" + str(u["runs"]) + "**"
            ),
            bot.loop,
        )
    except Exception:
        pass
    return Response(body, mimetype="text/plain")


def loader_line(key):
    url = PUBLIC_URL + "/script?key=" + key + "&hwid="
    lines = [
        'local _h=""',
        'pcall(function() _h=tostring(game:GetService("RbxAnalyticsService"):GetClientId()) end)',
        'if #_h<3 then pcall(function() _h=tostring(game:GetService("Players").LocalPlayer.UserId) end) end',
        'loadstring(game:HttpGet("' + url + '".._h))()',
    ]
    return "\n".join(lines)


async def notify_owners(text):
    for oid in OWNER_IDS:
        try:
            user = await bot.fetch_user(oid)
            await user.send(text)
        except Exception as e:
            print("notify owner failed:", repr(e))


def is_owner(user):
    return user.id in OWNER_IDS


def active_license(uid):
    u = DATA["users"].get(str(uid))
    if not u:
        return None
    if u["expires"] and u["expires"] < time.time():
        return None
    return u


def fmt_expiry(u):
    return "مدى الحياة ♾️" if not u["expires"] else "<t:" + str(int(u["expires"])) + ":R>"


async def give_role(member):
    if BUYER_ROLE_ID and isinstance(member, discord.Member):
        role = member.guild.get_role(BUYER_ROLE_ID)
        if role is not None:
            try:
                await member.add_roles(role, reason="تفعيل مفتاح")
                return True
            except Exception as e:
                print("give role failed:", repr(e))
    return False


# ============================================================
#                        الواجهة
# ============================================================
class RedeemModal(discord.ui.Modal, title="تفعيل المفتاح"):
    key = discord.ui.TextInput(label="المفتاح", placeholder="XXXX-XXXX-XXXX", min_length=6, max_length=40)

    async def on_submit(self, interaction: discord.Interaction):
        k = self.key.value.strip().upper()
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
        DATA["users"][str(interaction.user.id)] = {
            "key": k,
            "redeemed": now,
            "expires": (now + info["days"] * 86400) if info["days"] else 0,
            "resets": 0,
            "last_reset": 0,
        }
        save_bg()
        got_role = await give_role(interaction.user)
        await interaction.response.send_message(
            "✅ تم تفعيل المفتاح! اضغط **Get Script** لاستلام المشروع."
            + (" وتم إعطاؤك رتبة المشتري." if got_role else ""),
            ephemeral=True,
        )
        exp = "مدى الحياة ♾️" if not info["days"] else "<t:" + str(int(now + info["days"] * 86400)) + ":R>"
        await notify_owners(
            "🔑 **تفعيل مفتاح**\n"
            "المشتري: " + interaction.user.mention + " (`" + str(interaction.user.id) + "`)\n"
            "المفتاح: `" + k + "`\n"
            "الصلاحية: " + exp
        )


class PanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    async def on_error(self, interaction, error, item):
        import traceback
        print("button error", getattr(item, "custom_id", "?"))
        traceback.print_exception(type(error), error, error.__traceback__)
        try:
            if interaction.response.is_done():
                await interaction.followup.send("⚠️ صار خطأ، حاول مرة ثانية.", ephemeral=True)
            else:
                await interaction.response.send_message("⚠️ صار خطأ، حاول مرة ثانية.", ephemeral=True)
        except Exception:
            pass

    @discord.ui.button(label="Redeem Key", emoji="🔑", style=discord.ButtonStyle.success, custom_id="kp:redeem", row=0)
    async def redeem(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_modal(RedeemModal())

    @discord.ui.button(label="Get Script", emoji="📜", style=discord.ButtonStyle.primary, custom_id="kp:script", row=0)
    async def get_script(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = active_license(interaction.user.id)
        if not u:
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال. فعّل مفتاحك أول.", ephemeral=True)
            return
        await interaction.response.send_message(
            "📜 انسخ الكود كامل وشغّله. **مربوط بجهازك الأول**:\n```lua\n" + loader_line(u["key"]) + "\n```",
            ephemeral=True,
        )

    @discord.ui.button(label="Get Role", emoji="👤", style=discord.ButtonStyle.primary, custom_id="kp:role", row=1)
    async def get_role(self, interaction: discord.Interaction, button: discord.ui.Button):
        if not active_license(interaction.user.id):
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال.", ephemeral=True)
            return
        ok = await give_role(interaction.user)
        await interaction.response.send_message(
            "✅ تم إعطاؤك الرتبة." if ok else "⚠️ ما قدرت أعطيك الرتبة (تأكد من BUYER_ROLE_ID وصلاحيات البوت).",
            ephemeral=True,
        )

    @discord.ui.button(label="Reset HWID", emoji="⚙️", style=discord.ButtonStyle.secondary, custom_id="kp:reset", row=1)
    async def reset(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = active_license(interaction.user.id)
        if not u:
            await interaction.response.send_message("🔒 ما عندك ترخيص فعّال.", ephemeral=True)
            return
        left = u["last_reset"] + RESET_COOLDOWN - time.time()
        if left > 0:
            await interaction.response.send_message(
                "⏳ تقدر تعمل Reset بعد **" + str(int(left // 3600) + 1) + "** ساعة.", ephemeral=True
            )
            return
        u["resets"] += 1
        u["last_reset"] = time.time()
        u["hwid"] = None
        save_bg()
        await interaction.response.send_message(
            "✅ تم تصفير ربط الجهاز. أول جهاز تشغّل عليه السكربت بعد الآن يتسجّل.", ephemeral=True
        )
        await notify_owners(
            "⚙️ **Reset HWID**\nالمشتري: " + interaction.user.mention + " (`" + str(interaction.user.id) + "`)\n"
            "عدد المرات الكلي: **" + str(u["resets"]) + "**"
        )

    @discord.ui.button(label="Get Stats", emoji="📊", style=discord.ButtonStyle.secondary, custom_id="kp:stats", row=2)
    async def stats(self, interaction: discord.Interaction, button: discord.ui.Button):
        u = DATA["users"].get(str(interaction.user.id))
        if not u:
            await interaction.response.send_message("ما عندك ترخيص مسجّل.", ephemeral=True)
            return
        e = discord.Embed(title="📊 إحصائياتك", color=BLUE)
        e.add_field(name="الحالة", value="فعّال ✅" if active_license(interaction.user.id) else "منتهي ❌", inline=True)
        e.add_field(name="ينتهي", value=fmt_expiry(u), inline=True)
        e.add_field(name="تاريخ التفعيل", value="<t:" + str(int(u["redeemed"])) + ":D>", inline=True)
        e.add_field(name="عدد الـ Reset", value=str(u["resets"]), inline=True)
        await interaction.response.send_message(embed=e, ephemeral=True)


# ============================================================
#                        البوت
# ============================================================
intents = discord.Intents.default()


class KeyBot(commands.Bot):
    def __init__(self):
        super().__init__(command_prefix="!", intents=intents, status=discord.Status.invisible)

    async def setup_hook(self):
        self.add_view(PanelView())


bot = KeyBot()
_started = False


async def sync_guild(guild):
    try:
        bot.tree.copy_global_to(guild=guild)
        await bot.tree.sync(guild=guild)
    except Exception as ex:
        print("sync failed in", guild.id, repr(ex))


@bot.event
async def on_ready():
    global _started
    print("online as", bot.user)
    if _started:
        return
    _started = True
    try:
        await bot.http.bulk_upsert_global_commands(bot.application_id, [])
    except Exception as ex:
        print("clear global failed", repr(ex))
    for g in list(bot.guilds):
        if ALLOWED_GUILDS and g.id not in ALLOWED_GUILDS:
            await g.leave()
            continue
        await sync_guild(g)
    has_script = "موجود ✅" if script_body() else "غير موجود ❌ (ارفع الملف)"
    await notify_owners(
        "🟢 **البوت شغال / ريستارت**\n"
        "الوقت: <t:" + str(int(time.time())) + ":F>\n"
        "السيرفرات: **" + str(len(bot.guilds)) + "**\n"
        "ملف السكربت: " + has_script
    )
    bot.loop.create_task(daily_report())
    bot.loop.create_task(expiry_notifier())


@bot.event
async def on_guild_join(guild):
    if ALLOWED_GUILDS and guild.id not in ALLOWED_GUILDS:
        await guild.leave()
        return
    await sync_guild(guild)


async def daily_report():
    await bot.wait_until_ready()
    while True:
        await asyncio.sleep(86400)
        now = time.time()
        total = len(DATA["users"])
        active = sum(1 for u in DATA["users"].values() if not u["expires"] or u["expires"] > now)
        total_resets = sum(u.get("resets", 0) for u in DATA["users"].values())
        await notify_owners(
            "📋 **تقرير يومي — " + PROJECT_NAME + "**\n"
            "المشترين الكلي: **" + str(total) + "**\n"
            "فعّالين: **" + str(active) + "**\n"
            "منتهين: **" + str(total - active) + "**\n"
            "Resets الكلي: **" + str(total_resets) + "**"
        )


async def expiry_notifier():
    await bot.wait_until_ready()
    notified = set()
    while True:
        await asyncio.sleep(3600)
        now = time.time()
        for uid, u in list(DATA["users"].items()):
            if not u["expires"]:
                continue
            left = u["expires"] - now
            if 0 < left < 3 * 86400 and uid not in notified:
                try:
                    user = await bot.fetch_user(int(uid))
                    await user.send(
                        "⚠️ **تنبيه انتهاء الترخيص**\n"
                        "ترخيصك في **" + PROJECT_NAME + "** ينتهي " + fmt_expiry(u) + ".\n"
                        "تواصل مع الأونر للتجديد."
                    )
                    notified.add(uid)
                except Exception:
                    pass


# ============================================================
#                        الأوامر
# ============================================================
async def _owner_only(interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return False
    return True


@bot.tree.command(name="panel", description="انشر لوحة التحكم (للأونر)")
async def panel(interaction: discord.Interaction):
    if not await _owner_only(interaction):
        return
    e = discord.Embed(
        title=PROJECT_NAME + " Control Panel",
        description="لوحة التحكم الخاصة بمشروع **" + PROJECT_NAME + "**.\n"
        "إذا كنت مشتري، اضغط الأزرار بالأسفل لتفعيل مفتاحك أو استلام المشروع أو الرتبة.",
        color=BLUE,
    )
    await interaction.response.send_message(embed=e, view=PanelView())


def _make_keys(count, days):
    keys = []
    for _ in range(count):
        k = "-".join(secrets.token_hex(2).upper() for _ in range(3))
        DATA["keys"][k] = {"days": days, "used_by": None}
        keys.append(k)
    return keys


@bot.tree.command(name="genkey", description="توليد مفاتيح جديدة (للأونر)")
@app_commands.describe(count="عدد المفاتيح (1-100)", days="مدة الصلاحية بالأيام (0 = مدى الحياة)")
async def genkey(interaction: discord.Interaction, count: app_commands.Range[int, 1, 100] = 1,
                 days: app_commands.Range[int, 0, 3650] = 30):
    if not await _owner_only(interaction):
        return
    await interaction.response.defer(ephemeral=True)
    keys = _make_keys(count, days)
    await asyncio.to_thread(save)
    label = "مدى الحياة" if not days else str(days) + " يوم"
    await interaction.followup.send(
        "🔑 المفاتيح (" + label + "):\n```\n" + "\n".join(keys) + "\n```", ephemeral=True
    )
    await notify_owners(
        "🗝️ **توليد مفاتيح**\nبواسطة: " + interaction.user.mention + "\n"
        "العدد: **" + str(count) + "** | المدة: " + label + "\n"
        "المفاتيح:\n```\n" + "\n".join(keys) + "\n```"
    )


@bot.tree.command(name="genkeyfile", description="توليد مفاتيح كثيرة كملف .txt (للأونر)")
@app_commands.describe(count="عدد المفاتيح (1-500)", days="مدة الصلاحية بالأيام (0 = مدى الحياة)")
async def genkeyfile(interaction: discord.Interaction, count: app_commands.Range[int, 1, 500] = 10,
                     days: app_commands.Range[int, 0, 3650] = 30):
    if not await _owner_only(interaction):
        return
    await interaction.response.defer(ephemeral=True)
    keys = _make_keys(count, days)
    await asyncio.to_thread(save)
    label = "lifetime" if not days else str(days) + "d"
    content = ("# " + PROJECT_NAME + " Keys (" + label + ")\n\n" + "\n".join(keys)).encode("utf-8")
    f = discord.File(fp=io.BytesIO(content), filename="keys_" + label + "_" + str(count) + ".txt")
    await interaction.followup.send("🔑 **" + str(count) + "** مفتاح — مرفق كملف.", file=f, ephemeral=True)


@bot.tree.command(name="revoke", description="سحب ترخيص مشتري (للأونر)")
async def revoke(interaction: discord.Interaction, member: discord.Member):
    if not await _owner_only(interaction):
        return
    u = DATA["users"].pop(str(member.id), None)
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    save_bg()
    if BUYER_ROLE_ID:
        role = interaction.guild.get_role(BUYER_ROLE_ID)
        if role is not None:
            try:
                await member.remove_roles(role, reason="سحب ترخيص")
            except Exception as e:
                print("remove role failed:", repr(e))
    await interaction.response.send_message("✅ تم سحب الترخيص من " + member.mention, ephemeral=True)


@bot.tree.command(name="resetuser", description="تصفير HWID لمشتري بدون cooldown (للأونر)")
async def resetuser(interaction: discord.Interaction, member: discord.Member):
    if not await _owner_only(interaction):
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    u["hwid"] = None
    u["last_reset"] = 0
    save_bg()
    await interaction.response.send_message("✅ تم تصفير HWID لـ " + member.mention, ephemeral=True)


@bot.tree.command(name="addtime", description="تمديد ترخيص مشتري (للأونر)")
@app_commands.describe(member="المشتري", days="عدد الأيام للإضافة")
async def addtime(interaction: discord.Interaction, member: discord.Member, days: app_commands.Range[int, 1, 3650]):
    if not await _owner_only(interaction):
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    if not u["expires"]:
        await interaction.response.send_message("ترخيصه مدى الحياة.", ephemeral=True)
        return
    u["expires"] += days * 86400
    save_bg()
    await interaction.response.send_message(
        "✅ أُضيف **" + str(days) + "** يوم لـ " + member.mention + ". ينتهي " + fmt_expiry(u), ephemeral=True
    )


@bot.tree.command(name="listusers", description="قائمة المشترين (للأونر)")
async def listusers(interaction: discord.Interaction):
    if not await _owner_only(interaction):
        return
    await interaction.response.defer(ephemeral=True)
    now = time.time()
    if not DATA["users"]:
        await interaction.followup.send("ما في مشترين.", ephemeral=True)
        return
    lines = []
    for uid, u in DATA["users"].items():
        status = "✅" if (not u["expires"] or u["expires"] > now) else "❌"
        exp = "♾️" if not u["expires"] else "<t:" + str(int(u["expires"])) + ":d>"
        lines.append(status + " <@" + uid + "> | ينتهي: " + exp + " | Reset: " + str(u.get("resets", 0))
                     + " | تشغيل: " + str(u.get("runs", 0)))
    e = discord.Embed(title="👥 المشترين — " + PROJECT_NAME, color=BLUE, description="\n".join(lines[:25]))
    e.set_footer(text="الكلي: " + str(len(DATA["users"])))
    await interaction.followup.send(embed=e, ephemeral=True)


@bot.tree.command(name="ownerstats", description="إحصائيات المشروع (للأونر)")
async def ownerstats(interaction: discord.Interaction):
    if not await _owner_only(interaction):
        return
    now = time.time()
    total = len(DATA["users"])
    active = sum(1 for u in DATA["users"].values() if not u["expires"] or u["expires"] > now)
    unused = sum(1 for k in DATA["keys"].values() if not k["used_by"])
    e = discord.Embed(title="📊 إحصائيات " + PROJECT_NAME, color=BLUE)
    e.add_field(name="المشترين الكلي", value=str(total), inline=True)
    e.add_field(name="فعّالين", value=str(active), inline=True)
    e.add_field(name="منتهين", value=str(total - active), inline=True)
    e.add_field(name="مفاتيح غير مستخدمة", value=str(unused), inline=True)
    e.add_field(name="HWIDs محجوبة", value=str(len(_hwid_blacklist)), inline=True)
    e.add_field(name="▶️ تشغيل الكلي", value=str(sum(u.get("runs", 0) for u in DATA["users"].values())), inline=True)
    e.add_field(name="ملف السكربت", value="موجود ✅" if script_body() else "غير موجود ❌", inline=True)
    e.add_field(name="حالة السكربت", value=("🔴 موقوف: " + _script_lock_reason) if _script_locked else "🟢 يعمل", inline=True)
    await interaction.response.send_message(embed=e, ephemeral=True)


@bot.tree.command(name="lockdown", description="إيقاف تسليم السكربت للجميع (للأونر)")
@app_commands.describe(reason="سبب الإيقاف")
async def lockdown(interaction: discord.Interaction, reason: str = "under maintenance"):
    global _script_locked, _script_lock_reason
    if not await _owner_only(interaction):
        return
    _script_locked = True
    _script_lock_reason = reason.replace('"', "'")
    await interaction.response.send_message("🔴 Lockdown مفعّل. السبب: `" + reason + "`. استخدم /unlock للإلغاء.", ephemeral=True)


@bot.tree.command(name="unlock", description="إعادة تسليم السكربت (للأونر)")
async def unlock(interaction: discord.Interaction):
    global _script_locked, _script_lock_reason
    if not await _owner_only(interaction):
        return
    _script_locked = False
    _script_lock_reason = ""
    await interaction.response.send_message("🟢 تم رفع الـ Lockdown.", ephemeral=True)


@bot.tree.command(name="banhwid", description="حجب HWID (للأونر)")
async def banhwid(interaction: discord.Interaction, hwid: str):
    if not await _owner_only(interaction):
        return
    _hwid_blacklist.add(hwid)
    DATA["blacklist"] = list(_hwid_blacklist)
    save_bg()
    await interaction.response.send_message("🚫 تم حجب HWID: `" + hwid + "`", ephemeral=True)


@bot.tree.command(name="unbanhwid", description="رفع حجب HWID (للأونر)")
async def unbanhwid(interaction: discord.Interaction, hwid: str):
    if not await _owner_only(interaction):
        return
    _hwid_blacklist.discard(hwid)
    DATA["blacklist"] = list(_hwid_blacklist)
    save_bg()
    await interaction.response.send_message("✅ تم رفع حجب HWID: `" + hwid + "`", ephemeral=True)


@bot.tree.command(name="pause", description="تجميد ترخيص (للأونر)")
async def pause_license(interaction: discord.Interaction, member: discord.Member):
    if not await _owner_only(interaction):
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    if u.get("paused") or not u["expires"]:
        await interaction.response.send_message("مجمّد بالفعل أو مدى الحياة.", ephemeral=True)
        return
    u["paused"] = True
    u["paused_at"] = time.time()
    save_bg()
    await interaction.response.send_message("⏸️ تم تجميد ترخيص " + member.mention, ephemeral=True)


@bot.tree.command(name="resume", description="استئناف ترخيص مجمّد (للأونر)")
async def resume_license(interaction: discord.Interaction, member: discord.Member):
    if not await _owner_only(interaction):
        return
    u = DATA["users"].get(str(member.id))
    if not u or not u.get("paused"):
        await interaction.response.send_message("الترخيص مش مجمّد.", ephemeral=True)
        return
    frozen = time.time() - u.get("paused_at", time.time())
    if u["expires"]:
        u["expires"] += frozen
    u.pop("paused", None)
    u.pop("paused_at", None)
    save_bg()
    await interaction.response.send_message("▶️ تم استئناف ترخيص " + member.mention, ephemeral=True)


if __name__ == "__main__":
    Thread(target=lambda: _web.run(host="0.0.0.0", port=int(os.environ.get("PORT", 10000))), daemon=True).start()
    bot.run(TOKEN)
