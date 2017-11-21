picam
while true; do perl twitter.pl "$(date) at \#Orrholmen."; sleep 3600; done
while true; do convert -resize 25% $HOME/camera/latest.jpg $HOME/camera/latest.png; sleep 3550; done &
