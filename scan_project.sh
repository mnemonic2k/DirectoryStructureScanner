#!/bin/bash

# Directory Structure Scanner for Git Preparation
# Author: Mnemonic2k
# Purpose: Project structure analysis before Git initialization

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
show_help() {
    echo "Usage: $0 [OPTIONS] [DIRECTORY]"
    echo ""
    echo "Options:"
    echo "  -d, --depth NUM     Maximum depth of directory structure (default: 3)"
    echo "  -a, --all          Show hidden files as well"
    echo "  -s, --size         Show file sizes"
    echo "  -g, --git-ready    Git-specific analysis"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Example: $0 -d 4 -g /path/to/project"
}

analyze_for_git() {
    local target_dir="$1"
    
    echo -e "${BLUE}=== Git Analysis for: $target_dir ===${NC}"
    echo ""
    
    # Check if Git repository already exists
    if [ -d "$target_dir/.git" ]; then
        echo -e "${YELLOW}⚠️  Git repository already exists${NC}"
        echo ""
    else
        echo -e "${GREEN}✓ Ready for Git initialization${NC}"
        echo ""
    fi
    
    # Potential .gitignore candidates
    echo -e "${BLUE}Potential .gitignore entries:${NC}"
    find "$target_dir" -maxdepth 2 -type d \( -name "node_modules" -o -name ".vscode" -o -name ".idea" -o -name "dist" -o -name "build" -o -name "target" -o -name "__pycache__" \) 2>/dev/null | sed 's|'"$target_dir"'/||' | sort
    
    # Find large files
    echo ""
    echo -e "${BLUE}Large files (>10MB):${NC}"
    find "$target_dir" -type f -size +10M -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | head -10
    
    # Binary files
    echo ""
    echo -e "${BLUE}Binary files and archives:${NC}"
    find "$target_dir" -type f \( -name "*.exe" -o -name "*.dll" -o -name "*.so" -o -name "*.zip" -o -name "*.tar.gz" -o -name "*.jar" -o -name "*.war" \) 2>/dev/null | head -10
    
    echo ""
}

scan_directory() {
    local target_dir="$1"
    local max_depth="$2"
    local show_hidden="$3"
    local show_size="$4"
    
    # Tree-like output using find
    echo -e "${GREEN}=== Directory structure of: $target_dir ===${NC}"
    echo ""
    
    local find_opts=""
    if [ "$show_hidden" = false ]; then
        find_opts="-not -path '*/\.*'"
    fi
    
    if [ "$show_size" = true ]; then
        eval "find '$target_dir' -maxdepth $max_depth $find_opts -type d" | sort | while read dir; do
            local depth=$(echo "$dir" | tr -cd '/' | wc -c)
            local indent=$(printf "%*s" $((($depth - $(echo "$target_dir" | tr -cd '/' | wc -c)) * 2)) "")
            local dirname=$(basename "$dir")
            if [ "$dir" != "$target_dir" ]; then
                echo -e "${indent}${BLUE}📁 $dirname/${NC}"
            fi
            
            # Files in this directory
            eval "find '$dir' -maxdepth 1 $find_opts -type f" | sort | while read file; do
                if [ -f "$file" ]; then
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    local filename=$(basename "$file")
                    echo -e "${indent}  📄 $filename ${YELLOW}($size)${NC}"
                fi
            done
        done
    else
        eval "find '$target_dir' -maxdepth $max_depth $find_opts" | sort | while read item; do
            if [ "$item" = "$target_dir" ]; then
                continue
            fi
            
            local depth=$(echo "$item" | tr -cd '/' | wc -c)
            local target_depth=$(echo "$target_dir" | tr -cd '/' | wc -c)
            local indent=$(printf "%*s" $(((depth - target_depth) * 2)) "")
            local name=$(basename "$item")
            
            if [ -d "$item" ]; then
                echo -e "${indent}${BLUE}📁 $name/${NC}"
            else
                echo -e "${indent}📄 $name"
            fi
        done
    fi
}

# Default values
MAX_DEPTH=3
SHOW_HIDDEN=false
SHOW_SIZE=false
GIT_ANALYSIS=false
TARGET_DIR="."

# Process parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--depth)
            MAX_DEPTH="$2"
            shift 2
            ;;
        -a|--all)
            SHOW_HIDDEN=true
            shift
            ;;
        -s|--size)
            SHOW_SIZE=true
            shift
            ;;
        -g|--git-ready)
            GIT_ANALYSIS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Check directory
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

# Determine absolute path
TARGET_DIR=$(realpath "$TARGET_DIR")

# Execute main function
echo -e "${GREEN}Analyzing directory structure...${NC}"
echo ""

scan_directory "$TARGET_DIR" "$MAX_DEPTH" "$SHOW_HIDDEN" "$SHOW_SIZE"

if [ "$GIT_ANALYSIS" = true ]; then
    echo ""
    echo ""
    analyze_for_git "$TARGET_DIR"
fi

# Summary
echo ""
echo -e "${GREEN}=== Summary ===${NC}"

# Count only within the specified depth and apply same filters as display
count_opts=""
if [ "$SHOW_HIDDEN" = false ]; then
    count_opts="-not -path '*/\.*'"
fi

total_dirs=$(eval "find '$TARGET_DIR' -maxdepth $MAX_DEPTH $count_opts -type d" 2>/dev/null | wc -l)
total_files=$(eval "find '$TARGET_DIR' -maxdepth $MAX_DEPTH $count_opts -type f" 2>/dev/null | wc -l)

# Subtract 1 from directories to exclude the target directory itself
total_dirs=$((total_dirs - 1))

echo "Directories shown: $total_dirs (depth: $MAX_DEPTH)"
echo "Files shown: $total_files"

# Show actual total if different
if [ "$MAX_DEPTH" -lt 10 ]; then
    actual_dirs=$(eval "find '$TARGET_DIR' $count_opts -type d" 2>/dev/null | wc -l)
    actual_files=$(eval "find '$TARGET_DIR' $count_opts -type f" 2>/dev/null | wc -l)
    actual_dirs=$((actual_dirs - 1))
    
    if [ "$actual_dirs" -ne "$total_dirs" ] || [ "$actual_files" -ne "$total_files" ]; then
        echo -e "${YELLOW}Total in entire tree: $actual_dirs directories, $actual_files files${NC}"
    fi
fi

if [ "$GIT_ANALYSIS" = true ]; then
    echo ""
    echo -e "${BLUE}Next steps for Git:${NC}"
    echo "1. cd $TARGET_DIR"
    echo "2. git init"
    echo "3. Create .gitignore"
    echo "4. git add ."
    echo "5. git commit -m \"Initial commit\""
fi
