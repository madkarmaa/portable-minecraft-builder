<h1 align="center">
  <img src="https://static.wikia.nocookie.net/minecraft_gamepedia/images/1/12/Minecraft_Launcher_MS_Icon.png" alt="icon" style="width: 65px; height: 65px"><br>
  Portable Minecraft Builder
</h1>

> _Icon from the [Minecraft Wiki](https://minecraft.fandom.com/wiki/Minecraft_Launcher?file=Minecraft_Launcher_MS_Icon.png)_

A batch script that creates a portable Minecraft installation that you can use from **any Windows PC**, just put it in a USB drive. 😉

![separator](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

## ❓ Info

This script will download, extract and setup all the necessary tools by itself and delete them after it's done, **no software installation or admin permissions are required**.

It uses 64-bit resources, so it's meant for **64-bit Windows only**.

Sadly, I haven't discovered (_yet_) a way to automatically download SKlauncher from the official website, so I have to manually download it and host it on the [Dropbox](https://www.dropbox.com)'s CDN. You can scan the `.jar` file on [VirusTotal](https://www.virustotal.com/gui/home/upload) by yourself if you don't believe it's safe.

![separator](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

## ❓ How to use

Simply run `portable-minecraft-builder-(win64).bat` (download [here][download]). You'll be prompted to enter some personalization settings, then just let the script do its thing 😉. It will delete all the unnecessary files by itself. Further instructions/informations are available at script runtime.

![separator](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

## 🛠️ Tools and files used

- **[SKlauncher](https://skmedix.pl/)**: the Minecraft launcher.

> _I personally love this launcher, it's the main one I've been using since I've discovered it, even tho I've bought my own copy of Minecraft._

- **[jreisinger/ghrel](https://github.com/jreisinger/ghrel)**: used to download files from github repositories.

> _Huge thanks to **[@jreisinger](https://github.com/jreisinger)**, using their tool made my life way easier._

- **[adoptium/temurin17-binaries](https://github.com/adoptium/temurin17-binaries/)**: the recommended Java version by SKlauncher.

(current: [jdk-17.0.7+7](https://github.com/adoptium/temurin17-binaries/releases/tag/jdk-17.0.7+7))

> _Visit [Adoptium's website](https://adoptium.net/)._

![separator](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

## 🚨 Important 🚨

Neither I nor GitHub are responsible for any unintended use of these resources/softwares, as I do not own any of them, including (but not limited to) the [Minecraft](https://minecraft.net) brand/logo/game/name.

[download]: https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/portable-minecraft-builder-(win64).bat
