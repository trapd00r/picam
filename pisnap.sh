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

# make sure the dir where the images are about to be saved exists.
# picam expects this.
mkdir -p $SAVE_DIR_LOCAL

while true; do
  # give the image a meaningful name, template looks like this:
  # 2017-11-19_024431.jpg
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
