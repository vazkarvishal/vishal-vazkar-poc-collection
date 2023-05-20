#!/bin/bash

ROOT_DIR="."
README_FILE="$ROOT_DIR/readme.md"

echo "# Folder List" > "$README_FILE"
echo >> "$README_FILE"

for dir in "$ROOT_DIR"/*/; do
    folder_name=$(basename "$dir")
    echo "- [$folder_name]($folder_name)" >> "$README_FILE"
done

