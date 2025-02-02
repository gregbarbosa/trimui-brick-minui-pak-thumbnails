#!/bin/sh

# Define base paths
ROMS_DIR="/mnt/SDCARD/ROMS"
SAVE_STATE_BASE="/mnt/SDCARD/.userdata/shared/.minui"
FLAG_FILE="$(dirname "$0")/savestate_flag"

# GraphicsMagick setup
GM="/mnt/SDCARD/System/bin/gm"
export LD_LIBRARY_PATH="/mnt/SDCARD/System/lib:$LD_LIBRARY_PATH"

# Process each system
for save_state_dir in "$SAVE_STATE_BASE"/*/; do
    [ ! -d "$save_state_dir" ] && continue

    system_tag=$(basename "$save_state_dir")

    # Find matching ROM directory
    rom_dir=""
    for dir in "$ROMS_DIR"/*/; do
        if [ -d "$dir" ] && echo "$dir" | grep -q "(${system_tag})"; then
            rom_dir="$dir"
            break
        fi
    done
    [ -z "$rom_dir" ] && continue

    THMB_DIR="${rom_dir}.res"
    BACKUP_DIR="$THMB_DIR/backup"

    echo "Processing $system_tag..."

    if [ -f "$FLAG_FILE" ]; then
        # Restore box art
        rm -f "$THMB_DIR"/*.png
        if [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
            mv "$BACKUP_DIR"/* "$THMB_DIR"/
            rm -rf "$BACKUP_DIR" &&
                echo "> Box art restored"
        fi
    else
        # Backup box art and convert save states
        if [ -n "$(ls -A "$THMB_DIR" 2>/dev/null)" ]; then
            mkdir -p "$BACKUP_DIR"
            find "$THMB_DIR" -mindepth 1 -maxdepth 1 -not -path "$BACKUP_DIR" -exec cp {} "$BACKUP_DIR/" \;
            echo "Box art backed up"
        fi

        # Process only slot 0 save state thumbnails
        for file in "$save_state_dir"/*.0.bmp; do
            [ ! -f "$file" ] && continue

            base_name="$(basename "${file}")"
            base_name="$(echo "${base_name}" | sed 's/\.0\.bmp$//')"

            if [ -n "$base_name" ]; then
                if "$GM" convert "$file" \
                    -size 420x\! \
                    -resize 420x\! \
                    -background white \
                    -border 10 \
                    -bordercolor 'rgb(255,255,255)' \
                    "${THMB_DIR}/${base_name}.png"; then
                    echo "> Converted: $(basename "$file")"
                fi
            else
                echo "Warning: Could not process filename: $file"
            fi
        done
    fi
done

# Toggle flag file
if [ -f "$FLAG_FILE" ]; then
    rm "$FLAG_FILE"
    echo "Switched to box art mode"
else
    touch "$FLAG_FILE"
    echo "Switched to save state thumbnail mode"
fi
