#!/bin/bash

clear

echo -e "Ship of Harkinian updater - script by Linux Gaming Central\n"

# Check if GitHub is reachable
if ! curl -Is https://github.com | head -1 | grep 200 > /dev/null
then
    message "GitHub appears to be unreachable, you may not be connected to the Internet."
    exit 1
fi

title="Ship of Harkinian Updater"

# get SteamID - for adding SoH as a non-Steam shortcut
if [ $USER != "deck" ]; then
	STEAMID=$(find ~/.steam/debian-installation/userdata/ -mindepth 1 -maxdepth 1 -type d | sed -n '2p')
else
	STEAMID=$(find ~/.local/share/Steam/userdata/ -mindepth 1 -maxdepth 1 -type d | sed -n '1p')
fi
STEAMID=$(basename "$STEAMID")
echo -e "Steam ID is $STEAMID\n"

main_menu() {
	zenity --width 900 --height 350 --list --radiolist --multiple --title "$title"\
	--column "Select an Option" \
	--column "Option" \
	--column="Description"\
	FALSE Download "Download or update SoH"\
	FALSE Changelog "View changelog (your web browser will open)"\
	FALSE Play "Play SoH"\
	FALSE Steam "Add SoH as a non-Steam shortcut"\
	FALSE Mods "Get mods"\
	FALSE Dumping "View ROM dumping guide (for Steam Deck, will open your web browser)"\
	FALSE Uninstall "Uninstall SoH"\
	TRUE Exit "Exit this script"
}

mod_menu() {
	zenity --width 600 --height 350 --list --radiolist --multiple --title "$title"\
	--column "Select an Option" \
	--column "Option" \
	--column="Description"\
	FALSE OS "Get Steam Deck icon for splash screen"\
	FALSE SteamDeckUI "Download the Steam Deck UI"\
	FALSE 3DS "Download 3DS textures"\
	FALSE Reloaded "Download OOT Reloaded (hi-res textures)"\
	FALSE Other "Get other mods (your web browser will open)"\
	FALSE Remove "Uninstall all mods"\
	TRUE Main "Go back"
}

download_mod() {
	l=$1
	n=$2
	m=$3
	curl -L $1 -o $2
	unzip -o $2 -d mods/
	rm $2
	message "$3 downloaded! Make sure \"Use Alternate Assets\" is checked on in Enhancements -> Graphics -> Mods.\nIf you're using the 3DS textures you'll also need to disable Grotto Fixed Rotation in the same menu."
}

download_oot_reloaded() {
	l=$1
	n=$2
	m=$3
	curl -L $1 -o $2
	7za x $2 -o/$PWD/mods
	rm $2
	message "$3 installed! Make sure \"Use Alternate Assets\" is checked on in Enhancements -> Graphics -> Mods."
}

message() {
	t=$1
	zenity --info --title "$title" --text "$1" --width 400 --height 75
}

question() {
	t=$1
	zenity --question --title "$title" --text "$1" --width 400 --height 75
}

progress_bar() {
	t=$1
	zenity --title "$title" --text "$1" --progress --pulsate --auto-close --auto-kill --width=300 --height=100

	if [ "$?" != 0 ]; then
		echo -e "\nUser canceled.\n"
	fi
}

cd $HOME
mkdir -p Applications
cd Applications
mkdir -p ship-of-harkinian
cd ship-of-harkinian
mkdir -p mods

# Main menu
while true; do
Choice=$(main_menu)
	if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
		echo Goodbye!
		exit

	elif [ "$Choice" == "Download" ]; then
		(
		echo -e "Downloading...\n"
		curl -L $(curl -s https://api.github.com/repos/HarbourMasters/Shipwright/releases/latest | grep "browser_download_url" | grep "Linux-Performance.zip" | cut -d '"' -f 4) -o soh-performance.zip
			
		echo -e "Extracting...\n"
		unzip -o soh-performance.zip
		rm soh-performance.zip
		chmod +x soh.appimage
		) | progress_bar "Downloading/updating, please wait..."
		message "Download/update complete!"

	elif [ "$Choice" == "Changelog" ]; then
		xdg-open https://www.shipofharkinian.com/changelog

	elif [ "$Choice" == "Play" ]; then
		if ! [ -f soh.appimage ]; then
			message "SoH AppImage not found."
		else
			# if ROM isn't found in soh directory, ask user to locate it
			if ! [ -f zelda64.z64 ]; then
				ROM=`zenity --file-selection --file-filter='ROM file (z64) | *.z64' --title="Select ROM"`

				case $? in
		 		0)
		        		echo "\"$ROM\" selected."
		        		mv $ROM zelda64.z64
		        		./soh.appimage;;
		 		1)
		        		echo "No file selected.";;
				-1)
		        		echo "An unexpected error has occurred.";;
				esac
			else
				./soh.appimage
			fi
		fi
	
	elif [ "$Choice" == "Steam" ]; then
		if ! [ -f soh.appimage ]; then
			message "SoH AppImage not found."
		else
			# temporarily download some python scripts, execute them, then remove them when we're done
			wget https://raw.githubusercontent.com/linuxgamingcentral/Steam-Shortcut-Manager/master/shortcuts.py
			wget https://raw.githubusercontent.com/linuxgamingcentral/Steam-Shortcut-Manager/master/crc_algorithms.py
			if [ $USER != "deck" ]; then
				python shortcuts.py "$HOME/.steam/debian-installation/userdata/$STEAMID/config/shortcuts.vdf" "Ship of Harkinian" "$HOME/Applications/ship-of-harkinian/soh.appimage" $HOME/Applications/ship-of-harkinian/ "" "" "" 0 0 1 0 0 SoH
			else
				python shortcuts.py "$HOME/.local/share/Steam/userdata/$STEAMID/config/shortcuts.vdf" "Ship of Harkinian" "$HOME/Applications/ship-of-harkinian/soh.appimage" $HOME/Applications/ship-of-harkinian/ "" "" "" 0 0 1 0 0 SoH
			fi
			rm shortcuts.py crc_algorithms.py
			rm -rf __pycache__
			message "SoH added as a non-Steam shortcut! Note if Steam is open you'll need to restart it to see the changes."
		fi

	elif [ "$Choice" == "Mods" ]; then
		while true; do
		Choice=$(mod_menu)
			if [ $? -eq 1 ] || [ "$Choice" == "Main" ]; then
				break
			
			elif [ "$Choice" == "OS" ]; then
				download_mod "https://gamebanana.com/dl/978007" "steamdeckintro.zip" "Steam Deck intro"
				rm mods/apple.otr mods/linux.otr mods/switch.otr mods/wiiu.otr mods/windows.otr
			
			elif [ "$Choice" == "SteamDeckUI" ]; then		
				download_mod "https://gamebanana.com/dl/1028208" "steamdeckui.zip" "Steam Deck UI"
			
			elif [ "$Choice" == "3DS" ]; then
				if ( question "This will conflict if you have OoT Reloaded installed. Continue?" ); then
				yes |
					(
					download_mod "https://gamebanana.com/dl/1095310" "3ds.zip" "3DS textures"
					) | progress_bar "Downloading and installing, please wait..."
				else
					echo -e "User selected No.\n"
				fi
			
			elif [ "$Choice" == "Reloaded" ]; then
				if ( question "This will conflict if you have the 3DS textures installed. Continue?" ); then
				yes |
					(
					download_oot_reloaded "https://evilgames.eu/texture-packs/files/oot-reloaded-v10.4.2-soh-otr-hd.7z" "reloaded.7z" "OoT Reloaded"
					) | progress_bar "Downloading and installing, please wait..."
				else
					echo -e "User selected No.\n"
				fi
			
			elif [ "$Choice" == "Other" ]; then
				xdg-open https://gamebanana.com/mods/games/16121? 
			
			elif [ "$Choice" == "Remove" ]; then
				if ( question "Are you sure you want to uninstall all mods?" ); then
				yes |
					rm -rf mods/*
					message "All mods removed!"
				else
					echo -e "User selected No.\n"
				fi	
			fi
		done	

	elif [ "$Choice" == "Dumping" ]; then
		xdg-open https://linuxgamingcentral.com/posts/ship-of-harkinian-steam-deck-guide/?utm_source=Updater

	elif [ "$Choice" == "Uninstall" ]; then
		if ( question "Are you sure you want to uninstall (your save/configuration data will be preserved)?" ); then
		yes | 
			rm -rf logs/
			rm imgui.ini oot.otr readme.txt soh.appimage
			message "Uninstall complete. Your ROM, save data, mods, and configuration data have been preserved."
		else
			echo -e "User selected No.\n"
		fi
	fi
done
