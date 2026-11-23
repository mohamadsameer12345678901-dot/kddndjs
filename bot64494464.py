"""
بوت ديسكورد للأغاني (عراقي حزين + دول + أجنبي) مع التحكم بالصوت - Python 3
ملف واحد فقط: bot.py

الملف فيه كل شي: الكود + صورة البوت (مدمجة بالأسفل) + المكتبات.
البوت يحط صورته تلقائياً أول ما يشتغل لو ما عنده صورة.

التثبيت (مرة وحدة):
    pip uninstall -y discord.py        (لو كان مثبت عندك)
    pip install -U "py-cord[voice]" yt-dlp aiohttp
    ثبّت ffmpeg على الجهاز / السيرفر

التشغيل:
    python3 bot.py
"""

import asyncio
import base64
import os

import aiohttp
import discord
import yt_dlp

# ===== عبّي هذي القيم (أو حطها كمتغيرات بيئة بالاستضافة) =====
TOKEN = os.getenv("DISCORD_TOKEN", "حط_التوكن_هنا")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "حط_مفتاح_OpenAI_هنا")  # للتعرف على الصوت /listen
# ==============================================================

CATEGORIES = {
    "iraq_sad": "أغاني عراقية حزينة",
    "iraq": "أغاني عراقية",
    "saudi": "أغاني سعودية",
    "kuwait": "أغاني كويتية",
    "uae": "أغاني اماراتية",
    "egypt": "أغاني مصرية",
    "lebanon": "أغاني لبنانية",
    "syria": "أغاني سورية",
    "morocco": "أغاني مغربية",
    "turkey": "أغاني تركية",
    "foreign": "English songs top hits",
    "foreign_sad": "sad english songs",
}

YDL_SEARCH = {"quiet": True, "extract_flat": True, "skip_download": True}
YDL_AUDIO = {"format": "bestaudio/best", "quiet": True, "noplaylist": True}
FFMPEG_OPTS = {
    "before_options": "-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5",
    "options": "-vn",
}

bot = discord.Bot(intents=discord.Intents.default())
queues: dict[int, dict] = {}


def get_state(guild_id: int) -> dict:
    return queues.setdefault(guild_id, {"queue": [], "current": None})


# ---------- البحث والتشغيل ----------
def _search(q: str, n: int = 10) -> list[dict]:
    with yt_dlp.YoutubeDL(YDL_SEARCH) as y:
        info = y.extract_info(f"ytsearch{n}:{q}", download=False)
    out = []
    for e in info.get("entries", []):
        if not e:
            continue
        out.append({
            "id": e["id"],
            "title": e.get("title") or "؟",
            "author": e.get("uploader") or e.get("channel") or "",
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
    s = get_state(guild.id)
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


# ---------- قائمة النتائج ----------
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
        await interaction.response.defer()
        vid = self.values[0]
        title = self.titles[vid]
        await ensure_vc(interaction.guild, voice.channel)
        s = get_state(interaction.guild.id)
        s["queue"].append({"id": vid, "title": title})
        if s["current"] is None:
            await play_next(interaction.guild)
        await interaction.followup.send(f"✅ انضافت: **{title}**")


def results_view(results: list[dict]) -> discord.ui.View:
    return discord.ui.View(ResultSelect(results), timeout=900)


# ---------- التعرف على الصوت ----------
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


# ---------- الأوامر ----------
@bot.event
async def on_ready():
    print(f"✅ شغال باسم {bot.user}")
    if bot.user.avatar is None:  # يحط الصورة مرة وحدة بس
        try:
            await bot.user.edit(avatar=base64.b64decode(LOGO_B64))
            print("🖼️ تم وضع صورة البوت")
        except Exception as e:
            print("avatar error:", e)


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


@bot.slash_command(name="listen", description="البوت يدخل الروم ويسمعك تقول اسم الأغنية")
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


# ---------- صورة البوت (مدمجة) ----------
LOGO_B64 = """
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
2Q==
"""

bot.run(TOKEN)
