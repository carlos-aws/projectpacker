#!/bin/bash
#
# Show help
# ./project_packer.sh -h

# Use all defaults (current directory)
# ./project_packer.sh

# Specify directory only
# ./project_packer.sh -d /path/to/project

# Specify directory and exclusion pattern
# ./project_packer.sh -d /path/to/project -e "node_modules|dist"

# Specify custom output filename
# ./project_packer.sh -d /path/to/project -o custom_output

# Use all options
# ./project_packer.sh -d /path/to/project -e "node_modules|dist" -o custom_output

# Function to display help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -d <directory>    Directory path to analyze (default: current directory)"
    echo "  -e <pattern>      Exclude pattern for tree command (default: 'node_modules|dist|cdk.out')"
    echo "  -o <filename>     Output filename (default: directory_name_DATETIME.projectpacker.txt)"
    echo "  -h               Show this help message"
    echo "  -fe <extensions>  Additional file extensions to exclude (will be combined with default binary/media file extensions)"
    echo
    echo "Examples:"
    echo "  $0 -d /path/to/project"
    echo "  $0 -d /path/to/project -e 'node_modules|dist'"
    echo "  $0 -d /path/to/project -o custom_output"
    echo "  $0 -d /path/to/project -fe '.custom|.test'"
}

# Default values
DIR_PATH="$(pwd)"
EXCLUDE_PATTERN="node_modules|dist|cdk.out"
OUTPUT_NAME=""

# Define the base file extensions to exclude
BASE_FILE_EXTENSIONS=".env|.log|.tmp|.pdf|.png|.jpeg|.jpg|.gif|.bmp|.tiff|.raw|.cr2|.nef|.arw|.dng|.psd|.ai|.eps|.mov|.mp4|.avi|.mkv|.wmv|.flv|.webm|.m4v|.3gp|.mpeg|.mpg|.mp3|.wav|.aac|.wma|.ogg|.flac|.m4a|.mid|.midi|.doc|.docx|.ppt|.pptx|.xls|.xlsx|.zip|.rar|.7z|.tar.gz|.gz|.iso|.dmg|.exe|.dll|.app|.deb|.rpm|.msi|.bin|.dat|.db|.sqlite|.mdb|.pdb|.obj|.lib|.so|.dylib|.class|.jar|.pyc|.ico|.cur|.heic|.heif|.webp|.svg|.xcf|.sketch|.fig|.dwg|.dxf|.blend|.fbx|.3ds|.max|.mb|.ma|.swf"

# Initialize FILE_EXTENSIONS_EXCLUDE with the base extensions
FILE_EXTENSIONS_EXCLUDE="$BASE_FILE_EXTENSIONS"

# Parse command line arguments
while getopts "d:e:o:fe:h" opt; do
    case $opt in
        d)
            DIR_PATH="$OPTARG"
            ;;
        e)
            EXCLUDE_PATTERN="$OPTARG"
            ;;
        o)
            OUTPUT_NAME="$OPTARG"
            ;;
        fe)
            # Append user-provided extensions to the base extensions
            FILE_EXTENSIONS_EXCLUDE="$OPTARG|$BASE_FILE_EXTENSIONS"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            exit 1
            ;;
    esac
done

# Check if directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory does not exist: $DIR_PATH"
    exit 1
fi

# Change to the specified directory
cd "$DIR_PATH" || exit 1

# Get current date-time for the filename
DATETIME=$(date +"%Y%m%d_%H%M%S")

# Set output filename as current folder name if not provided
if [ -z "$OUTPUT_NAME" ]; then
    BASE_DIR=$(basename "$DIR_PATH")
    OUTPUT_FILE="${BASE_DIR}_${DATETIME}.projectpacker.txt"
else
    OUTPUT_FILE="${OUTPUT_NAME}_${DATETIME}.projectpacker.txt"
fi

# Create or clear the output file
> "$OUTPUT_FILE"

# Function to write section header
write_header() {
    echo "$1" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

prompt_additional_info() {
    echo "Would you like to add additional information about this repository? (y/n)"
    read -r ADD_INFO
    
    if [[ "$ADD_INFO" =~ ^[Yy]$ ]]; then
        echo "Please enter additional information about the repository (purpose, high-level description, etc.)"
        echo "Press Ctrl+D when finished (or Ctrl+D twice if using a terminal):"
        ADDITIONAL_INFO=$(cat)
    else
        ADDITIONAL_INFO="No additional information provided about this repository. Below is its content."
    fi
}

write_header "================================================================
Project Packed File Summary
================================================================

Purpose:
--------
This Project Packed file contains a packed representation of an entire project or repository's contents.

Analyze each file and make sure you understand how they interconnect between them and each of its components and functions. When referencing any file, use the file path to distinguish between different files in the repository.

File Format:
------------
The content is organized as follows:
1. This summary section
2. Project/repository additional information
3. Directory structure
4. Multiple file entries, each consisting of:
  a. A separator line (================)
  b. The file path (File: path/to/file)
  c. Another separator line (================)
  d. The full contents of the file

Notes:
------
- Some files have been excluded based on exclusion rules when generating this packed file.
- Binary files are not included in this packed representation. Please refer to
  the Repository Structure section for a complete list of file paths, including
  binary files.

Additional Info:
----------------"

# Prompt for additional information
prompt_additional_info

# Write the additional information
echo "$ADDITIONAL_INFO" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

write_header "================================================================
Directory Structure
================================================================"

# Get the base directory name
BASE_DIR=$(basename "$DIR_PATH")
echo "$BASE_DIR" >> "$OUTPUT_FILE"

# Perform tree command and save to output file
tree -f -I "$EXCLUDE_PATTERN" >> "$OUTPUT_FILE"

# Write the files content header
write_header "================================================================
Files
================================================================
"

write_header "Below is the content of each file in the project:"

# Create a temporary file to store the list of files
TEMP_FILE=$(mktemp)

# Get list of files from tree command (excluding directories)
tree -f -I "$EXCLUDE_PATTERN" --noreport -i | grep -v "^.$" | grep -v "^..$" > "$TEMP_FILE"

# Add pause before reading files
echo "Directory tree has been written to $OUTPUT_FILE"
echo "Press Enter to continue with reading file contents..."
read -r

TOTAL_FILES=0

# Read each line from the temp file
while IFS= read -r file; do
    # Skip if it's a directory
    if [ -f "$file" ]; then
        # Skip if file ends with package-lock.json
        if [[ "$file" != *"package-lock.json" ]]; then
            # Check if the file matches any of the excluded patterns
            if [[ ! "$file" =~ \.projectpacker.txt$ && ! "$file" =~ ($FILE_EXTENSIONS_EXCLUDE)$ ]]; then
                echo "Processing: $file"
                echo "" >> "$OUTPUT_FILE"
                echo "================" >> "$OUTPUT_FILE"
                echo "File: $file" >> "$OUTPUT_FILE"
                echo "================" >> "$OUTPUT_FILE"
                cat "$file" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                TOTAL_FILES=$((TOTAL_FILES+1))
            fi
        fi
    fi
done < "$TEMP_FILE"

# Clean up
rm "$TEMP_FILE"

# Get total number of characters
TOTAL_CHARS=$(cat "$OUTPUT_FILE" | wc -m)

# Estimate total number of tokens (assuming 1 token per 4 chars)
TOTAL_TOKENS=$((TOTAL_CHARS / 4))

# Print summary
echo "
================================================================
📊 Summary
================================================================
Total Files Processed: $TOTAL_FILES
Total Chars: $TOTAL_CHARS
Total Tokens: $TOTAL_TOKENS
"

echo "Project content has been written to $OUTPUT_FILE"
