#!/bin/bash

clean_text() {
    local text="$1"
    
    # Replace German special characters
    text=$(echo "$text" | sed -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
                               -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
                               -e 's/ß/ss/g')
    
    # Remove all remaining special characters and replace space with periods (dot)
    text=$(echo "$text" | tr -cd '[:alnum:]' | tr ' ' '.')

    echo "$text"
}

rename_file_or_directory() {
    local path="$1"
    local dir=$(dirname "$path")
    local base=$(basename "$path")
    local extension="${base##*.}"  # Extract extension, if any
    local filename="${base%.*}"    # Extract filename without extension
    local new_base=$(clean_text "$filename")
    
    if [ -n "$extension" ]; then
        new_base="$new_base.$extension"
    fi
    
    # Rename the file or directory if the name has changed
    if [ "$base" != "$new_base" ]; then
        mv "$path" "$dir/$new_base"
        echo "Renamed: $path -> $dir/$new_base"
    fi
}

process_path() {
    local path="$1"
    
    if [ -f "$path" ]; then
        # If it's a file, clean and rename it
        rename_file_or_directory "$path"
        
        # Clean the content of the file (optional step, uncomment if needed)
        # sed -i -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
        #        -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
        #        -e 's/ß/ss/g' "$path"
        
        # Remove all remaining special characters and replace space with periods (dot)
        # tr -cd '[:alnum:]' < "$path" | tr ' ' '.' > "${path}.tmp" && mv "${path}.tmp" "$path"
        
        echo "$path is renamed and cleaned!"
    elif [ -d "$path" ]; then
        # If it's a directory, clean and rename it
        rename_file_or_directory "$path"
        
        # Recursively process all files and directories inside this directory
        for entry in "$path"/*; do
            process_path "$entry"
        done
    fi
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

# Process the provided directory and its subdirectories
process_path "$dir_path"

echo "All data is renamed and cleaned"
