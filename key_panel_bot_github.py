import asyncio
import base64
import json
import os
import random
import re
import secrets
import string
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
SCRIPT_TEXT = os.environ.get("SCRIPT_TEXT", "ضع هنا رابط أو لودر المشروع (متغير SCRIPT_TEXT).")
PUBLIC_URL = os.environ.get("PUBLIC_URL", "https://hxxfddhdj-1.onrender.com").rstrip("/")
SCRIPT_FILE = os.environ.get("SCRIPT_FILE", "protected_script.lua")
RESET_COOLDOWN = 24 * 3600

DATA_FILE = "keys_data.json"
BLUE, GREEN, RED = 0x5865F2, 0x57F287, 0xED4245

# rate limiting: max 10 requests per minute per IP
_rate_data = defaultdict(list)
_rate_lock = Lock()
RATE_LIMIT = 10
RATE_WINDOW = 60

_hwid_blacklist = set()

# global script lockdown — when True, /script returns 503 for ALL users
_script_locked = False
_script_lock_reason = ""

# brute force: max failed key attempts per HWID before auto-ban
BRUTEFORCE_LIMIT = 5
BRUTEFORCE_WINDOW = 300  # seconds
_bf_attempts: dict = defaultdict(list)  # hwid -> [timestamps]
_bf_lock = Lock()


def _record_failed_attempt(hwid: str) -> bool:
    now = time.time()
    with _bf_lock:
        hits = _bf_attempts[hwid]
        _bf_attempts[hwid] = [t for t in hits if now - t < BRUTEFORCE_WINDOW]
        _bf_attempts[hwid].append(now)
        if len(_bf_attempts[hwid]) >= BRUTEFORCE_LIMIT:
            _hwid_blacklist.add(hwid)
            DATA["blacklist"] = list(_hwid_blacklist)
            return True
    return False

def is_rate_limited(ip):
    now = time.time()
    with _rate_lock:
        hits = _rate_data[ip]
        _rate_data[ip] = [t for t in hits if now - t < RATE_WINDOW]
        if len(_rate_data[ip]) >= RATE_LIMIT:
            return True
        _rate_data[ip].append(now)
        return False

# ============================================================
#                   GitHub Storage
# ============================================================
GH_TOKEN = os.environ.get("GITHUB_TOKEN", "")
GH_REPO  = os.environ.get("GITHUB_REPO", "alsalehsamer2022-code/hxxfddhdj")
GH_PATH  = os.environ.get("GITHUB_DATA_PATH", "keys_data.json")
GH_API   = "https://api.github.com/repos/" + GH_REPO + "/contents/" + GH_PATH

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
            print("✅ GitHub data loaded, sha=" + str(_gh_sha))
        except urllib.error.HTTPError as e:
            if e.code == 404:
                print("⚠️ keys_data.json مش موجود على GitHub، رح ينشئه عند أول save")
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
#              🔒  Lua Obfuscator (built-in)
# ============================================================
_RNG = random.SystemRandom()
_RESERVED_LUA = {
    "and","break","do","else","elseif","end","false","for","function",
    "if","in","local","nil","not","or","repeat","return","then","true",
    "until","while","goto",
}

def _rand_name(length=None):
    if length is None:
        length = _RNG.randint(8, 16)
    chars = string.ascii_letters + string.digits
    return random.choice(string.ascii_letters) + "".join(_RNG.choice(chars) for _ in range(length - 1))

def _rand_names(n):
    seen = set()
    out = []
    while len(out) < n:
        name = _rand_name()
        if name not in seen and name not in _RESERVED_LUA:
            seen.add(name)
            out.append(name)
    return out

def _strip_comments(src: str) -> str:
    src = re.sub(r'--\[(=*)\[.*?\]\1\]', '', src, flags=re.DOTALL)
    lines = []
    for line in src.split('\n'):
        in_str = False
        result = []
        i = 0
        while i < len(line):
            c = line[i]
            if c in ('"', "'") and not in_str:
                in_str = c
                result.append(c)
            elif in_str and c == in_str and (i == 0 or line[i-1] != '\\'):
                in_str = False
                result.append(c)
            elif not in_str and c == '-' and i+1 < len(line) and line[i+1] == '-':
                break
            else:
                result.append(c)
            i += 1
        lines.append(''.join(result))
    return '\n'.join(lines)

def _xor_encrypt(data: bytes, key: bytes) -> bytes:
    out = bytearray(len(data))
    kl = len(key)
    for i, b in enumerate(data):
        out[i] = b ^ key[i % kl] ^ ((i * 7 + 13) & 0xFF)
    return bytes(out)

def _build_decryptor(encrypted: bytes, key: bytes) -> str:
    def to_lua_str(b: bytes) -> str:
        return '"' + "".join(f"\\{byte}" for byte in b) + '"'

    lua_enc = to_lua_str(encrypted)
    lua_key = to_lua_str(key)
    v_enc, v_key, v_out, v_i, v_kl, v_b, v_pos, v_fn, v_err = _rand_names(9)

    return (
        f"local {v_enc}={lua_enc}\n"
        f"local {v_key}={lua_key}\n"
        f"local {v_out}={{}}\n"
        f"local {v_kl}=#{v_key}\n"
        f"for {v_i}=1,#{v_enc} do\n"
        f"  local {v_b}=string.byte({v_enc},{v_i})\n"
        f"  local {v_pos}={v_i}-1\n"
        f"  {v_out}[{v_i}]=string.char(({v_b})~string.byte({v_key},({v_pos}%{v_kl})+1)~(({v_pos}*7+13)%256))\n"
        f"end\n"
        f"local {v_fn},{v_err}=loadstring(table.concat({v_out}))\n"
        f"if not {v_fn} then error({v_err}) end\n"
        f"{v_fn}()\n"
    )

def _anti_tamper() -> str:
    v1, v2, v3 = _rand_names(3)
    seed = _RNG.randint(10000, 99999)
    xval = _RNG.randint(1000, 9999)
    return (
        f"local {v1}={seed} local {v2}={xval} "
        f"local {v3}=({v1}*{v2})%65537 "
        f"if {v3}~={seed*xval%65537} then return end\n"
    )

def _obfuscate_numbers(src: str) -> str:
    def replacer(m):
        try:
            n = int(m.group(0))
            a = _RNG.randint(-9999, 9999)
            b = n - a
            return f"({a}+{b})"
        except:
            return m.group(0)
    return re.sub(r'(?<!["\'\w.])\b([1-9][0-9]{2,})\b(?!["\'\w.])', replacer, src)

def obfuscate_lua(src: str) -> str:
    """
    Double-layer XOR encryption + anti-tamper header.
    Roblox executor compatible (Lua 5.1 / LuaJIT).
    """
    src = _strip_comments(src)
    src = _obfuscate_numbers(src)

    # layer 1
    key1 = bytes(_RNG.randint(1, 255) for _ in range(_RNG.randint(16, 32)))
    enc1 = _xor_encrypt(src.encode("utf-8"), key1)
    layer1 = _build_decryptor(enc1, key1)

    # layer 2 wraps layer 1
    key2 = bytes(_RNG.randint(1, 255) for _ in range(_RNG.randint(16, 32)))
    enc2 = _xor_encrypt(layer1.encode("utf-8"), key2)
    layer2 = _build_decryptor(enc2, key2)

    return _anti_tamper() + "\n" + layer2


# cache: obfuscate once at startup, re-obfuscate every 6h (fresh keys each time)
_obf_cache: dict = {"body": None, "ts": 0}
_OBF_TTL = 6 * 3600  # 6 hours
_obf_lock = Lock()

def _inject_keys(raw: str) -> str:
    """Replace KEY_LIST in the lua source with all active keys from DATA."""
    now = time.time()
    active_keys = []
    for key, info in DATA["keys"].items():
        uid = info.get("used_by")
        if not uid:
            continue
        u = DATA["users"].get(str(uid))
        if not u:
            continue
        if u.get("expires") and u["expires"] < now:
            continue
        if u.get("paused"):
            continue
        active_keys.append(key)
    lua_list = ", ".join(f'"{k}"' for k in active_keys)
    # replace the KEY_LIST table content
    import re as _re
    patched = _re.sub(
        r'(local\s+KEY_LIST\s*=\s*\{)[^}]*(\})',
        lambda m: m.group(1) + "\n    " + lua_list + "\n" + m.group(2),
        raw,
        count=1,
    )
    return patched


def _read_script_raw() -> str | None:
    """Read protected_script.lua directly from GitHub."""
    if not GH_TOKEN:
        return None
    script_path = "protected_script.lua"
    api_url = f"https://api.github.com/repos/{GH_REPO}/contents/{script_path}"
    try:
        req = urllib.request.Request(api_url, headers=_gh_headers())
        with urllib.request.urlopen(req, timeout=10) as r:
            resp = json.loads(r.read())
        content = base64.b64decode(resp["content"]).decode("utf-8")
        print(f"✅ Script read from GitHub: {len(content)} bytes")
        return content
    except Exception as e:
        print("GitHub script read error:", repr(e))
        return None


def _get_obfuscated_script() -> str | None:
    # read raw from GitHub every time — keys change dynamically
    raw = _read_script_raw()
    if raw is None:
        return None
    raw = _inject_keys(raw)
    try:
        obf = obfuscate_lua(raw)
        print(f"✅ Script obfuscated: {len(raw)} → {len(obf)} bytes")
        return obf
    except Exception as e:
        print("Obfuscation error:", repr(e))
        return raw


# ============================================================
#     التحقق من الجهاز وتسليم السكربت
# ============================================================
def script_body():
    return _get_obfuscated_script()


@_web.route("/script")
def serve_script():
    ip = request.headers.get("X-Forwarded-For", request.remote_addr).split(",")[0].strip()
    if is_rate_limited(ip):
        return Response('warn("[license] too many requests")', 429, mimetype="text/plain")
    key = (request.args.get("key") or "").strip().upper()
    hwid = (request.args.get("hwid") or "NOHWID").strip()
    if hwid in _hwid_blacklist:
        return Response('warn("[license] device banned")', 403, mimetype="text/plain")
    if _script_locked:
        reason = _script_lock_reason or "script temporarily unavailable"
        return Response(f'warn("[license] {reason}")', 503, mimetype="text/plain")
    info = DATA["keys"].get(key)
    if not info or not info.get("used_by"):
        auto_banned = _record_failed_attempt(hwid)
        if auto_banned:
            asyncio.run_coroutine_threadsafe(
                notify_owners(
                    "🤖 **Auto-Ban HWID (brute force)**\n"
                    "HWID: `" + hwid + "`\n"
                    "سبب: " + str(BRUTEFORCE_LIMIT) + " محاولات خاطئة خلال " + str(BRUTEFORCE_WINDOW // 60) + " دقيقة"
                ),
                bot.loop,
            )
            save()
        return Response('warn("[license] invalid key")', 403, mimetype="text/plain")
    u = DATA["users"].get(str(info["used_by"]))
    if not u or u.get("key") != key:
        return Response('warn("[license] invalid key")', 403, mimetype="text/plain")
    if u["expires"] and u["expires"] < time.time():
        return Response('warn("[license] key expired")', 403, mimetype="text/plain")
    if u.get("paused"):
        return Response('warn("[license] key paused by admin")', 403, mimetype="text/plain")
    bound = u.get("hwid")
    if not bound:
        u["hwid"] = hwid
        save()
    elif bound != hwid:
        return Response('warn("[license] this key is locked to another device")', 403, mimetype="text/plain")
    body = script_body()
    if body is None:
        return Response('warn("[license] script not available yet")', 503, mimetype="text/plain")
    # track execution count
    u["runs"] = u.get("runs", 0) + 1
    u["last_run"] = time.time()
    save()
    # notify owners async (non-blocking)
    uid_str = str(info["used_by"])
    runs = u["runs"]
    asyncio.run_coroutine_threadsafe(
        notify_owners(
            f"▶️ **تشغيل سكربت**\n"
            f"المشتري: <@{uid_str}>\n"
            f"المفتاح: `{key}`\n"
            f"HWID: `{hwid}`\n"
            f"عدد مرات التشغيل: **{runs}**"
        ),
        bot.loop,
    )
    return Response(body, mimetype="text/plain")


def loader_line(key):
    return 'loadstring(game:HttpGet("' + PUBLIC_URL + '/script?key=' + key + '"))()'


async def notify_owners(text):
    for oid in OWNER_IDS:
        try:
            user = await bot.fetch_user(oid)
            await user.send(text)
        except Exception as e:
            print("تعذر إرسال إشعار للأونر:", repr(e))


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
                print("تعذر إعطاء الرتبة:", repr(e))
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
        exp = ("مدى الحياة ♾️" if not info["days"] else "<t:" + str(int(now + info["days"] * 86400)) + ":R>")
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
        print("❌ خطأ في الزر", getattr(item, "custom_id", "?"))
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
            "📜 انسخ هذا السطر وشغّله. **مربوط بجهازك الأول**، وإذا أعطيته لشخص ما راح يشتغل عنده:\n```lua\n"
            + loader_line(u["key"]) + "\n```",
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
#                   Owner: /reobfuscate
# ============================================================
# slash command to force fresh obfuscation immediately
# useful after updating the script file


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
        print("⚠️ sync فشل في", guild.id, repr(ex))


@bot.event
async def on_ready():
    global _started
    print("✅ شغّال كـ", bot.user)
    if _started:
        return
    _started = True
    try:
        await bot.http.bulk_upsert_global_commands(bot.application_id, [])
    except Exception as ex:
        print("⚠️ مسح global فشل", repr(ex))
    for g in list(bot.guilds):
        if ALLOWED_GUILDS and g.id not in ALLOWED_GUILDS:
            await g.leave()
            continue
        await sync_guild(g)
    # pre-obfuscate at startup in background
    loop = asyncio.get_event_loop()
    loop.run_in_executor(None, _get_obfuscated_script)
    await notify_owners(
        "🟢 **البوت شغال / ريستارت**\n"
        "الوقت: <t:" + str(int(time.time())) + ":F>\n"
        "السيرفرات: **" + str(len(bot.guilds)) + "**\n"
        "🔒 التشفير: مفعّل (يتجدد كل 6 ساعات)"
    )
    bot.loop.create_task(daily_report())
    bot.loop.create_task(expiry_notifier())


@bot.event
async def on_guild_join(guild):
    if ALLOWED_GUILDS and guild.id not in ALLOWED_GUILDS:
        await guild.leave()
        return
    await sync_guild(guild)


# ============================================================
#                   Daily Report
# ============================================================
async def daily_report():
    await bot.wait_until_ready()
    while True:
        await asyncio.sleep(86400)
        now = time.time()
        total = len(DATA["users"])
        active = sum(1 for u in DATA["users"].values() if not u["expires"] or u["expires"] > now)
        expired = total - active
        total_resets = sum(u.get("resets", 0) for u in DATA["users"].values())
        await notify_owners(
            "📋 **تقرير يومي — " + PROJECT_NAME + "**\n"
            "المشترين الكلي: **" + str(total) + "**\n"
            "فعّالين: **" + str(active) + "**\n"
            "منتهين: **" + str(expired) + "**\n"
            "Resets الكلي: **" + str(total_resets) + "**"
        )


# ============================================================
#                   Expiry Notifier (3 days)
# ============================================================
async def expiry_notifier():
    await bot.wait_until_ready()
    notified = set()
    while True:
        await asyncio.sleep(3600)
        now = time.time()
        for uid, u in DATA["users"].items():
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
@bot.tree.command(name="panel", description="انشر لوحة التحكم (للأونر)")
async def panel(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    e = discord.Embed(
        title=PROJECT_NAME + " Control Panel",
        description="لوحة التحكم الخاصة بمشروع **" + PROJECT_NAME + "**.\n"
        "إذا كنت مشتري، اضغط الأزرار بالأسفل لتفعيل مفتاحك أو استلام المشروع أو الرتبة.",
        color=BLUE,
    )
    await interaction.response.send_message(embed=e, view=PanelView())


@bot.tree.command(name="genkey", description="توليد مفاتيح جديدة (للأونر)")
@app_commands.describe(count="عدد المفاتيح (1-100)", days="مدة الصلاحية بالأيام (0 = مدى الحياة)")
async def genkey(interaction: discord.Interaction, count: app_commands.Range[int, 1, 100] = 1,
                 days: app_commands.Range[int, 0, 3650] = 30):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    keys = []
    for _ in range(count):
        k = "-".join(secrets.token_hex(2).upper() for _ in range(3))
        DATA["keys"][k] = {"days": days, "used_by": None}
        keys.append(k)
    await asyncio.to_thread(save)
    await interaction.followup.send(
        "🔑 المفاتيح (" + ("مدى الحياة" if not days else str(days) + " يوم") + "):\n```\n" + "\n".join(keys) + "\n```",
        ephemeral=True,
    )
    await notify_owners(
        "🗝️ **توليد مفاتيح**\n"
        "بواسطة: " + interaction.user.mention + "\n"
        "العدد: **" + str(count) + "** | المدة: " + ("مدى الحياة" if not days else str(days) + " يوم") + "\n"
        "المفاتيح:\n```\n" + "\n".join(keys) + "\n```"
    )


@bot.tree.command(name="revoke", description="سحب ترخيص مشتري (للأونر)")
async def revoke(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
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
                print("تعذر سحب الرتبة:", repr(e))
    await interaction.response.send_message("✅ تم سحب الترخيص من " + member.mention, ephemeral=True)


@bot.tree.command(name="resetuser", description="تصفير HWID لمشتري بدون cooldown (للأونر)")
@app_commands.describe(member="المشتري")
async def resetuser(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    u["hwid"] = None
    u["last_reset"] = 0
    save_bg()
    await interaction.response.send_message(
        "✅ تم تصفير HWID لـ " + member.mention + ". يقدر يستخدم Reset الحين.", ephemeral=True
    )
    await notify_owners(
        "🔧 **Owner Reset HWID**\nبواسطة: " + interaction.user.mention +
        "\nللمشتري: " + member.mention + " (`" + str(member.id) + "`)"
    )


@bot.tree.command(name="addtime", description="تمديد ترخيص مشتري (للأونر)")
@app_commands.describe(member="المشتري", days="عدد الأيام للإضافة")
async def addtime(interaction: discord.Interaction, member: discord.Member, days: app_commands.Range[int, 1, 3650]):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    if not u["expires"]:
        await interaction.response.send_message("ترخيصه مدى الحياة، ما يحتاج تمديد.", ephemeral=True)
        return
    u["expires"] += days * 86400
    save_bg()
    await interaction.response.send_message(
        "✅ تم إضافة **" + str(days) + "** يوم لـ " + member.mention + ". ينتهي " + fmt_expiry(u),
        ephemeral=True,
    )


@bot.tree.command(name="listusers", description="قائمة المشترين (للأونر)")
async def listusers(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
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
        lines.append(status + " <@" + uid + "> | ينتهي: " + exp + " | Reset: " + str(u.get("resets", 0)) + " | تشغيل: " + str(u.get("runs", 0)))
    e = discord.Embed(title="👥 المشترين — " + PROJECT_NAME, color=BLUE,
                      description="\n".join(lines[:25]))
    e.set_footer(text="الكلي: " + str(len(DATA["users"])))
    await interaction.followup.send(embed=e, ephemeral=True)


@bot.tree.command(name="ownerstats", description="إحصائيات المشروع (للأونر)")
async def ownerstats(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    now = time.time()
    total = len(DATA["users"])
    active = sum(1 for u in DATA["users"].values() if not u["expires"] or u["expires"] > now)
    expired = total - active
    unused_keys = sum(1 for k in DATA["keys"].values() if not k["used_by"])
    total_resets = sum(u.get("resets", 0) for u in DATA["users"].values())
    blacklisted = len(_hwid_blacklist)
    obf_age = int((time.time() - _obf_cache["ts"]) / 60) if _obf_cache["ts"] else -1
    e = discord.Embed(title="📊 إحصائيات " + PROJECT_NAME, color=BLUE)
    e.add_field(name="المشترين الكلي", value=str(total), inline=True)
    e.add_field(name="فعّالين", value=str(active), inline=True)
    e.add_field(name="منتهين", value=str(expired), inline=True)
    e.add_field(name="مفاتيح غير مستخدمة", value=str(unused_keys), inline=True)
    e.add_field(name="Resets الكلي", value=str(total_resets), inline=True)
    total_runs = sum(u.get("runs", 0) for u in DATA["users"].values())
    e.add_field(name="HWIDs محجوبة", value=str(blacklisted), inline=True)
    e.add_field(name="▶️ تشغيل الكلي", value=str(total_runs), inline=True)
    e.add_field(name="🔒 آخر تشفير", value=f"منذ {obf_age} دقيقة" if obf_age >= 0 else "لم يتم بعد", inline=True)
    lockdown_val = f"🔴 موقوف\n`{_script_lock_reason}`" if _script_locked else "🟢 يعمل"
    e.add_field(name="حالة السكربت", value=lockdown_val, inline=True)
    await interaction.response.send_message(embed=e, ephemeral=True)


@bot.tree.command(name="reobfuscate", description="إعادة تشفير السكربت فوراً (للأونر)")
async def reobfuscate(interaction: discord.Interaction):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    # force cache expiry
    with _obf_lock:
        _obf_cache["ts"] = 0
    result = await asyncio.to_thread(_get_obfuscated_script)
    if result:
        size_kb = len(result) // 1024
        await interaction.followup.send(
            f"✅ تم إعادة التشفير.\nالحجم الجديد: **{size_kb} KB**", ephemeral=True
        )
    else:
        await interaction.followup.send("❌ فشل التشفير — تأكد من وجود الملف.", ephemeral=True)


# ============================================================
#              lockdown / unlock — سحب السكربت من الكل
# ============================================================
@bot.tree.command(name="lockdown", description="إيقاف تسليم السكربت لجميع المشترين فوراً (للأونر)")
@app_commands.describe(reason="سبب الإيقاف (يظهر في الـ executor للمشتري)")
async def lockdown(interaction: discord.Interaction, reason: str = "under maintenance"):
    global _script_locked, _script_lock_reason
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    if _script_locked:
        await interaction.response.send_message("⚠️ السكربت موقوف بالفعل.", ephemeral=True)
        return
    _script_locked = True
    _script_lock_reason = reason
    active_count = sum(
        1 for u in DATA["users"].values()
        if not u.get("expires") or u["expires"] > time.time()
    )
    await interaction.response.send_message(
        f"🔴 **Lockdown مفعّل**\n"
        f"السكربت الحين محجوب عن **{active_count}** مشتري فعّال.\n"
        f"السبب: `{reason}`\n"
        f"استخدم `/unlock` لإعادة التفعيل.",
        ephemeral=True,
    )
    await notify_owners(
        f"🔴 **LOCKDOWN**\nبواسطة: {interaction.user.mention}\n"
        f"المشترين المتأثرين: **{active_count}**\n"
        f"السبب: `{reason}`"
    )


@bot.tree.command(name="unlock", description="إعادة تفعيل تسليم السكربت لجميع المشترين (للأونر)")
async def unlock(interaction: discord.Interaction):
    global _script_locked, _script_lock_reason
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    if not _script_locked:
        await interaction.response.send_message("⚠️ السكربت مش موقوف أصلاً.", ephemeral=True)
        return
    _script_locked = False
    _script_lock_reason = ""
    await interaction.response.send_message(
        "🟢 **Lockdown رُفع** — السكربت يُسلَّم الحين لجميع المشترين الفعّالين.",
        ephemeral=True,
    )
    await notify_owners(
        f"🟢 **UNLOCK**\nبواسطة: {interaction.user.mention}\n"
        f"السكربت متاح مجدداً لجميع المشترين."
    )


@bot.tree.command(name="banhwid", description="حجب HWID (للأونر)")
@app_commands.describe(hwid="الـ HWID المراد حجبه")
async def banhwid(interaction: discord.Interaction, hwid: str):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    _hwid_blacklist.add(hwid)
    DATA["blacklist"] = list(_hwid_blacklist)
    save_bg()
    await interaction.response.send_message("🚫 تم حجب HWID: `" + hwid + "`", ephemeral=True)


@bot.tree.command(name="unbanhwid", description="رفع حجب HWID (للأونر)")
@app_commands.describe(hwid="الـ HWID المراد رفع حجبه")
async def unbanhwid(interaction: discord.Interaction, hwid: str):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    _hwid_blacklist.discard(hwid)
    DATA["blacklist"] = list(_hwid_blacklist)
    save_bg()
    await interaction.response.send_message("✅ تم رفع حجب HWID: `" + hwid + "`", ephemeral=True)


@bot.tree.command(name="banhwiduser", description="حجب HWID مشتري مباشرة بالمنشن (للأونر)")
@app_commands.describe(member="المشتري")
async def banhwiduser(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u or not u.get("hwid"):
        await interaction.response.send_message("هذا العضو ما عنده HWID مسجّل.", ephemeral=True)
        return
    hwid = u["hwid"]
    _hwid_blacklist.add(hwid)
    DATA["blacklist"] = list(_hwid_blacklist)
    save_bg()
    await interaction.response.send_message(
        "🚫 تم حجب HWID لـ " + member.mention + "\nHWID: `" + hwid + "`", ephemeral=True
    )
    await notify_owners(
        "🚫 **banhwid by member**\nبواسطة: " + interaction.user.mention +
        "\nالعضو: " + member.mention + " (`" + str(member.id) + "`)\nHWID: `" + hwid + "`"
    )


@bot.tree.command(name="transfer", description="نقل ترخيص من مشتري لآخر (للأونر)")
@app_commands.describe(from_member="المشتري الأصلي", to_member="المشتري الجديد",
                       keep_hwid="ابقِ HWID المرتبط؟ (افتراضي: لا)")
async def transfer(interaction: discord.Interaction, from_member: discord.Member,
                   to_member: discord.Member, keep_hwid: bool = False):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    src = DATA["users"].pop(str(from_member.id), None)
    if not src:
        await interaction.response.send_message("المشتري الأصلي ما عنده ترخيص.", ephemeral=True)
        return
    if DATA["users"].get(str(to_member.id)):
        await interaction.response.send_message(
            "⚠️ " + to_member.mention + " عنده ترخيص بالفعل. revoke أول.", ephemeral=True
        )
        DATA["users"][str(from_member.id)] = src
        return
    if not keep_hwid:
        src["hwid"] = None
        src["last_reset"] = 0
    DATA["users"][str(to_member.id)] = src
    key_info = DATA["keys"].get(src["key"])
    if key_info:
        key_info["used_by"] = to_member.id
    save_bg()
    if BUYER_ROLE_ID:
        role = interaction.guild.get_role(BUYER_ROLE_ID)
        if role:
            try:
                await from_member.remove_roles(role, reason="نقل ترخيص")
            except Exception:
                pass
            try:
                await to_member.add_roles(role, reason="نقل ترخيص")
            except Exception:
                pass
    await interaction.response.send_message(
        "✅ تم نقل الترخيص من " + from_member.mention + " إلى " + to_member.mention +
        ("\n🔗 HWID محتفظ به." if keep_hwid else "\n🔄 HWID تم تصفيره للعضو الجديد."),
        ephemeral=True,
    )
    await notify_owners(
        "🔀 **Transfer License**\nبواسطة: " + interaction.user.mention +
        "\nمن: " + from_member.mention + " → إلى: " + to_member.mention +
        "\nHWID: " + ("محتفظ" if keep_hwid else "صُفِّر")
    )


@bot.tree.command(name="pause", description="تجميد ترخيص (يوقف عداد الوقت) (للأونر)")
@app_commands.describe(member="المشتري")
async def pause_license(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    if u.get("paused"):
        await interaction.response.send_message("⚠️ الترخيص مجمّد بالفعل.", ephemeral=True)
        return
    if not u["expires"]:
        await interaction.response.send_message("ترخيصه مدى الحياة، التجميد ما يؤثر عليه.", ephemeral=True)
        return
    u["paused"] = True
    u["paused_at"] = time.time()
    save_bg()
    await interaction.response.send_message("⏸️ تم تجميد ترخيص " + member.mention, ephemeral=True)
    await notify_owners(
        "⏸️ **Pause License**\nبواسطة: " + interaction.user.mention +
        "\nالعضو: " + member.mention
    )


@bot.tree.command(name="resume", description="استئناف ترخيص مجمّد (للأونر)")
@app_commands.describe(member="المشتري")
async def resume_license(interaction: discord.Interaction, member: discord.Member):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    u = DATA["users"].get(str(member.id))
    if not u:
        await interaction.response.send_message("هذا العضو ما عنده ترخيص.", ephemeral=True)
        return
    if not u.get("paused"):
        await interaction.response.send_message("⚠️ الترخيص مش مجمّد.", ephemeral=True)
        return
    frozen_duration = time.time() - u.get("paused_at", time.time())
    if u["expires"]:
        u["expires"] += frozen_duration
    u.pop("paused", None)
    u.pop("paused_at", None)
    save_bg()
    await interaction.response.send_message(
        "▶️ تم استئناف ترخيص " + member.mention +
        "\n+**" + str(int(frozen_duration // 3600)) + "** ساعة أُضيفت للصلاحية.",
        ephemeral=True,
    )
    await notify_owners(
        "▶️ **Resume License**\nبواسطة: " + interaction.user.mention +
        "\nالعضو: " + member.mention +
        "\nمدة التجميد: " + str(int(frozen_duration // 3600)) + " ساعة أُعيدت"
    )


@bot.tree.command(name="whoishwid", description="اعرف مين يملك HWID معيّن (للأونر)")
@app_commands.describe(hwid="الـ HWID")
async def whoishwid(interaction: discord.Interaction, hwid: str):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    hwid = hwid.strip()
    matches = [(uid, u) for uid, u in DATA["users"].items() if u.get("hwid") == hwid]
    if not matches:
        banned_note = " *(محجوب)*" if hwid in _hwid_blacklist else ""
        await interaction.response.send_message(
            "❌ ما في مشتري مرتبط بهذا الـ HWID." + banned_note, ephemeral=True
        )
        return
    uid, u = matches[0]
    e = discord.Embed(title="🔍 whois HWID", color=BLUE)
    e.add_field(name="HWID", value="`" + hwid + "`", inline=False)
    e.add_field(name="المشتري", value="<@" + uid + ">", inline=True)
    e.add_field(name="المفتاح", value="`" + u.get("key", "?") + "`", inline=True)
    e.add_field(name="الحالة",
                value="فعّال ✅" if (not u["expires"] or u["expires"] > time.time()) else "منتهي ❌",
                inline=True)
    e.add_field(name="ينتهي", value=fmt_expiry(u), inline=True)
    e.add_field(name="محجوب؟", value="نعم 🚫" if hwid in _hwid_blacklist else "لا ✅", inline=True)
    await interaction.response.send_message(embed=e, ephemeral=True)


@bot.tree.command(name="executions", description="قائمة المشترين وعدد مرات تشغيل السكربت (للأونر)")
@app_commands.describe(sort="رتّب حسب: runs (الأكثر تشغيلاً) أو recent (الأحدث)")
@app_commands.choices(sort=[
    app_commands.Choice(name="الأكثر تشغيلاً", value="runs"),
    app_commands.Choice(name="الأحدث تشغيلاً", value="recent"),
])
async def executions(interaction: discord.Interaction, sort: str = "runs"):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    now = time.time()
    users = [
        (uid, u) for uid, u in DATA["users"].items()
    ]
    if sort == "recent":
        users.sort(key=lambda x: x[1].get("last_run", 0), reverse=True)
    else:
        users.sort(key=lambda x: x[1].get("runs", 0), reverse=True)
    if not users:
        await interaction.followup.send("ما في مشترين.", ephemeral=True)
        return
    total_runs = sum(u.get("runs", 0) for _, u in users)
    lines = []
    for uid, u in users[:25]:
        runs = u.get("runs", 0)
        last = u.get("last_run")
        last_str = f"<t:{int(last)}:R>" if last else "لم يشغّل بعد"
        status = "✅" if (not u.get("expires") or u["expires"] > now) else "❌"
        lines.append(f"{status} <@{uid}> — **{runs}** مرة | آخر تشغيل: {last_str}")
    e = discord.Embed(
        title=f"▶️ إحصائيات التشغيل — {PROJECT_NAME}",
        description="\n".join(lines),
        color=BLUE,
    )
    e.set_footer(text=f"إجمالي التشغيل: {total_runs} | المشترين: {len(users)}")
    await interaction.followup.send(embed=e, ephemeral=True)


@bot.tree.command(name="genkeyfile", description="توليد مفاتيح كثيرة وتسليمها كملف .txt (للأونر)")
@app_commands.describe(count="عدد المفاتيح (1-500)", days="مدة الصلاحية بالأيام (0 = مدى الحياة)")
async def genkeyfile(interaction: discord.Interaction,
                     count: app_commands.Range[int, 1, 500] = 10,
                     days: app_commands.Range[int, 0, 3650] = 30):
    if not is_owner(interaction.user):
        await interaction.response.send_message("🔒 للأونر فقط.", ephemeral=True)
        return
    await interaction.response.defer(ephemeral=True)
    keys = []
    for _ in range(count):
        k = "-".join(secrets.token_hex(2).upper() for _ in range(3))
        DATA["keys"][k] = {"days": days, "used_by": None}
        keys.append(k)
    await asyncio.to_thread(save)
    duration_label = "مدى الحياة" if not days else str(days) + " يوم"
    file_content = (
        "# " + PROJECT_NAME + " — Keys\n"
        "# المدة: " + duration_label + "\n"
        "# التاريخ: " + str(int(time.time())) + "\n\n" +
        "\n".join(keys)
    ).encode("utf-8")
    file = discord.File(
        fp=__import__("io").BytesIO(file_content),
        filename="keys_" + duration_label.replace(" ", "_") + "_" + str(count) + ".txt"
    )
    await interaction.followup.send(
        "🔑 **" + str(count) + "** مفتاح (" + duration_label + ") — مرفق كملف.",
        file=file,
        ephemeral=True,
    )
    await notify_owners(
        "🗝️ **genkeyfile**\nبواسطة: " + interaction.user.mention +
        "\nالعدد: **" + str(count) + "** | المدة: " + duration_label
    )


if __name__ == "__main__":
    Thread(target=lambda: _web.run(host="0.0.0.0", port=int(os.environ.get("PORT", 10000))), daemon=True).start()
    bot.run(TOKEN)
