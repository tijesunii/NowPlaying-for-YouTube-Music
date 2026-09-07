document.addEventListener('DOMContentLoaded', () => {
    const apiUrlInput = document.getElementById('apiUrl');
    const secretTokenInput = document.getElementById('secretToken');
    const saveBtn = document.getElementById('saveBtn');
    const statusDiv = document.getElementById('status');

    chrome.storage.sync.get(['apiUrl', 'secretToken'], (items) => {
        if (items.apiUrl) apiUrlInput.value = items.apiUrl;
        if (items.secretToken) secretTokenInput.value = items.secretToken;
    });

    saveBtn.addEventListener('click', () => {
        const apiUrl = apiUrlInput.value.trim();
        const secretToken = secretTokenInput.value.trim();

        chrome.storage.sync.set({ apiUrl, secretToken }, () => {
            statusDiv.classList.remove('hidden');
            setTimeout(() => statusDiv.classList.add('hidden'), 2500);
        });
    });
});
