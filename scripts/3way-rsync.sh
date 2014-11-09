#!/bin/sh
# version 20140603
# Backup script using rsync to create multiple snapshots of the source.
# A little known trick of rsync is to be able to run a three-way comparison,
# so to only transfer the diffs but store a full copy in a new directory,
# while comparing and hard linking to the previous snapshot.
# This allows to make many frequent snapshots at minimal network and storage
# impact.
# 
# This version doesn't do any form of rotation: you'll eventually run out of space.
# It is always safe to delete any older directory: a benefit of hard links is that
# deletions are independent, and a restore from any stored timestamp is trivial.
# 
# In practice if you filter accurately (see .rsync-filter to keep the bloat out) and
# store highly mutating stuff like source code elsewhere (e.g. github) you might see
# you don't even need an automated rotation policy to remove older backups.
# KISS: I have a look approximately every couple of months, or when I receive a
# critical space warning to remind me.
#
# To prevent partial copies being considered valid, data is first copied under in-progress
# in-progress is renamed upon rsync success and the symlink to the latest stable is updated
# 
# Copyright (c) 2014 Sanne Grinovero
# Copyright (c) 2014 Emmanuel Bernard
# 
# Permission to use, copy, modify, and/or distribute this software for any purpose with
# or without fee is hereby granted, provided that the above copyright notice and this
# permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
# TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# 


#Following two lines are the only three parameters you're expected to change:
# we receive them from the command line
WHAT_TO_BACKUP=$1
BACKUP_STORAGE=$2
BACKUP_SERVER=$3

ERROR_REPORT="Usage 3way-rsync.sh [source_server:]source_path [destination_server:]absolute_destination_path"
if [ $# -ne 2 ]; then
    echo $ERROR_REPORT
    exit 1;
fi

# find server and path parts
INPUT="$1"
# split string between :
# looks weird but passes ash and bash
SOURCE_SERVER="${INPUT%:*}"
SOURCE_PATH="${INPUT#*:}"
if [ "$SOURCE_SERVER" == "$SOURCE_PATH" ]; then
    SOURCE_SERVER=""
fi
WHAT_TO_BACKUP="$INPUT"
echo "Source $SOURCE_SERVER:$SOURCE_PATH"

INPUT="$2"
DEST_SERVER="${INPUT%:*}"
DEST_PATH="${INPUT#*:}"
if [ "$DEST_SERVER" == "$DEST_PATH" ]; then
    DEST_SERVER=""
fi
echo "Destination $DEST_SERVER:$DEST_PATH"

#Define the format for timestamps
CURRENT_TIMESTAMP=`date +%Y%m%d-%H%M%S`
echo $CURRENT_TIMESTAMP
LINK_TO_LAST=$DEST_PATH/last
ACTUAL_DESTINATION=$DEST_PATH/$CURRENT_TIMESTAMP
TEMP_DESTINATION=$DEST_PATH/in-progress
echo "Creating Backup $CURRENT_TIMESTAMP in $DEST_SERVER:$ACTUAL_DESTINATION"

# If 'last' doesn't exist, create it:
if [[ "$DEST_SERVER" == "" ]]; then
    mkdir -p "$LINK_TO_LAST"
else
    ssh $DEST_SERVER "mkdir -p $LINK_TO_LAST"
fi

# Actually do the backup:
if [[ "$DEST_SERVER" == "" ]]; then
    ACTUAL_DESTINATION_WITH_SERVER="$ACTUAL_DESTINATION"
    TEMP_DESTINATION_WITH_SERVER="$TEMP_DESTINATION"
else
    ACTUAL_DESTINATION_WITH_SERVER="$DEST_SERVER:$ACTUAL_DESTINATION"
    TEMP_DESTINATION_WITH_SERVER="$DEST_SERVER:$TEMP_DESTINATION"
fi

# If temp destination exists, we need to delete the obsolete files
if [[ "$DEST_SERVER" == "" ]]; then
    test -d $TEMP_DESTINATION
else
    ssh $DEST_SERVER "test -d $TEMP_DESTINATION"
fi
if [[ $? -eq 0 ]]; then
    DO_DELETE="--delete"
else
    DO_DELETE=""
fi

rsync $DO_DELETE --archive --verbose --one-file-system --hard-links --human-readable --inplace --numeric-ids -F --link-dest="$LINK_TO_LAST" "$WHAT_TO_BACKUP" "$TEMP_DESTINATION_WITH_SERVER/"
# Memo:
# -F is to apply any ".rsync-filter" file listing exclusion rules. These files are to be stored in the source tree.
# --numeric-ids is essential for backups to try map the actual user an group across systems
# --one-file-system is convenient to have but keep it in mind!
# --inplace is supposed to be a safe performance boost for backups
# --human-readable just related to the output
# --link-dest does the awesome hard linking on the backup storage from previous snapshots saving time and space
# --hard-links examine hard links on the source too: allows recursion of this technique, for example I make snapshots of my Eclipse to have different configurations in parallel
# --delete is not needed as we start from an empty dir all the time
# --compress is hurt low powered CPUs like in the NAS

# upon success
# 1. rename the temp destination
# 2. remove the pointer to the "last" backup as we need to update it:
# 3. create a new pointer to "last" to be used the next time
EC=$?
if [[ $EC -eq 0 || $EC -eq 23 || $EC -eq 24 || $EC -eq 25 ]]; then
    echo "Success"
    if [[ "$DEST_SERVER" == "" ]]; then
        mv $TEMP_DESTINATION $ACTUAL_DESTINATION
        rm -Rf $LINK_TO_LAST
        ln -s $ACTUAL_DESTINATION $LINK_TO_LAST
    else
        ssh $DEST_SERVER "mv $TEMP_DESTINATION $ACTUAL_DESTINATION;rm -Rf $LINK_TO_LAST;ln -s $ACTUAL_DESTINATION $LINK_TO_LAST"
    fi
else
    echo "Failure: keep temporary copy in $TEMP_DESTINATION"
fi
exit $EC
