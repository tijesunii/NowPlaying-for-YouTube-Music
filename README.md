# NowPlaying for YouTube™ Music

A sleek, highly optimized, and CSP-compliant Chrome Extension that securely tracks what you are listening to on YouTube Music and broadcasts it to a custom webhook. Perfect for displaying a real-time "Now Playing" widget on your personal developer portfolio.

## Architecture

This project is divided into two parts:
1. **The Chrome Extension (`extension/`)**: Extracts track info locally without heavy polling.
2. **The Webhook Backend (`backend-template/`)**: A secure, lock-safe PHP script that receives the data and serves it to your portfolio.

## 🚀 Installation & Setup

### 1. Host your Webhook (Backend)
1. Upload the `backend-template/` directory to your web server (e.g., `https://your-domain.com/api/`).
2. Open `now-playing.php` and change `YOUR_SUPER_SECRET_TOKEN_HERE` to a strong, random password.
3. Ensure the folder has write permissions so the script can create the `current-track.json` file.

### 2. Install the Extension
1. Clone or download this repository.
2. Open Google Chrome and navigate to `chrome://extensions/`.
3. Enable **Developer Mode** in the top right corner.
4. Click **Load unpacked** and select the `extension/` folder.

### 3. Configure the Tracker
1. In Chrome, click the extension icon in your toolbar to open the settings popup.
2. Enter the full URL to your PHP script (e.g., `https://your-domain.com/api/now-playing.php`).
3. Enter the Secret Token you defined in the PHP file.
4. Click **Save**.

### 4. Display on your Portfolio
Make a simple `GET` request from your portfolio frontend to your PHP endpoint. It will return JSON containing the current track:
```json
{
  "is_playing": true,
  "title": "Song Title",
  "artist": "Artist Name",
  "image": "https://...",
  "updated_at": 1690000000
}
```

## 🛡️ Security & Performance Highlights
* **Zero-Polling Architecture**: Uses `MutationObserver` and native Media Events instead of heavy `setInterval` loops, keeping your CPU usage at 0% when the track isn't changing.
* **Cryptographic Safety**: The PHP backend uses `hash_equals()` to prevent timing attacks against your secret token.
* **Concurrency Safe**: File writes utilize `LOCK_EX` to eliminate JSON corruption under heavy loads.
* **XSS Mitigation**: Aggressively sanitizes inputs via `textContent` locally and `htmlspecialchars` on the server, while validating image URLs.
