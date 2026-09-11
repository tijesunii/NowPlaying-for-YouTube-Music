document.addEventListener('DOMContentLoaded', () => {
    const apiUrlInput = document.getElementById('apiUrl');
    const remoteUrlInput = document.getElementById('remoteUrl');
    const secretTokenInput = document.getElementById('secretToken');
    const saveBtn = document.getElementById('saveBtn');
    const statusDiv = document.getElementById('status');

    chrome.storage.sync.get(['apiUrl', 'remoteUrl', 'secretToken'], (items) => {
        if (items.apiUrl) apiUrlInput.value = items.apiUrl;
        if (items.remoteUrl) remoteUrlInput.value = items.remoteUrl;
        if (items.secretToken) secretTokenInput.value = items.secretToken;
    });

    saveBtn.addEventListener('click', () => {
        const apiUrl = apiUrlInput.value.trim();
        const remoteUrl = remoteUrlInput.value.trim();
        const secretToken = secretTokenInput.value.trim();

        chrome.storage.sync.set({ apiUrl, remoteUrl, secretToken }, () => {
            statusDiv.classList.remove('hidden');
            setTimeout(() => statusDiv.classList.add('hidden'), 2500);
        });
    });
});
