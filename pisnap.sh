#!/bin/sh
# pisnap
# take photo, scp it to server and delete it from the pi to save space.

# set up:
#   credentials for auto-scp'ing
#   photo save dir
#   sleep time

           USER='scp1'
           HOST='laleh'
 SAVE_DIR_LOCAL="${HOME}/camera"
SAVE_DIR_REMOTE="_picam"
          SLEEP=1730

while true; do
  FILE=$(date +"%Y-%m-%d_%H%M%S").jpg

  printf -- "----------\n"
  raspistill -vf -hf -n -o $FILE && printf "$FILE written\n"
  scp $FILE ${USER}@${HOST}:${SAVE_DIR_REMOTE} && cp -v $FILE $SAVE_DIR_LOCAL/latest.jpg && rm -v $FILE
  # resize the picture for twitter.
  cd $SAVE_DIR_LOCAL
  convert -resize 25% latest.jpg latest.png
  printf -- "----------\n"
  sleep $SLEEP
done
