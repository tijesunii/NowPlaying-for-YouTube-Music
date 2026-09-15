let lastState = { title: null, artist: null, is_playing: null };
let syncTimeout = null;
let observer = null;

function requestSync() {
    if (syncTimeout) clearTimeout(syncTimeout);
    syncTimeout = setTimeout(performSync, 500);
}

function performSync() {
    try {
        const titleEl = document.querySelector('yt-formatted-string.title.ytmusic-player-bar');
        const artistEl = document.querySelector('span.subtitle.ytmusic-player-bar');
        const imgEl = document.querySelector('img.image.ytmusic-player-bar');
        const videoEl = document.querySelector('video');

        if (!titleEl || !artistEl || !imgEl || !videoEl) return;

        const title = titleEl.textContent.trim();
        const artistText = artistEl.textContent.split(' • ')[0].trim();
        const image = imgEl.src;
        const is_playing = !videoEl.paused;

        if (
            title !== lastState.title ||
            artistText !== lastState.artist ||
            is_playing !== lastState.is_playing
        ) {
            lastState = { title, artist: artistText, is_playing };
            sendPayload(title, artistText, image, is_playing);
        }
    } catch (error) {
        console.error("[NowPlaying] Parse Error:", error);
    }
}

function sendPayload(title, artist, image, is_playing) {
    chrome.storage.sync.get(['apiUrl', 'secretToken'], (config) => {
        if (!config.apiUrl || !config.secretToken) return;

        fetch(config.apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                secret: config.secretToken,
                title,
                artist,
                image,
                is_playing
            })
        }).then(response => {
            if (!response.ok) throw new Error(response.status);
        }).catch(err => {
            console.error("[NowPlaying] Sync Error:", err);
            lastState.title = null; 
        });
    });
}

function initializeTracker() {
    const playerBar = document.querySelector('ytmusic-player-bar');
    const videoEl = document.querySelector('video');

    if (playerBar && videoEl) {
        observer = new MutationObserver(requestSync);
        observer.observe(playerBar, { childList: true, subtree: true, characterData: true });

        videoEl.addEventListener('play', requestSync);
        videoEl.addEventListener('pause', requestSync);
        
        requestSync();
    } else {
        setTimeout(initializeTracker, 1000);
    }
}

initializeTracker();

let remoteInterval = null;

function initializeRemoteControl() {
    if (remoteInterval) clearInterval(remoteInterval);
    
    remoteInterval = setInterval(() => {
        chrome.storage.sync.get(['remoteUrl'], (config) => {
            if (!config.remoteUrl) return;

            const cacheBusterUrl = config.remoteUrl + '?t=' + Date.now();

            fetch(cacheBusterUrl, { method: 'GET' })
                .then(response => response.json())
                .then(data => {
                    if (data && data.command) {
                        executeRemoteCommand(data.command);
                    }
                })
                .catch(err => {
                });
        });
    }, 2000);
}

function executeRemoteCommand(command) {
    const clickEvent = new MouseEvent('click', {
        view: window,
        bubbles: true,
        cancelable: true
    });

    if (command === 'next') {
        const btn = document.querySelector('.next-button');
        if (btn) btn.dispatchEvent(clickEvent);
    } else if (command === 'prev') {
        const btn = document.querySelector('.previous-button');
        if (btn) btn.dispatchEvent(clickEvent);
    } else if (command === 'play_pause') {
        const btn = document.querySelector('.play-pause-button');
        if (btn) btn.dispatchEvent(clickEvent);
    }
}

initializeRemoteControl();
