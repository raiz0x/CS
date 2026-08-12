FROM python:3.11-slim

RUN apt-get update && apt-get install -y ffmpeg yt-dlp && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
EXPOSE 10000

CMD ["gunicorn", "-b", "0.0.0.0:10000", "app:app"]
