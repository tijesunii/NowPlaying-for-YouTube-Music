# NowPlaying for YouTube Music

A lightweight tracker and remote control for YouTube Music. It tracks what you are listening to in real-time so you can display it on your personal portfolio, and lets you control the music directly from your phone.

## How it Works

1. **Chrome Extension**: Runs in your browser and grabs the song title, artist, and cover art whenever the music changes.
2. **PHP Backend**: A simple, fast server relay that receives the song data and securely handles commands. 
3. **Flutter Mobile App**: A sleek mobile app that acts as a remote control, allowing you to skip tracks or pause the music from anywhere.

## Setup Guide

### 1. Server Setup (PHP)
1. Upload the contents of the `/backend-template` folder to your web server (e.g., `https://your-domain.com/api/`).
2. Open `now-playing.php` and `remote.php` and change the `SECRET_TOKEN` to a secure, random password.
3. Make sure the folder has write permissions so the script can save the `current-track.json` and `command.json` files.

### 2. Chrome Extension Setup
1. Open Google Chrome and go to `chrome://extensions/`.
2. Turn on **Developer Mode** in the top right corner.
3. Click **Load unpacked** and select the `/extensions` folder from this project.
4. Click the extension icon in your toolbar to open the settings.
5. Enter your server URLs and the Secret Token you set in step 1, then click **Save**.

### 3. Display on your Portfolio
To show the currently playing song on your website, make a simple `GET` request to your `now-playing.php` URL. It will return the live track data in JSON format:
```json
{
  "is_playing": true,
  "title": "Song Title",
  "artist": "Artist Name",
  "image": "https://...",
  "updated_at": 1690000000
}
```

### 4. Mobile App Setup (Optional)
To use the remote control:
1. Install the provided `.apk` from the Releases tab on GitHub, or compile the `/mobile-app` folder yourself using Flutter.
2. Open the app and tap the Settings gear icon.
3. Enter your server URLs and Secret Token to connect it to your backend.
