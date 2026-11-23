"""
بوت ديسكورد للأغاني (عراقي حزين + دول + أجنبي) مع التحكم بالصوت - Python 3
ملف واحد فقط: bot.py

التثبيت (مرة وحدة):
    pip uninstall -y discord.py
    pip install -U "py-cord[voice]" yt-dlp aiohttp
    ثبّت ffmpeg على الجهاز / السيرفر

متغيرات البيئة المطلوبة:
    DISCORD_TOKEN      — توكن البوت
    TARGET_VOICE_ID    — ID الروم الصوتي اللي البوت يدخله من البداية
    MENU_CHANNEL_ID    — ID القناة النصية اللي يرسل فيها القائمة
    OPENAI_API_KEY     — اختياري، للأمر /listen فقط
"""

import asyncio
import base64
import os
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

import aiohttp
import discord
import yt_dlp

# ─── keepalive للاستضافة المجانية ───────────────────────────────────────────
class _Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, *args):
        pass

threading.Thread(
    target=lambda: HTTPServer(('', int(os.environ.get('PORT', 10000))), _Handler).serve_forever(),
    daemon=True
).start()

# ─── إعدادات ─────────────────────────────────────────────────────────────────
TOKEN            = os.getenv("DISCORD_TOKEN",    "حط_التوكن_هنا")
OPENAI_API_KEY   = os.getenv("OPENAI_API_KEY",   "حط_مفتاح_OpenAI_هنا")
TARGET_VOICE_ID  = int(os.getenv("TARGET_VOICE_ID", "0"))   # ID الروم الصوتي
MENU_CHANNEL_ID  = int(os.getenv("MENU_CHANNEL_ID",  "0"))  # ID القناة النصية

CATEGORIES = {
    "iraq_sad":   "أغاني عراقية حزينة",
    "iraq":       "أغاني عراقية",
    "saudi":      "أغاني سعودية",
    "kuwait":     "أغاني كويتية",
    "uae":        "أغاني اماراتية",
    "egypt":      "أغاني مصرية",
    "lebanon":    "أغاني لبنانية",
    "syria":      "أغاني سورية",
    "morocco":    "أغاني مغربية",
    "turkey":     "أغاني تركية",
    "foreign":    "English songs top hits",
    "foreign_sad":"sad english songs",
}

YDL_SEARCH  = {"quiet": True, "extract_flat": True, "skip_download": True}
YDL_AUDIO   = {"format": "bestaudio/best", "quiet": True, "noplaylist": True}
FFMPEG_OPTS = {
    "before_options": "-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5",
    "options": "-vn",
}

# ─── intents ─────────────────────────────────────────────────────────────────
intents = discord.Intents.default()
intents.members      = True   # لازم تفعّله في Developer Portal → Privileged Intents
intents.voice_states = True

bot    = discord.Bot(intents=intents)
queues: dict[int, dict] = {}


def get_state(guild_id: int) -> dict:
    return queues.setdefault(guild_id, {"queue": [], "current": None})


# ─── بحث وتشغيل ──────────────────────────────────────────────────────────────
def _search(q: str, n: int = 10) -> list[dict]:
    with yt_dlp.YoutubeDL(YDL_SEARCH) as y:
        info = y.extract_info(f"ytsearch{n}:{q}", download=False)
    out = []
    for e in info.get("entries", []):
        if not e:
            continue
        out.append({
            "id":       e["id"],
            "title":    e.get("title") or "؟",
            "author":   e.get("uploader") or e.get("channel") or "",
            "duration": e.get("duration"),
        })
    return out


async def search(q: str) -> list[dict]:
    return await asyncio.to_thread(_search, q)


def _get_audio_url(video_id: str) -> str:
    with yt_dlp.YoutubeDL(YDL_AUDIO) as y:
        info = y.extract_info(f"https://www.youtube.com/watch?v={video_id}", download=False)
    return info["url"]


def fmt_duration(sec) -> str:
    if not sec:
        return "؟"
    sec = int(sec)
    return f"{sec // 60}:{sec % 60:02d}"


async def play_next(guild: discord.Guild):
    s  = get_state(guild.id)
    vc = guild.voice_client
    if not vc or not s["queue"]:
        s["current"] = None
        return
    item = s["queue"].pop(0)
    s["current"] = item
    try:
        url = await asyncio.to_thread(_get_audio_url, item["id"])
    except Exception as e:
        print("yt-dlp error:", e)
        return await play_next(guild)

    loop = asyncio.get_running_loop()

    def after(err):
        if err:
            print("player error:", err)
        asyncio.run_coroutine_threadsafe(play_next(guild), loop)

    vc.play(discord.FFmpegPCMAudio(url, **FFMPEG_OPTS), after=after)


async def ensure_vc(guild: discord.Guild, channel: discord.VoiceChannel) -> discord.VoiceClient:
    vc = guild.voice_client
    if vc and vc.is_connected():
        if vc.channel.id != channel.id:
            await vc.move_to(channel)
        return vc
    return await channel.connect()


# ─── قائمة الأقسام ───────────────────────────────────────────────────────────
def make_category_view() -> discord.ui.View:
    class CategorySelect(discord.ui.Select):
        def __init__(self):
            options = [
                discord.SelectOption(label=v, value=k)
                for k, v in CATEGORIES.items()
            ]
            super().__init__(placeholder="اختر قسم الأغاني 🎶", options=options)

        async def callback(self, interaction: discord.Interaction):
                        await interaction.response.defer(ephemeral=False)
           spaces results = await search(CATEGORIES[self.values[0]])
            if not results:
                return await interaction.followup.send("ما لقيت شي 😔", ephemeral=True)
            await interaction.followup.send(
                f"🎶 {CATEGORIES[self.values[0]]}",
                view=results_view(results),
            )

    return discord.ui.View(CategorySelect(), timeout=300)


# ─── قائمة النتائج ───────────────────────────────────────────────────────────
class ResultSelect(discord.ui.Select):
    def __init__(self, results: list[dict]):
        options = [
            discord.SelectOption(
                label=r["title"][:100],
                description=f'{r["author"]} • {fmt_duration(r["duration"])}'[:100],
                value=r["id"],
            )
            for r in results
        ]
        super().__init__(placeholder="اختر الأغنية 🎵", options=options)
        self.titles = {r["id"]: r["title"] for r in results}

    async def callback(self, interaction: discord.Interaction):
        voice = interaction.user.voice
        if not voice:
            return await interaction.response.send_message("ادخل روم صوتي أول 🎤", ephemeral=True)
        await interaction.response.defer(ephemeral=False)
        vid   = self.values[0]
        title = self.titles[vid]
        await ensure_vc(interaction.guild, voice.channel)
        s = get_state(interaction.guild.id)
        s["queue"].append({"id": vid, "title": title})
        if s["current"] is None:
            await play_next(interaction.guild)
        await interaction.followup.send(f"✅ انضافت: **{title}**")


def results_view(results: list[dict]) -> discord.ui.View:
    return discord.ui.View(ResultSelect(results), timeout=900)


# ─── مساعد: إيجاد قناة نصية صالحة ──────────────────────────────────────────
def find_text_channel(guild: discord.Guild) -> discord.TextChannel | None:
    # أولوية 1: القناة المحددة بـ MENU_CHANNEL_ID
    if MENU_CHANNEL_ID:
        ch = guild.get_channel(MENU_CHANNEL_ID)
        if ch and isinstance(ch, discord.TextChannel):
            perms = ch.permissions_for(guild.me)
            if perms.send_messages and perms.embed_links:
                return ch

    # أولوية 2: system channel
    if guild.system_channel:
        perms = guild.system_channel.permissions_for(guild.me)
        if perms.send_messages:
            return guild.system_channel

    # أولوية 3: أي قناة اسمها يحتوي على كلمة معروفة
    keywords = ["عام", "general", "chat", "bot", "بوت", "music", "موسيقى"]
    for ch in sorted(guild.text_channels, key=lambda c: c.position):
        perms = ch.permissions_for(guild.me)
        if perms.send_messages and any(w in ch.name.lower() for w in keywords):
            return ch

    # أولوية 4: أول قناة متاحة
    for ch in sorted(guild.text_channels, key=lambda c: c.position):
        if ch.permissions_for(guild.me).send_messages:
            return ch

    return None


# ─── on_ready: دخول الروم الصوتي فور التشغيل ────────────────────────────────
@bot.event
async def on_ready():
    print(f"✅ شغال باسم {bot.user}")

    # حط الصورة مرة وحدة
    if bot.user.avatar is None:
        try:
            await bot.user.edit(avatar=base64.b64decode(LOGO_B64))
            print("🖼️ تم وضع صورة البوت")
        except Exception as e:
            print("avatar error:", e)

    # دخول الروم الصوتي المحدد في كل السيرفرات
    if TARGET_VOICE_ID == 0:
        print("⚠️ TARGET_VOICE_ID غير محدد — البوت لن يدخل روماً تلقائياً عند التشغيل")
        return

    for guild in bot.guilds:
        try:
            vc_channel = guild.get_channel(TARGET_VOICE_ID)
            if vc_channel is None or not isinstance(vc_channel, discord.VoiceChannel):
                print(f"[{guild.name}] TARGET_VOICE_ID مش روم صوتي أو مش موجود")
                continue

            existing_vc = guild.voice_client
            if existing_vc and existing_vc.is_connected():
                if existing_vc.channel.id != vc_channel.id:
                    await existing_vc.move_to(vc_channel)
                    print(f"[{guild.name}] انتقل إلى {vc_channel.name}")
            else:
                await vc_channel.connect()
                print(f"[{guild.name}] دخل {vc_channel.name}")

        except Exception as e:
            print(f"[{guild.name}] خطأ في الدخول التلقائي: {e}")


# ─── on_voice_state_update: قائمة لما حد يدخل ──────────────────────────────
@bot.event
async def on_voice_state_update(member: discord.Member, before: discord.VoiceState, after: discord.VoiceState):
    # تجاهل البوت نفسه
    if member.bot:
        return

    # خرج من كل الرومات
    if after.channel is None:
        return

    # ما انتقل — نفس الروم بالظبط
    if before.channel is not None and before.channel.id == after.channel.id:
        return

    guild = member.guild

    # البوت يتبع الشخص للروم لو مش فيها
    try:
        vc = guild.voice_client
        if vc and vc.is_connected():
            if vc.channel.id != after.channel.id:
                await vc.move_to(after.channel)
        else:
            await after.channel.connect()
    except Exception as e:
        print("voice join error:", e)
        return

    # القائمة تطلع دايماً لما حد يدخل — سواء جديد أو انتقل
    text_channel = find_text_channel(guild)
    if text_channel is None:
        return

    try:
        await text_channel.send(
            f"🎵 أهلاً **{member.display_name}**! اختر قسم الأغاني:",
            view=make_category_view(),
        )
    except Exception as e:
        print("send menu error:", e)


# ─── أوامر ───────────────────────────────────────────────────────────────────
@bot.slash_command(name="play", description="ابحث وشغل أغنية")
async def play(ctx: discord.ApplicationContext,
               name: discord.Option(str, "اسم الأغنية أو المغني")):
    await ctx.defer()
    results = await search(name)
    if not results:
        return await ctx.followup.send("ما لقيت شي 😔")
    await ctx.followup.send("🎵 النتائج:", view=results_view(results))


@bot.slash_command(name="category", description="تصفح أغاني حسب القسم / الدولة")
async def category(ctx: discord.ApplicationContext,
                   kind: discord.Option(
                       str, "القسم",
                       choices=[discord.OptionChoice(v, k) for k, v in CATEGORIES.items()])):
    await ctx.defer()
    results = await search(CATEGORIES[kind])
    await ctx.followup.send(f"🎶 {CATEGORIES[kind]}", view=results_view(results))


@bot.slash_command(name="menu", description="عرض قائمة الأقسام")
async def menu(ctx: discord.ApplicationContext):
    await ctx.respond("🎶 اختر قسم الأغاني:", view=make_category_view())


@bot.slash_command(name="listen", description="البوت يسمعك تقول اسم الأغنية")
async def listen(ctx: discord.ApplicationContext):
    if not ctx.author.voice:
        return await ctx.respond("ادخل روم صوتي أول 🎤", ephemeral=True)
    if OPENAI_API_KEY.startswith("حط"):
        return await ctx.respond("ما حطيت OPENAI_API_KEY", ephemeral=True)
    await ctx.respond("🎤 وش الأغنية اللي تبيها؟ تكلم الحين (عندك 7 ثواني)...")
    vc = await ensure_vc(ctx.guild, ctx.author.voice.channel)
    try:
        vc.start_recording(discord.sinks.WaveSink(), on_recording_done, ctx.channel, ctx.author.id)
    except Exception as e:
        print("record error:", e)
        return await ctx.followup.send("ما قدرت أبدأ التسجيل، جرب بعد شوي.")
    await asyncio.sleep(7)
    if vc.recording:
        vc.stop_recording()


@bot.slash_command(name="pause", description="إيقاف مؤقت")
async def pause(ctx: discord.ApplicationContext):
    vc = ctx.guild.voice_client
    if vc and vc.is_playing():
        vc.pause()
    await ctx.respond("⏸️ تم")


@bot.slash_command(name="resume", description="متابعة")
async def resume(ctx: discord.ApplicationContext):
    vc = ctx.guild.voice_client
    if vc and vc.is_paused():
        vc.resume()
    await ctx.respond("▶️ تم")


@bot.slash_command(name="skip", description="تخطي الأغنية")
async def skip(ctx: discord.ApplicationContext):
    vc = ctx.guild.voice_client
    if vc and (vc.is_playing() or vc.is_paused()):
        vc.stop()
    await ctx.respond("⏭️ تم")


@bot.slash_command(name="queue", description="عرض قائمة الانتظار")
async def queue(ctx: discord.ApplicationContext):
    s = get_state(ctx.guild.id)
    lines = []
    if s["current"]:
        lines.append(f"▶️ {s['current']['title']}")
    lines += [f"{i + 1}. {q['title']}" for i, q in enumerate(s["queue"])]
    await ctx.respond("\n".join(lines)[:1900] if lines else "القائمة فاضية")


@bot.slash_command(name="stop", description="إيقاف وخروج")
async def stop(ctx: discord.ApplicationContext):
    s = get_state(ctx.guild.id)
    s["queue"].clear()
    s["current"] = None
    vc = ctx.guild.voice_client
    if vc:
        await vc.disconnect()
    await ctx.respond("⏹️ تم الإيقاف")


# ─── تعرف على الصوت ──────────────────────────────────────────────────────────
async def transcribe(wav: bytes) -> str:
    form = aiohttp.FormData()
    form.add_field("file", wav, filename="voice.wav", content_type="audio/wav")
    form.add_field("model", "whisper-1")
    form.add_field("prompt", "اسم أغنية أو مغني، عربي أو إنجليزي")
    async with aiohttp.ClientSession() as session:
        async with session.post(
            "https://api.openai.com/v1/audio/transcriptions",
            headers={"Authorization": f"Bearer {OPENAI_API_KEY}"},
            data=form,
        ) as r:
            if r.status != 200:
                raise RuntimeError(await r.text())
            data = await r.json()
            return (data.get("text") or "").strip()


async def on_recording_done(sink: discord.sinks.WaveSink, channel, user_id: int):
    audio = sink.audio_data.get(user_id)
    if not audio:
        return await channel.send("ما سمعتك 😔 جرب /listen مرة ثانية.")
    audio.file.seek(0)
    try:
        text = await transcribe(audio.file.read())
        if not text:
            return await channel.send("ما فهمت كلامك زين، جرب مرة ثانية.")
        results = await search(text)
        if not results:
            return await channel.send(f"سمعتك تقول: **{text}**\nبس ما لقيت شي 😔")
        await channel.send(f"سمعتك تقول: **{text}**\n🎵 النتائج:", view=results_view(results))
    except Exception as e:
        print("listen error:", e)
        await channel.send("صار خطأ بالتعرف على الصوت. تأكد من OPENAI_API_KEY.")


# ─── صورة البوت (مدمجة) ──────────────────────────────────────────────────────
LOGO_B64 = """
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
FFFFBIRRRRRIRRRRRIRRRRRIRRRRRIRf/2Q==
"""

bot.run(TOKEN)
