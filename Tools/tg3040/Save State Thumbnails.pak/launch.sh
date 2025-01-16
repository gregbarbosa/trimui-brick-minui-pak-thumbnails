#!/bin/sh
USERDATA="/mnt/SDCARD/.userdata/shared/.minui"
ROMS="/mnt/SDCARD/Roms/"
SCRIPT_DIR="$(dirname "$0")"
RES_PATH="$SCRIPT_DIR/res"
LOG_FILE="$SCRIPT_DIR/thumbnail_convert.log"

# Status images
IMG_BACKINGUP="$RES_PATH/backingup.png"
IMG_COPYING="$RES_PATH/copying.png"
IMG_RESTORING="$RES_PATH/restoring.png"
IMG_DONE="$RES_PATH/done.png"

# Function to show images
show_image() {
    show.elf "$1"
}

# Set GraphicsMagick environment
GM_PATH="/mnt/SDCARD/System/bin/gm"
LD_LIBRARY_PATH="/mnt/SDCARD/System/lib"
export LD_LIBRARY_PATH

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Function to find matching destination directory
find_dest_dir() {
    local system_code="$1"
    local dest_dir=""

    # Loop through all directories in ROMS
    for dir in "$ROMS"*; do
        if [ -d "$dir" ] && echo "$dir" | grep -q "$system_code"; then
            dest_dir="$dir"
            break
        fi
    done

    echo "$dest_dir"
}

# Function to backup existing images
backup_existing_images() {
    local res_dir="$1"
    local source_dir="$2" # Add source directory parameter
    local backed_up=0

    # Create boxart directory if it doesn't exist
    local boxart_dir="$res_dir/boxart"
    mkdir -p "$boxart_dir"

    # Check if directory exists and contains PNG files
    if [ -d "$res_dir" ]; then
        for img in "$res_dir"/*.png; do
            if [ -f "$img" ] && [ "$(dirname "$img")" != "$boxart_dir" ]; then
                # Get the base name of the boxart
                local boxart_base="${img%.png}"
                # Construct the corresponding save state name
                local save_state_name="${boxart_base}.0.bmp"
                save_state_name=$(basename "$save_state_name")

                # Only move if there's a corresponding save state
                if [ -f "$source_dir/$save_state_name" ]; then
                    mv "$img" "$boxart_dir/"
                    backed_up=$((backed_up + 1))
                    log_message "Moved to boxart: $(basename "$img")"
                else
                    log_message "Keeping boxart: $(basename "$img") (no save state found)"
                fi
            fi
        done
    fi

    echo $backed_up
}

# Clear previous log file
echo "Starting new conversion session" >"$LOG_FILE"
log_message "Script started"

# Counter for processed files
total_processed=0
total_errors=0
total_backups=0

# Show initial backup message
show_image "$IMG_BACKINGUP"

# Process each directory in .minui
for source_dir in "$USERDATA"/*; do
    if [ ! -d "$source_dir" ]; then
        continue
    fi

    # Get system code (GBA, GBC, etc.)
    system_code=$(basename "$source_dir")
    log_message "Processing system: $system_code"

    # Find matching destination directory
    dest_dir=$(find_dest_dir "$system_code")

    if [ -z "$dest_dir" ]; then
        log_message "ERROR: No matching destination directory found for $system_code"
        continue
    fi

    # Ensure .res directory exists
    mkdir -p "$dest_dir/.res"

    # Backup existing images
    log_message "Checking for existing images in $dest_dir/.res"
    backed_up=$(backup_existing_images "$dest_dir/.res" "$source_dir")
    total_backups=$((total_backups + backed_up))
    if [ $backed_up -gt 0 ]; then
        log_message "Moved $backed_up existing images to boxart folder for $system_code"
    fi

    # Show copying message before processing files
    show_image "$IMG_COPYING"

    # Process files in current system directory
    processed=0
    errors=0

    for file in "$source_dir"/*.0.bmp; do
        # Check if no files were found
        if [ ! -f "$file" ]; then
            log_message "No .bmp files found in $source_dir"
            continue
        fi

        basename=$(basename "$file")
        newname="${basename%.0.bmp}.png"
        destination="$dest_dir/.res/$newname"

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

    log_message "Completed $system_code - Processed: $processed, Errors: $errors"
    total_processed=$((total_processed + processed))
    total_errors=$((total_errors + errors))
done

# Log final summary
sleep 2
show_image "$IMG_DONE"
log_message "All systems processed. Total converted: $total_processed, Total errors: $total_errors, Total backups: $total_backups"
log_message "Script finished"

# Display final counts in log
echo "----------------------------------------" >>"$LOG_FILE"
echo "Final Summary" >>"$LOG_FILE"
echo "Total files processed: $total_processed" >>"$LOG_FILE"
echo "Total errors encountered: $total_errors" >>"$LOG_FILE"
echo "Total files backed up: $total_backups" >>"$LOG_FILE"
echo "----------------------------------------" >>"$LOG_FILE"
