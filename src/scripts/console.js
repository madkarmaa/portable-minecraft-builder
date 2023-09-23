class ElectronConsole {
    constructor(electron_ipcMain_recieved_event) {
        this.event = electron_ipcMain_recieved_event;
    }

    log(message, ...args) {
        this.event.send('log', message, ...args);
    }

    popup(message, ...args) {
        this.event.send('popup', message, ...args);
    }

    warn(message, ...args) {
        this.event.send('warn', message, ...args);
    }

    error(error, ...args) {
        this.event.send('error', error, ...args);
    }
}

module.exports = { ElectronConsole };
