window.addEventListener('DOMContentLoaded', () => {
    document.querySelector('form').addEventListener('submit', (e) => {
        // prevent form submit from refreshing the page
        e.preventDefault();
        document.querySelector('#submit').disabled = true;
    });

    // TODO: DOM logs
    window.api.onMessage('log', (e, message) => {
        console.log(message);
    });

    window.api.onMessage('popup', (e, message) => {
        alert(message);
    });

    window.api.onMessage('warn', (e, warn) => {
        console.warn(warn);
    });

    window.api.onMessage('error', (e, error) => {
        console.error(error);
    });

    document.querySelector('#submit').addEventListener('click', () => {
        folderInput = document.querySelector('#folder-name');
        // remove starting dots
        folderInput.value = folderInput.value.replace(/^\.+/, '');
        // remove invalid folder names (https://stackoverflow.com/a/31918294)
        folderInput.value = folderInput.value.replace(
            /[<>:"\/\\|?*\x00-\x1F]|^(?:aux|con|clock\$|nul|prn|com[1-9]|lpt[1-9])$/i,
            ''
        );
        // set default folder name
        folderInput.value = folderInput.value ? '.' + folderInput.value : '.minecraft';

        // send build message to main process with build data
        window.api.sendMessage('build', {
            folderName: folderInput.value,
            installMods: document.querySelector('#install-mods').checked,
        });
    });
});
