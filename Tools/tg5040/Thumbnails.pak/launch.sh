#!/bin/sh

# Define paths
THMB_DIR="/mnt/SDCARD/ROMS/1) Game Boy Advance (GBA)/.res"
SAVE_STATE_DIR="/mnt/SDCARD/.userdata/shared/.minui/GBA"
BACKUP_DIR="$THMB_DIR/backup"
FLAG_FILE="$(dirname "$0")/savestate_flag"

# GraphicsMagick
GM="/mnt/SDCARD/System/bin/gm"
export LD_LIBRARY_PATH="/mnt/SDCARD/System/lib:$LD_LIBRARY_PATH"

# Check if flag exists
if [ -f "$FLAG_FILE" ]; then
    # Restore box art
    echo "Restoring box art..."
    rm -f "$THMB_DIR"/*.png
    echo "Current save state images removed."

    if [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        mv "$BACKUP_DIR"/* "$THMB_DIR"/
        rm -rf "$BACKUP_DIR" &&
            echo "Box art restored and backup directory removed."
    else
        echo "No box art files to restore."
    fi
    rm "$FLAG_FILE"
else
    # Backup box art
    echo "Backing up box art..."
    if [ -n "$(ls -A "$THMB_DIR" 2>/dev/null)" ]; then
        mkdir -p "$BACKUP_DIR"
        find "$THMB_DIR" -mindepth 1 -maxdepth 1 -not -path "$BACKUP_DIR" -exec cp {} "$BACKUP_DIR/" \;
        echo "Box art backed up successfully."
    else
        echo "No box art files to backup."
    fi

    # Copy and rename save state thumbnails
    echo "Copying save state thumbnails..."
    if [ -n "$(ls -A "$SAVE_STATE_DIR" 2>/dev/null)" ]; then
        for file in "$SAVE_STATE_DIR"/*.bmp; do
            # Extract the base name (e.g., Tetris.gb.0.bmp -> Tetris.gb)
            base_name=$(printf "%q" "$(basename "$file" | sed 's/\.[0-9]\+\.bmp$//')")
            # Use GraphicsMagick to process and save the image
            if
                "$GM" convert "$file" \
                    -size 420x\! \
                    -resize 420x\! \
                    -background white \
                    -border 10 \
                    -bordercolor 'rgb(255,255,255)' \
                    "${THMB_DIR}/${base_name}.png"
            then
                echo "> Processed: $file"
            else
                echo "Processing failed for $file."
                continue
            fi
        done
    else
        echo "No save state thumbnails to copy."
    fi

    # Create flag file
    echo "Creating flag file..."
    touch "$FLAG_FILE"
fi

echo "Toggle complete."
