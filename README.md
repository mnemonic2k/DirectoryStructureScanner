# Directory Structure Scanner

A powerful Bash script for analyzing project directory structures and preparing them for Git version control. Perfect for developers and product managers who need to understand project layouts before initializing Git repositories.

## Features

- **Visual Directory Tree**: Generate clean, colored directory structures
- **Git Preparation**: Identify potential .gitignore candidates and problematic files
- **Large File Detection**: Find files over 10MB that might not belong in version control
- **Binary File Analysis**: Locate executables, archives, and other binary files
- **Flexible Depth Control**: Limit scanning depth to avoid overwhelming output
- **Hidden Files Support**: Option to include or exclude hidden files and directories
- **Size Information**: Display file sizes for better storage analysis

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/yourusername/directory-scanner/main/scan_project.sh
```

2. Make it executable:
```bash
chmod +x scan_project.sh
```

3. Optionally, move to your PATH:
```bash
sudo mv scan_project.sh /usr/local/bin/scan-project
```

## Usage

### Basic Usage
```bash
# Scan current directory
./scan_project.sh

# Scan specific directory
./scan_project.sh /path/to/your/project

# Show help
./scan_project.sh --help
```

### Advanced Options
```bash
# Git-ready analysis with custom depth
./scan_project.sh -g -d 4 /path/to/project

# Include hidden files and show sizes
./scan_project.sh -a -s -d 3 ./my-project

# Complete analysis for Git preparation
./scan_project.sh --git-ready --all --size --depth 5 ~/development/my-app
```

## Command Line Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-d NUM` | `--depth NUM` | Maximum directory depth to scan (default: 3) |
| `-a` | `--all` | Include hidden files and directories |
| `-s` | `--size` | Display file sizes |
| `-g` | `--git-ready` | Perform Git-specific analysis |
| `-h` | `--help` | Show help information |

## Git Analysis Features

When using the `--git-ready` option, the script provides:

- **Repository Detection**: Checks if Git is already initialized
- **Ignore Candidates**: Identifies common directories that should be in .gitignore
- **Large File Warnings**: Lists files over 10MB that might cause repository bloat
- **Binary Detection**: Finds executables and archives that typically shouldn't be versioned
- **Next Steps Guide**: Provides exact commands for Git initialization

## Example Output

```
=== Directory structure of: /home/user/my-project ===

📁 src/
  📁 components/
    📄 Header.js
    📄 Footer.js
  📁 utils/
    📄 helpers.js
📁 tests/
  📄 app.test.js
📄 package.json
📄 README.md

=== Git Analysis for: /home/user/my-project ===

✓ Ready for Git initialization

Potential .gitignore entries:
node_modules
.vscode
dist

Large files (>10MB):
15M ./assets/video.mp4

Next steps for Git:
1. cd /home/user/my-project
2. git init
3. Create .gitignore
4. git add .
5. git commit -m "Initial commit"
```

## Use Cases

### For Product Managers
- Understand project structure before code reviews
- Assess technical debt and project organization
- Prepare clean handovers between development teams

### For Developers
- Quick project structure overview
- Pre-commit repository health checks
- Identify cleanup opportunities before releases

### For DevOps
- Analyze build artifacts and deployment structures
- Identify repository optimization opportunities
- Prepare CI/CD pipeline configurations

## Requirements

- Bash shell (version 4.0 or higher)
- Standard Unix utilities: `find`, `du`, `awk`, `sort`
- Linux or macOS operating system

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by Mnemonic

---

**Tip**: Use this script regularly during development to maintain clean project structures and efficient Git workflows.
