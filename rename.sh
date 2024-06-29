#!/bin/bash

clean_text() {
    local text="$1"
    
    # Replace German special characters
    text=$(echo "$text" | sed -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
                               -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
                               -e 's/ß/ss/g')
    
    # Remove all remaining special characters and replace space with periods (dot)
    text=$(echo "$text" | tr -cd '[:alnum:]\n' | tr ' ' '.')
    
    echo "$text"
}

process_file() {
    local file="$1"
    local dir=$(dirname "$file")
    local base=$(basename "$file")
    local new_base=$(clean_text "$base")
    
    # Clean the content of the file
    sed -i -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
           -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
           -e 's/ß/ss/g' "$file"
    
    tr -cd '[:alnum:]\n | tr ' ' '.'' < "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    
    # Rename the file if the name has changed
    if [ "$base" != "$new_base" ]; then
        mv "$file" "$dir/$new_base"
        echo "Renamed: $file -> $dir/$new_base"
    fi
    
    echo "$file is renamed!"
}

# Check if a directory is provided
if [ $# -eq 0 ]; then
    echo "Please provide a directory path."
    exit 1
fi

dir_path="$1"

# Check if the provided path is a directory
if [ ! -d "$dir_path" ]; then
    echo "The provided path is not a directory."
    exit 1
fi

# Process all files in the directory and subdirectories
find "$dir_path" -type f | while read file; do
    process_file "$file"
done

echo "All data is renamed and cleaned"
