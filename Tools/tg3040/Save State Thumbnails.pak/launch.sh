#!/bin/sh
USERDATA="/mnt/SDCARD/.userdata/shared/.minui"
ROMS="/mnt/SDCARD/Roms/"
SCRIPT_DIR="$(dirname "$0")"
RES_PATH="$SCRIPT_DIR/res"
LOG_FILE="$SCRIPT_DIR/thumbnail_convert.log"
UPDATING_THUMBNAILS="$RES_PATH/enable.png"
UPDATED_THUMBNAILS="$RES_PATH/disable.png"

# Set GraphicsMagick environment
GM_PATH="/mnt/SDCARD/System/bin/gm"
LD_LIBRARY_PATH="/mnt/SDCARD/System/lib"
export LD_LIBRARY_PATH

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Clear previous log file
echo "Starting new conversion session" >"$LOG_FILE"
log_message "Script started"

# Check if source directory exists
if [ ! -d "$USERDATA/GBA/" ]; then
    log_message "ERROR: Source directory $USERDATA/GBA/ not found"
    exit 1
fi

# Check if destination directory exists
if [ ! -d "$ROMS/3) Game Boy Advance (GBA)/.res" ]; then
    log_message "ERROR: Destination directory $ROMS/3) Game Boy Advance (GBA)/.res not found"
    exit 1
fi

# Counter for processed files
processed=0
errors=0

for file in "$USERDATA/GBA/"*.zip.0.bmp; do
    # Check if no files were found
    if [ ! -f "$file" ]; then
        log_message "ERROR: No .bmp files found in $USERDATA/GBA/"
        exit 1
    fi

    basename=$(basename "$file")
    newname="${basename%.0.bmp}.png"
    destination="$ROMS/3) Game Boy Advance (GBA)/.res/$newname"

    log_message "Processing: $basename"

    if $GM_PATH convert "$file" \
        -resize 420x\! \
        -border 10 \
        -bordercolor 'white' \
        "$destination"; then
        log_message "SUCCESS: Converted and styled $basename to $newname"
        processed=$((processed + 1))
    else
        log_message "ERROR: Failed to convert $basename"
        errors=$((errors + 1))
    fi
done

# Log summary
log_message "Conversion complete. Processed: $processed files, Errors: $errors"
log_message "Script finished"

# Display final counts in log
echo "----------------------------------------" >>"$LOG_FILE"
echo "Final Summary" >>"$LOG_FILE"
echo "Files processed: $processed" >>"$LOG_FILE"
echo "Errors encountered: $errors" >>"$LOG_FILE"
echo "----------------------------------------" >>"$LOG_FILE"
