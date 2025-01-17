# ProjectPacker

A bash script that creates a comprehensive documentation of your project's structure and contents, specifically designed for easy consumption by AI models for analysis and code review and development purposes.

## Features

- Generates a structured documentation of your project
- Creates a directory tree representation
- Includes file contents with proper formatting
- Excludes binary files and other specified patterns
- Customizable exclusion patterns for both directories and file types
- Estimates total tokens for AI processing

## Prerequisites

### Tree Command Installation

The script requires the `tree` command to be installed on your system.

#### For macOS:
Using Homebrew:
```bash
brew install tree
```

#### For Linux:
For Debian/Ubuntu-based systems:
```bash
sudo apt-get install tree
```

For Red Hat/Fedora-based systems:
```bash
sudo yum install tree
```

#### For Windows:
If using Windows Subsystem for Linux (WSL), follow the Linux instructions above.
If using Git Bash or similar, the `tree` command should be included by default.

### Verifying Installation
To verify that tree is installed correctly:
```bash
tree --version
```

## Installation

### Method 1: User-specific Installation (Recommended)

1. Create a bin directory in your home folder (if it doesn't exist):
```bash
mkdir -p ~/bin
```

2. Copy the script to the bin directory:
```bash
cp path/to/project_packer.sh ~/bin/projectpacker
```

3. Make the script executable:
```bash
chmod +x ~/bin/projectpacker
```

4. Add the bin directory to your PATH:

For Bash (edit `~/.bash_profile` or `~/.bashrc`):
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
```

For Zsh (edit `~/.zshrc`):
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
```

5. Reload your shell configuration:

For Bash:
```bash
source ~/.bash_profile
```

For Zsh:
```bash
source ~/.zshrc
```

### Method 2: System-wide Installation

```bash
# Copy the script
sudo cp path/to/project_packer.sh /usr/local/bin/projectpacker

# Make it executable
sudo chmod +x /usr/local/bin/projectpacker
```

## Usage

```bash
# Show help
projectpacker -h

# Use all defaults (current directory)
projectpacker

# Specify directory only
projectpacker -d /path/to/project

# Specify directory and exclusion pattern
projectpacker -d /path/to/project -e "node_modules|dist"

# Specify custom output filename
projectpacker -d /path/to/project -o custom_output.read

# Specify additional file extensions to exclude
projectpacker -d /path/to/project -fe ".custom|.test"

# Use all options
projectpacker -d /path/to/project -e "node_modules|dist" -o custom_output.read -fe ".custom|.test"
```

## Options

- `-d <directory>`: Directory path to analyze (default: current directory)
- `-e <pattern>`: Exclude pattern for tree command (default: 'node_modules|dist|cdk.out')
- `-o <filename>`: Output filename (default: directory_name_DATETIME.read)
- `-fe <extensions>`: Additional file extensions to exclude (will be combined with default binary/media file extensions)
- `-h`: Show help message

## Default Exclusions

### Directory Exclusions
By default, the following directories are excluded:
- node_modules
- dist
- cdk.out

### File Extension Exclusions
The script automatically excludes common binary, media, and temporary files including:
- Common image formats (.png, .jpg, .gif, etc.)
- Document formats (.pdf, .doc, .docx, etc.)
- Audio/video formats (.mp3, .mp4, etc.)
- Archive formats (.zip, .rar, etc.)
- Binary files (.exe, .dll, etc.)
- Database files (.db, .sqlite, etc.)
- And many more

## Output Format

The generated file includes:
1. A summary section
2. Repository information
3. Directory structure
4. File contents with clear separators
5. Statistical information (total files, characters, estimated tokens)

## Uninstallation

To remove the script:

If installed in ~/bin:
```bash
rm ~/bin/projectpacker
```

If installed system-wide:
```bash
sudo rm /usr/local/bin/projectpacker
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

[MIT License](LICENSE)
