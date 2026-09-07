const API_ENDPOINT = "https://eben.allmytools.xyz/api/now-playing.php"; // Update this when deploying to production
const SECRET_TOKEN = "eben_custom_tracker_secret_2026"; // Must match the PHP file

let lastState = {
  title: null,
  artist: null,
  is_playing: null
};

// Function to read the DOM and extract track info
function checkNowPlaying() {
  try {
    // YouTube Music's player bar elements
    const titleEl = document.querySelector('yt-formatted-string.title.ytmusic-player-bar');
    const artistEl = document.querySelector('span.subtitle.ytmusic-player-bar');
    const imgEl = document.querySelector('img.image.ytmusic-player-bar');
    const videoEl = document.querySelector('video');

    if (!titleEl || !artistEl || !imgEl || !videoEl) return;

    const title = titleEl.innerText;
    // Artist text might contain a bullet point " • " depending on the layout, so we split it out
    const artistText = artistEl.innerText.split(' • ')[0]; 
    const image = imgEl.src;
    const is_playing = !videoEl.paused;

    // Only send an update if something actually changed
    if (
      title !== lastState.title ||
      artistText !== lastState.artist ||
      is_playing !== lastState.is_playing
    ) {
      
      // Keep track of state so we don't spam the server
      lastState = { title, artist: artistText, is_playing };

      // Send payload to PHP backend
      fetch(API_ENDPOINT, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          secret: SECRET_TOKEN,
          title: title,
          artist: artistText,
          image: image,
          is_playing: is_playing
        })
      }).catch(err => console.error("Failed to sync to portfolio:", err));
      
      console.log(`[YTM Tracker] Synced: ${title} by ${artistText} (Playing: ${is_playing})`);
    }
  } catch (error) {
    // Ignore errors while elements are loading
  }
}

// Poll every 3 seconds to catch play/pause and track changes immediately
setInterval(checkNowPlaying, 3000);
