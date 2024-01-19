#!/bin/sh

WATCHED_DIR="/watch"
LAST_CHECK_DIRS="/tmp/checked_dirs.txt"

process_directory() {
    for folder in $FOLDERS; do
        mkdir -p "$1/$folder"
    done
    
    if [ $DATESTAMP ]; then
        mv "$1" "$(dirname "$1")/$(date +$DATESTAMP)_$(basename "$1")"
    fi
}

is_dir_empty() {
    return $(ls -A "$1" | wc -l)
}

ls -1 $WATCHED_DIR | while read dir_name; do echo "$dir_name" > $LAST_CHECK_DIRS; done

# Основной цикл
while true; do
    for dir in $WATCHED_DIR/*; do
        if [ -d "$dir" ]; then
            dir_name=$(basename "$dir")
            if ! grep -Fxq "$dir_name" $LAST_CHECK_DIRS; then
                if is_dir_empty "$dir"; then
                    echo "New empty found: $dir"
                    process_directory "$dir"
                    echo "$dir_name" >> $LAST_CHECK_DIRS
                fi
            fi
        fi
    done
    sleep 5
done
