#!/bin/bash

ROOT_DIR="."
README_FILE="$ROOT_DIR/readme.md"

echo "# Folder List" > "$README_FILE"
echo >> "$README_FILE"
echo "| Folder Name | Description |" >> "$README_FILE"
echo "| ----------- | ----------- |" >> "$README_FILE"

for dir in "$ROOT_DIR"/*/; do
    folder_name=$(basename "$dir")
    description="This folder contains files and resources related to $folder_name."
    echo "| [$folder_name]($folder_name) | $description |" >> "$README_FILE"
done

