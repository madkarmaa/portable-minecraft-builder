const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
    // expose ipcRenderer.send to DOM
    sendMessage: function (message, ...data) {
        ipcRenderer.send(message, ...data);
    },
    // expose ipcRenderer.on to DOM
    onMessage: function (message, callback) {
        ipcRenderer.on(message, callback);
    },
});
