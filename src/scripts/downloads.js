const fs = require('node:fs');
const path = require('node:path');
const { DownloaderHelper } = require('node-downloader-helper');

// https://github.com/hgouveia/node-downloader-helper#options
async function downloadFile(url, savePath, options, cb) {
    if (!url || !savePath) return console.error('Please provide a url and a save path');
    if (cb && typeof cb !== 'function') return console.error('Callback must be a function');

    const normalizedPath = path.normalize(savePath);

    try {
        fs.accessSync(normalizedPath);
    } catch (err) {
        // Path doesn't exist, so create it
        fs.mkdirSync(normalizedPath, { recursive: true });
    }

    const dl = new DownloaderHelper(url, normalizedPath, options);

    if (
        options?.events &&
        Array.isArray(options?.events) &&
        options?.events.length > 0 &&
        options?.events.every((event) => {
            return typeof event === 'object';
        })
    )
        for (const event of options?.events) dl.on(event.name, event.cb);

    await dl.start().catch((err) => {
        if (cb) cb(err);
    });
}

module.exports = { downloadFile };
