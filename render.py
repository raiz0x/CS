from flask import Flask, request, jsonify
import subprocess
import os
import hashlib
import glob

app = Flask(__name__)

MUSIC_DIR = "/tmp/music"  # Pe Render, /tmp e writable
os.makedirs(MUSIC_DIR, exist_ok=True)

@app.route("/play")
def play():
    q = request.args.get("q", "").strip()
    if not q:
        return jsonify({"error": "Missing query"}), 400

    h = hashlib.md5(q.encode()).hexdigest()
    wav_file = os.path.join(MUSIC_DIR, f"{h}_8k.wav")
    base_url = request.host_url.rstrip("/")

    # Cache
    if os.path.exists(wav_file):
        dur = get_duration(wav_file)
        return jsonify({
            "url": f"{base_url}/music/{h}_8k.wav",
            "title": q,
            "duration": dur
        })

    # 1. Search & download with yt-dlp
    temp = os.path.join(MUSIC_DIR, h)
    cmd = [
        "yt-dlp", "-x", "--audio-format", "wav", "--audio-quality", "0",
        "-o", f"{temp}.%(ext)s", f"ytsearch1:{q}"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0 or not os.path.exists(f"{temp}.wav"):
        return jsonify({"error": "Download failed", "debug": result.stderr}), 500

    # 2. Convert to 8kHz mono PCM
    cmd = [
        "ffmpeg", "-y", "-i", f"{temp}.wav",
        "-ar", "8000", "-ac", "1", "-acodec", "pcm_s16le",
        wav_file
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    os.remove(f"{temp}.wav")
    
    if result.returncode != 0 or not os.path.exists(wav_file):
        return jsonify({"error": "Conversion failed", "debug": result.stderr}), 500

    dur = get_duration(wav_file)
    
    return jsonify({
        "url": f"{base_url}/music/{h}_8k.wav",
        "title": q,
        "duration": dur
    })

@app.route("/music/<path:filename>")
def serve_music(filename):
    return send_from_directory(MUSIC_DIR, filename)

def get_duration(filepath):
    cmd = ["ffprobe", "-v", "error", "-show_entries", "format=duration",
           "-of", "default=noprint_wrappers=1:nokey=1", filepath]
    result = subprocess.run(cmd, capture_output=True, text=True)
    try:
        return round(float(result.stdout.strip()))
    except:
        return 180

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)
