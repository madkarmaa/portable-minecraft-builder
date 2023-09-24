const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('node:path');
const fs = require('node:fs');
const fswin = require('fswin');
const { urls, templates } = require('./src/constants');
const { downloadFile } = require('./src/scripts/downloads');
const { ElectronConsole } = require('./src/scripts/console');

const StreamZip = require('node-stream-zip');

const createWindow = () => {
    const mainWindow = new BrowserWindow({
        width: 800,
        height: 500,
        autoHideMenuBar: true,
        webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            preload: path.join(__dirname, 'src', 'scripts', 'preload.js'),
        },
    });

    mainWindow.loadFile('./index.html');
};

ipcMain.on('build', async (event, buildData) => {
    const mcDirPath = path.join(__dirname, buildData.folderName);
    const elConsole = new ElectronConsole(event.sender);
    const downloadOptions = {
        override: true,
        events: [
            {
                name: 'end',
                cb: (info) => elConsole.log(info),
            },
            {
                name: 'error',
                cb: (err) => elConsole.error(err),
            },
            {
                name: 'progress',
                cb: (stats) => elConsole.log(stats),
            },
        ],
    };

    try {
        fs.mkdirSync(mcDirPath);
    } catch (e) {} // folder already exists

    // create launch files
    fs.writeFile(
        path.join(__dirname, 'minecraft.bat'),
        templates.bat('Java', 'launcher.jar', buildData.folderName),
        () => {
            fswin.setAttributes(path.join(__dirname, 'minecraft.bat'), { IS_HIDDEN: true }, () => {});
        }
    );
    fs.writeFile(path.join(__dirname, 'Minecraft.vbs'), templates.vbs, () => {});

    // download launcher
    await downloadFile(urls.launcher, __dirname, {
        ...downloadOptions, // copy existing options
        hidden: true,
        events: [
            ...downloadOptions.events, // copy existing events
            {
                name: 'end',
                cb: (stats) => {
                    // rename launcher to universal name
                    fs.renameSync(stats.filePath, path.join(path.dirname(stats.filePath), 'launcher.jar'));
                },
            },
        ],
    });

    // if install mods
    if (buildData.installMods) {
        // download mods
        const modsDownloads = (await urls.modrinth.getMods()).map((mod) => {
            // send warn if missing download url (probably no stable files found)
            if (!mod?.download_url) return elConsole.warn('Could not find a valid mod file for ' + mod.name);
            return downloadFile(mod.download_url, mcDirPath, downloadOptions);
        });

        // download fabric
        await downloadFile(await urls.fabric.latestVersion(), __dirname, {
            ...downloadOptions, // copy existing options
            events: [
                ...downloadOptions.events, // copy existing events
                {
                    name: 'end',
                    cb: (stats) => {
                        // rename fabric installer to universal name
                        fs.renameSync(stats.filePath, path.join(path.dirname(stats.filePath), 'fabric.jar'));
                    },
                },
            ],
        });

        // start mods downloads simultaneously
        await Promise.all(modsDownloads);
    }

    // extract once downloaded
    const onJavaDlEnd = (info) => {
        const zip = new StreamZip({
            file: info.filePath,
        });

        zip.on('error', function (err) {
            console.error(err);
        });

        zip.on('ready', () => {
            zip.extract(null, __dirname, (err, count) => {
                err ? elConsole.error(err) : elConsole.log(`Extracted ${count} files`);
                zip.close();

                // remove .zip file
                fs.unlinkSync(info.filePath, (err) => {
                    if (err) elConsole.error(err);
                });

                // read current directory for folders
                fs.readdir(__dirname, (err, files) => {
                    if (err) throw err;

                    const jdkFolder = files.find((file) => {
                        return fs.statSync(path.join(__dirname, file)).isDirectory() && file.startsWith('jdk');
                    });

                    // rename extracted folder to a more universal name
                    if (jdkFolder) fs.renameSync(path.join(__dirname, jdkFolder), path.join(__dirname, 'Java'));

                    // elConsole.popup("Close the launcher once it's completely loaded");
                    // fabricInstall(
                    //     path.join(__dirname, 'Java', 'bin'),
                    //     path.join(__dirname, 'launcher.jar'),
                    //     path.join(__dirname, 'fabric.jar'),
                    //     path.join(__dirname, buildData.folderName)
                    // );
                });
            });
        });
    };

    // download java
    // await downloadFile(await urls.java.latestVersion(), __dirname, {
    //     ...downloadOptions, // copy existing options
    //     events: [
    //         ...downloadOptions.events, // copy existing events
    //         {
    //             name: 'end',
    //             cb: onJavaDlEnd,
    //         },
    //     ],
    // });
});

app.on('ready', () => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit();
});
