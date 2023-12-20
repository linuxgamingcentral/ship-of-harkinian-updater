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

menu() {
	zenity --width 800 --height 350 --list --radiolist --multiple --title "$title"\
	--column "Select an Option" \
	--column "Option" \
	--column="Description"\
	FALSE Download "Download or update SoH"\
	FALSE Changelog "View changelog (your web browser will open)"\
	FALSE Play "Play SoH"\
	FALSE Mods "Get mods"\
	FALSE Dumping "View ROM dumping guide (for Steam Deck, will open your web browser)"\
	FALSE Uninstall "Uninstall SoH"\
	TRUE Exit "Exit this script"
}

sub_menu() {
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

download_mod(){
	l=$1
	n=$2
	m=$3
	curl -L $1 -o $2
	unzip -o $2 -d mods/
	rm $2
	message "$3 downloaded!"
	message "Note you will need to use alternate assets in Enhancements -> Graphics -> Mods in order to use this.\nYou may also need to disable grotto fixed rotation in the same menu if you have the 3DS textures installed."
}

download_oot_reloaded(){
	l=$1
	n=$2
	m=$3
	curl -L $1 -o $2
	7za x $2 -o/$PWD/mods
	rm $2
	message "$3 downloaded!"
	message "Note you will need to use alternate assets in Enhancements -> Graphics -> Mods in order to use this."
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

mkdir -p soh
cd soh
mkdir -p mods

# Main menu
while true; do
Choice=$(menu)
	if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
		echo Goodbye!
		exit

	elif [ "$Choice" == "Download" ]; then
		echo -e "Downloading...\n"
		curl -L $(curl -s https://api.github.com/repos/HarbourMasters/Shipwright/releases/latest | grep "browser_download_url" | grep "Linux-Performance.zip" | cut -d '"' -f 4) -o soh-performance.zip
			
		echo -e "Extracting...\n"
		unzip -o soh-performance.zip
		rm soh-performance.zip
		chmod +x soh.appimage
		message "Download/update complete!"

	elif [ "$Choice" == "Changelog" ]; then
		xdg-open https://www.shipofharkinian.com/changelog

	elif [ "$Choice" == "Play" ]; then
		if ! [ -f soh.appimage ]; then
			message "SoH AppImage not found."
		else
			./soh.appimage
		fi

	elif [ "$Choice" == "Mods" ]; then
		while true; do
		Choice=$(sub_menu)
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
		xdg-open https://linuxgamingcentral.com/posts/ship-of-harkinian-steam-deck-guide/

	elif [ "$Choice" == "Uninstall" ]; then
		rm -rf logs/
		rm imgui.ini oot.otr readme.txt soh.appimage
		message "Uninstall complete. Your ROM, save data, mods, and configuration data have been preserved."
	fi
done
