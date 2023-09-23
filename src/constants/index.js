const urls = {
    fabric: {
        // latest fabric loader version
        latestVersion: async () => {
            const versions = await (
                await fetch('https://meta.fabricmc.net/v2/versions/installer').catch((e) => console.error(e))
            ).json();
            return versions.find((v) => v.stable).url;
        },
    },

    java: {
        latestVersion: async () => {
            const versions = await (
                await fetch('https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest')
            ).json();

            return versions.assets.find((asset) => asset.name.match(/^OpenJDK17U-jdk_x64_windows_hotspot.*\.zip$/))
                .browser_download_url;
        },
    },

    // launcher file
    launcher: 'https://skmedix.pl/_data/SKlauncher-3.1.1.jar',

    minecraft: {
        // latest minecraft version
        latestVersion: async () => {
            const version = await (await fetch('https://launchermeta.mojang.com/mc/game/version_manifest.json')).json();
            return version.latest.release;
        },
    },

    modrinth: {
        baseUrl: 'https://api.modrinth.com/v2/project/',

        // mods list
        modsList: [
            'alternate-current',
            'c2me-fabric',
            'entityculling',
            'fabric-api',
            'iris',
            'lithium',
            'sodium',
            'starlight',
            'memoryleakfix',
            'krypton',
            'dynamic-fps',
            'modmenu',
        ],

        getMods: async () => {
            // mods API urls
            const apiUrls = urls.modrinth.modsList.sort().map((mod) => urls.modrinth.baseUrl + mod);

            const modsData = await Promise.all(
                apiUrls.map(async (url) => {
                    // general mod data
                    const modData = await (await fetch(url)).json();
                    // mod versions data
                    const modVersionsData = await (await fetch(url + '/version')).json();

                    // only keep stable versions for fabric loader for the latest game version
                    const latestVersion = modVersionsData
                        .filter(
                            (version) =>
                                version.version_type === 'release' &&
                                version.loaders.includes('fabric') &&
                                version.game_versions.includes('1.20.1') // DEBUG: 1.20.2 is too new
                            // version.game_versions.includes(urls.minecraft.latestVersion())
                        )
                        // only keep the latest version if multiple are available
                        .sort((a, b) => new Date(b.date_published) - new Date(a.date_published))[0];

                    // get primary file data
                    const primaryFile = latestVersion?.files.find((file) => file.primary);

                    // return mod name and download url
                    return {
                        name: modData.title,
                        download_url: primaryFile ? primaryFile.url : null,
                    };
                })
            );

            return modsData;
        },
    },
};

const templates = {
    bat: (javafolder, launchername, gamedir) => {
        return `
@echo off

set java="%~dp0${javafolder}\\bin\\javaw.exe"
set launcher="%~dp0${launchername}"
set workingDirectory="%~dp0${gamedir}"

%java% -jar %launcher% --workDir %workingDirectory%`;
    },

    vbs: `
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & ".\\minecraft.bat" & Chr(34), 0
Set WshShell = Nothing
`,
};

module.exports = { urls, templates };
