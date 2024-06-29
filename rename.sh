#!/bin/bash

clean_text() {
    local text="$1"
    
    # Replace German special characters
    text=$(echo "$text" | sed -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
                               -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
                               -e 's/ß/ss/g')
    
    # Replace spaces with dots (.)
    text=$(echo "$text" | tr ' ' '.')

    # Remove parentheses and replace double dots with single dot
    text=$(echo "$text" | tr -d '()' | sed -e 's/\.\.*/./g')

    echo "$text"
}

rename_file_or_directory() {
    local path="$1"
    local dir=$(dirname "$path")
    local base=$(basename "$path")
    
    if [ -d "$path" ]; then
        # It's a directory, clean and rename without file extension
        local new_base=$(clean_text "$base")
        if [ "$base" != "$new_base" ]; then
            mv "$path" "$dir/$new_base"
            echo "Renamed: $path -> $dir/$new_base"
        fi
    elif [ -f "$path" ]; then
        # It's a file, preserve the file extension
        local extension="${base##*.}"  # Extract extension
        local filename="${base%.*}"    # Extract filename without extension
        local new_base=$(clean_text "$filename")
        
        if [ "$base" != "$new_base.$extension" ]; then
            mv "$path" "$dir/$new_base.$extension"
            echo "Renamed: $path -> $dir/$new_base.$extension"
        fi
    fi
}

process_path() {
    local path="$1"
    
    # Process all files and directories inside this directory first
    for entry in "$path"/*; do
        if [ -d "$entry" ]; then
            # If it's a directory, recursively process it
            process_path "$entry"
        elif [ -f "$entry" ]; then
            # If it's a file, rename it
            rename_file_or_directory "$entry"
            
            # Clean the content of the file (optional step, uncomment if needed)
            # sed -i -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' \
            #        -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g' \
            #        -e 's/ß/ss/g' "$entry"
            
            # Remove all remaining special characters and replace space with dots (.)
            # tr -cd '[:alnum:]' < "$entry" | tr ' ' '.' > "${entry}.tmp" && mv "${entry}.tmp" "$entry"
            
            echo "$entry is renamed and cleaned!"
        fi
    done
    
    # Clean and rename the directory itself after processing its contents
    rename_file_or_directory "$path"
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

# Finally, rename the parent directory itself
rename_file_or_directory "$dir_path"

echo "All data is renamed and cleaned"
