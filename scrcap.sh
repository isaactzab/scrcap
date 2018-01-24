#!/bin/bash
# Author: Isaac Tzab
# License: GNU v3
# Please, feel free to colaborate with this script

# Requirements and assets
# Outer audio capture: https://askubuntu.com/questions/682144/capturing-only-desktop-audio-with-ffmpeg
# pavucontrol to select outer device
# Video capture thread: https://ubuntuforums.org/showthread.php?t=2003738
# Select range area of desktop: https://github.com/naelstrof/slop
# Slop requirement
# sudo apt-get install libxext-dev
# sudo apt-get install libglew-dev
# sudo apt-get install libglm-dev


DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

X=0
Y=0
W=1024
H=768

APP_TITLE="Screen Capture from shell"
DEFAULT_FILENAME="capture"
DEFAULT_FOLDER="$HOME/Videos"

FILES=($(ls -d -- $DEFAULT_FOLDER/$DEFAULT_FILENAME*.mp4 2>/dev/null | sort -t. -k2))
if [ ${#FILES[@]} -eq 0 ]; then
	LASTINDEX=00
else
	LASTINDEX=$(echo "${FILES[-1]}" | sed 's/\.mp4//g' | sed 's/[^0-9]*//g')
	LASTINDEX=$(($LASTINDEX + 1))
fi
FILE="$DEFAULT_FOLDER/$DEFAULT_FILENAME$LASTINDEX.mp4"

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
CHOICE=0

cls() {
	echo -e '\0033\0143'
	clear
}
display_message() {
  dialog \
	--no-collapse \
	--msgbox "$1" 0 0
}

pick_a_file() {
	FILE=$(dialog --stdout --title "List file of directory" --fselect $FILE 14 48)
}

pick_screen() {
	dialog \
		--backtitle $APP_TITLE \
		--title "Area Selection" \
		--clear \
		--msgbox "Now you will be prompted to select the area to capture. \nPress OK and select the area \n\n Your mouse cursor will change to crosshair. After selection will be back to normally." \
		10 50
	read -r X Y W H G ID < <(slop -f "%x %y %w %h %g %i") > 3

	# TODO: check that width and heigh at least be 10 or defined constant
	# [[ $(( $W < 10)) ]] && W=10
	# [[ $(( $H < 10)) ]] && H=10

	[[ $(( $W % 2)) == 1 ]] && W=$(( $W + 1 )) 
	[[ $(( $H % 2)) == 1 ]] && H=$(( $H + 1 ))
}

_main () {
   CHOICE=$(dialog --title "A sample application" \
			--stdout \
			--menu "Please choose an option:" 15 55 5 \
				1 "Capture screen to file" \
				2 "Capture screen to device" \
				3 "Cast screen to device ")

   # retv=$?
   # choice=$(cat $tempfile3)
   # [ $retv -eq 1 -o $retv -eq 255 ] && exit

   case $CHOICE in
		0)
			cls
			echo "Program terminated."
		  ;;
		1)
			pick_a_file
			cls
			pick_screen
			display_message "After this message the screen will being to be capture."
			cls
		 #    echo "$X $Y $W $H $G $I"

			ffmpeg -f x11grab -video_size "$W"x"$H" -framerate 30 -i :0.0+"$X","$Y" -f pulse -i default -c:v libx264 -c:a aac -crf 28 -pix_fmt yuv420p -strict -2  $FILE
		 	# -crf means quality, were less (18) is better

		 	# TODO: send ffmpeg process to background and show a dialog that fires stops when accept (or some mechanism to make ffmpeg transparent)
			# & > /dev/null # this line is to send to background the process
			# display_message "Now recording \n Press OK to stop."
			# kill %1
			;;
		2) 
			display_message "Capture to video device has not yet implemented... please back soon."


			## requirements
			# *ffmpeg
			# *v4l2loopback
			# *V4l-utils

			## Load the module
			# sudo modprobe v4l2loopback exclusive_caps=1

			## Find the dummy device
			# v4l2-ctl --list-devices

			## Start the virtual-webcam (change "/dev/video1" to reflect your system)
			# ffmpeg -f x11grab -r 15 -s 1920x1080 -i :0.0+0,0 -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video1
			_main
			;;
		3) 
			display_message "Cast to device has not yet implemented... please back soon."
			# use castnow to sent to device
			_main
			;;
   esac
}

_main
