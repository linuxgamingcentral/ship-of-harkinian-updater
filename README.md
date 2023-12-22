# Ship of Harkinian Updater for Steam Deck/Linux
Ship of Harkinian (*Zelda: OoT* PC port) installer and updater for Steam Deck/Linux.

![Screenshot](https://i.imgur.com/xGJr8ZV.png)

Download, update, and play SoH. It was primarily designed to be used with the Steam Deck but it should literally work across any Linux distro, so long as your distro has `p7zip-full` installed (for installing OoT Reloaded). You can also view the SoH changelog, install a couple of Steam Deck-specific mods, install high-resolution textures, and add the game as a non-Steam shortcut.

If you're on Steam Deck, download the [desktop file](https://raw.githubusercontent.com/linuxgamingcentral/ship-of-harkinian-updater/main/soh-updater.desktop) (right-click, save link as...) and run it. Other distros can run the script with:

`curl -L https://raw.githubusercontent.com/linuxgamingcentral/ship-of-harkinian-updater/main/soh-updater.sh | sh`

The script will create a `ship-of-harkinian` folder in `~/Applications/`. Put your legally-dumped ROM inside of this folder and name it to `zelda64.z64`. If this file isn't found, the script will ask you to locate your ROM. See my [ROM dumping guide for Steam Deck](https://linuxgamingcentral.com/posts/ship-of-harkinian-steam-deck-guide/) if you need to get your ROM dumped.
