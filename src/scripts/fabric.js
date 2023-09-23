const { exec } = require('child_process');
const fs = require('node:fs');
const path = require('path');

function fabricInstall(javaBinDir, launcherExecutable, fabricExecutable, gameDir) {
    const launcherProcess = exec(
        `${path.join(javaBinDir, 'java.exe')} -jar ${launcherExecutable} --workDir ${gameDir}`
    );

    launcherProcess.on('exit', () => {
        const fabricProcess = exec(
            `${path.join(javaBinDir, 'java.exe')} -jar ${fabricExecutable} client -dir ${gameDir}`
        );

        fabricProcess.on('exit', () => {
            fs.unlink(fabricExecutable, (err) => {});
        });
    });
}

module.exports = { fabricInstall };
