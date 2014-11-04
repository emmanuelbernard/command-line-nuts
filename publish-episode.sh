#!/bin/bash
#20140508

#TODO
# - create short URL
# - show length in minutes
# - clean unused files afterwards

if [[ $# -ne 1 ]]; then
    echo "Usage publish-episode.sh <episode number>"
    exit 1;
fi

cd episodes/$1

COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_NONE="\033[0m"

SHOWNOTES="ep-$1.md"
SHOWNOTES_TEMP="ep-temp"
YEAR=$(date +'%Y')
DATE_TODAY=$(date +'%Y-%m-%d')
DATE_TODAY_URL=$(date +'%Y/%m/%d')
TDTG=$(date +'%Y-%m-%dT%H:%M:%S')
SITE=~/Sites/lescastcodeurs.com

cp $SHOWNOTES $SHOWNOTES_TEMP
sed -i '' '1,7d' $SHOWNOTES_TEMP
sed -i '' 's/"/\\\"/g' $SHOWNOTES_TEMP
TITLE=$(sed -n 2p $SHOWNOTES|sed 's/^title: \(.*\)$/\1/')
lyrics=`cat $SHOWNOTES_TEMP`

echo ";FFMETADATA1" >> metadata.txt
echo "album=Les Cast Codeurs Podcast" >> metadata.txt
echo "artist=Emmanuel Bernard, Guillaume Laforge, Vincent Massol, Antonio Goncalves, Arnaud Heritier" >> metadata.txt
echo "genre=Podcast" >> metadata.txt
echo "date=$YEAR" >> metadata.txt
echo "year=$YEAR" >> metadata.txt
echo "title=$TITLE" >> metadata.txt
echo "TDTG=$TDTG" >> metadata.txt

SOURCE_ROOT="ep-$1-final"
MP3="LesCastCodeurs-Episode-$1.mp3"

echo -e "$COLOR_YELLOW Compress episode (y/n)$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    echo "##########################################"
    echo "Compress episode to flac and MP3"
    ffmpeg -i $SOURCE_ROOT.aiff -i metadata.txt -map 0 -map_metadata 1 $SOURCE_ROOT.flac
    ffmpeg -i $SOURCE_ROOT.aiff -i metadata.txt -map 0 -ac 1 -ab 96k -map_metadata 1 $MP3
    rm metadata.txt

    echo "##########################################"
    echo "Update MP3's metadata"
    eyeD3 --remove-all $MP3

    eyeD3 --artist="Emmanuel Bernard, Guillaume Laforge, Vincent Massol, Antonio Goncalves, Arnaud Heritier" \
         --add-image ../../logo-lescastcodeurs-1400px-white.png:FRONT_COVER \
         --album="Les Cast Codeurs Podcast" \
         --title="$TITLE" \
         --release-year=$YEAR \
         --release-date="$YEAR" \
         --recording-date="$YEAR" \
         --add-lyrics $SHOWNOTES_TEMP:"":"fre" \
         --genre "Podcast" \
        $MP3

    rm ep-temp
fi

echo -e "$COLOR_YELLOW Upload to Libsyn (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
echo "##########################################"
echo "Upload file to Libsyn"
ftp -i ftp-server.libsyn.com <<ENDOFCOMMANDS
cd lescastcodeurs
cd dropbox
put $MP3
quit
ENDOFCOMMANDS
fi

echo -e "$COLOR_YELLOW Create site entry (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    echo "##########################################"
    echo "Create site entry"
    FILESIZE=$(stat -f %z $MP3)
    sed -i '' "/^mp3_length: /s/^mp3_length:.*$/mp3_length: $FILESIZE/" ep-$1.md
    CLEANED_TITLE=$(echo $TITLE | sed -e 's/[\.\,]//g' | sed -e 's/[-!\:\/] //g' | sed -e 's/[ !:\/]/\-/g' | sed -e 's/[ -]*$//g' | tr [:upper:] [:lower:] | sed -e 's/[èéêë]/e/g' -e 's/[àáâãäå]/a/g')
    cp ep-$1.md $SITE/$DATE_TODAY-$CLEANED_TITLE.md
fi

echo "##########################################"
echo "open libsyn and create entry"
echo $TITLE
open -a Marked ep-$1.md


FilesToDelete=( )
echo -e "$COLOR_YELLOW Compress source files (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    echo "##########################################"
    echo "Compress source files"

    cd raw
    shopt -s nullglob
    for file in "."/*.{aiff,wav}
    do
        file_wo_extension="${file%.*}"
        ffmpeg -i $file $file_wo_extension.flac
        if [[ $? -eq 0 ]]; then
            FilesToDelete=("${FilesToDelete[@]}" "$file")
        else
            echo "[ERROR] Failed to compress $file"
        fi
    done
    cd ..
fi

echo "##########################################"
echo "Manual action"

echo -e "$COLOR_REDOpen Libsyn and add MP3$COLOR_NONE"
echo $TITLE

echo ""

echo -e "$COLOR_YELLOW Push to git (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then

    CURRENT_DIR=$(pwd)
    cd $SITE
    git add $DATE_TODAY-$CLEANED_TITLE.md

    echo "##########################################"
    echo "Commit and push site"
    git commit -m "Publish episode $1: $TITLE"
    git push upstream master
    cd $CURRENT_DIR
fi

echo -e "$COLOR_YELLOW Push site in production (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    CURRENT_DIR=$(pwd)
    cd $SITE
    echo "##########################################"
    echo "Push site in production"
    [ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm"
    . .rvmrc
    rake clean publish
    #rsync -avz --delete --filter="- /video/" --filter="- /cgi-bin/" _site/ emmanuelbernard:public_html/lescastcodeurs
    cd $CURRENT_DIR
fi

echo "URL: http://lescastcodeurs.com/$DATE_TODAY_URL/$CLEANED_TITLE/"
echo "MP3: http://traffic.libsyn.com/lescastcodeurs/LesCastCodeurs-Episode-$1.mp3"
ffmpeg -i $SOURCE_ROOT.flac 2>&1 | grep Duration


echo -e "$COLOR_YELLOW Delete raw resources (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    echo "##########################################"
    echo "Delete raw resources"

    for ftd in "${FilesToDelete[@]}"
    do
        rm raw/$ftd
    done
    shopt -s nullglob
    for file in "."/*.{aiff,wav}
    do
        rm $file
    done
fi
echo -e "$COLOR_YELLOW Archive to Synology (y/n)?$COLOR_NONE"
read -p "" -n1 -s
if [[ "$REPLY" == "y" ]]; then
    echo "##########################################"
    echo "Archive to synology"
    rsync -avz ../$1/ dsm-local:/volume1/Music/current/LesCastCodeurs/episodes/$1
fi
