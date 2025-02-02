A MinUI tool pak for TrimUI Brick that allows switching between traditional box art and save state thumbnails for your ROM collection.

## Features

- Toggle between box art and save state thumbnails
- Automatic backup of original box art
- Support for all ROM systems
- Non-destructive operation (original box art is preserved)

## Requirements

- TrimUI Brick running MinUI-20250126-0
  - This version of MinUI combines the TrimUI Smart Pro and TrimUI Brick folders

## Installation

1. Download the latest `Thumbnails.zip` release from GitHub
2. Extract the .zip file
3. Move the `Thumbnails.pak` folder into your Brick's SD card at `/mnt/SDCARD/Tools/tg5040` folder
4. Launch Thumbnails under MinUI's Tools section

## Usage

Simply launch the pak to toggle between:

- Box art mode (default)
- Save state thumbnail mode

The current mode is preserved between reboots using a flag file.

## How it works

On first launch Thumbnails will backup your existing images, then set save state images as your ROM's box art image. If you launch it again, it'll do the opposite and restore your original images, and delete the save state images being used as your ROM's box art.

## Roadmap

- [x] Save state images: move original images to `/boxart`
- [x] Box art images: remove save state thumbnails and move images back from `/boxart`
- [x] Iterate through all ROM folder saves state images
- [ ] Include update option for new save state thumbnails
  - [ ] Automate updating thumbnails
- [ ] MinUI-like interface
- [ ] User options??

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
