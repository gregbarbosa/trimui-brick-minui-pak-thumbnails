#!/bin/sh

# Define base paths
ROMS_DIR="/mnt/SDCARD/ROMS"
SAVE_STATE_BASE="/mnt/SDCARD/.userdata/shared/.minui"
RES_DIR="$(dirname "$0")/res"
FLAG_FILE="$(dirname "$0")/savestate_flag"
SYSTEM_BIN="/mnt/SDCARD/.system/tg5040/bin/"

# GraphicsMagick setup
GM="/mnt/SDCARD/System/bin/gm"
export LD_LIBRARY_PATH="/mnt/SDCARD/System/lib:$LD_LIBRARY_PATH"

# Images
IMG_SWITCHING_SAVE_STATE="$RES_DIR/switching-save-state.png"
IMG_SWITCHING_BOX="$RES_DIR/switching-box.png"
IMG_DONE="$RES_DIR/done.png"
IMG_BACKING_UP="$RES_DIR/backingup.png"
IMG_RESTORING="$RES_DIR/restoring.png"
IMG_PROCESSING="$RES_DIR/processing.png"

# Show images
show_image() {
    $SYSTEM_BIN/show.elf "$1" 0.5
}

# Show initial status
if [ -f "$FLAG_FILE" ]; then
    show_image "$IMG_SWITCHING_BOX"
    show_image "$IMG_RESTORING"
else
    show_image "$IMG_SWITCHING_SAVE_STATE"
    show_image "$IMG_BACKING_UP"
fi

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

show_image "$IMG_DONE"
