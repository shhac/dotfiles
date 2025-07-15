#!/usr/bin/env zsh

gwt-new() {
    # Define colors
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local NC='\033[0m' # No Color
    
    # Check if branch name is provided
    if [[ -z "$1" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Please provide a branch name${NC}"
        echo -e "${YELLOW}Usage:${NC} claudetree <branch-name>"
        return 1
    fi
    
    local branch_name="$1"
    
    # Get the root of the git repository
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Not in a git repository${NC}"
        return 1
    fi
    
    # Get the repository directory name
    local repo_name=$(basename "$repo_root")
    
    # Get the parent directory of the repository
    local parent_dir=$(dirname "$repo_root")
    
    # Construct the worktree path
    local worktree_path="${parent_dir}/${repo_name}-trees/${branch_name}"
    
    # Create the worktree
    echo -e "${BLUE}${BOLD}Creating worktree at:${NC} ${CYAN}$worktree_path${NC}"
    if git worktree add "$worktree_path" -b "$branch_name"; then
        echo -e "${GREEN}${BOLD}✓ Worktree created successfully${NC}"
        
        # Change to the new worktree directory
        cd "$worktree_path"
        echo -e "${MAGENTA}${BOLD}📁 Changed directory to:${NC} ${CYAN}$worktree_path${NC}"
        
        # Check for .nvmrc and run nvm use if it exists
        if [[ -f ".nvmrc" ]]; then
            echo -e "${YELLOW}${BOLD}📋 Found .nvmrc, running nvm use...${NC}"
            nvm use
            # Rehash to ensure yarn is available in PATH after nvm use
            hash -r
        fi
        
        # Check for package.json with yarn package manager
        if [[ -f "package.json" ]] && grep -q '"packageManager":[[:space:]]*"yarn' package.json; then
            echo -e "${YELLOW}${BOLD}📦 Found package.json with yarn, running yarn install...${NC}"
            # Use command to bypass any aliases and ensure we're using the right yarn
            command yarn
        fi
        
        # Copy local configuration files from main repository
        echo -e "${YELLOW}${BOLD}📋 Copying local configuration files...${NC}"
        
        # Array of files/directories to copy if they exist
        local config_items=(
            ".claude"           # Claude Code configuration
            ".env"              # Environment variables
            ".env.local"        # Local environment overrides
            ".env.development"  # Development environment
            ".env.test"         # Test environment
            ".env.production"   # Production environment
            "CLAUDE.local.md"   # Local Claude instructions
            ".ai-cache"         # AI cache directory
        )
        
        for item in "${config_items[@]}"; do
            if [[ -e "$repo_root/$item" ]]; then
                if [[ -d "$repo_root/$item" ]]; then
                    # It's a directory
                    cp -r "$repo_root/$item" "$worktree_path/"
                    echo -e "  ${GREEN}✓${NC} Copied directory: ${CYAN}$item${NC}"
                else
                    # It's a file
                    cp "$repo_root/$item" "$worktree_path/"
                    echo -e "  ${GREEN}✓${NC} Copied file: ${CYAN}$item${NC}"
                fi
            fi
        done
        
        # Ask if user wants to run claude
        echo
        echo -n -e "${YELLOW}Would you like to start claude?${NC} [Y/n] "
        read -r response
        if [[ -z "$response" || "$response" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}${BOLD}🚀 Starting claude...${NC}"
            claude
        else
            echo -e "${BLUE}Skipped starting claude${NC}"
        fi
    else
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Failed to create worktree${NC}"
        return 1
    fi
}

gwt-rm() {
    # Define colors
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local NC='\033[0m' # No Color
    
    # Check if we're in a git repository
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Not in a git repository${NC}"
        return 1
    fi
    
    # Check if we're in a worktree
    local git_dir=$(git rev-parse --git-dir 2>/dev/null)
    local worktree_path=$(git rev-parse --show-toplevel 2>/dev/null)
    
    # If .git is a directory (not a file), we're in the main repo
    if [[ -d "$git_dir" && "$git_dir" == "$worktree_path/.git" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}You are in the main repository, not a worktree${NC}"
        echo -e "${YELLOW}Tip:${NC} This command should be run from within a git worktree"
        return 1
    fi
    
    # If .git is not a file, something is wrong
    if [[ ! -f "$worktree_path/.git" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Not in a git worktree${NC}"
        return 1
    fi
    
    # Get the main repository path
    local main_repo=$(git worktree list | head -n1 | awk '{print $1}')
    if [[ -z "$main_repo" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Could not determine main repository path${NC}"
        return 1
    fi
    
    # Get the current branch name
    local current_branch=$(git branch --show-current)
    
    # Show what we're about to do
    echo -e "${YELLOW}${BOLD}⚠️  About to remove worktree:${NC}"
    echo -e "   ${CYAN}Path:${NC} $worktree_path"
    echo -e "   ${CYAN}Currently on branch:${NC} $current_branch"
    echo
    echo -n -e "${YELLOW}Are you sure you want to continue?${NC} [y/N] "
    
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    fi
    
    # Change to the main repository
    echo -e "${MAGENTA}${BOLD}📁 Changing to main repository:${NC} ${CYAN}$main_repo${NC}"
    cd "$main_repo"
    
    # Remove the worktree
    echo -e "${BLUE}${BOLD}Removing worktree...${NC}"
    if git worktree remove "$worktree_path"; then
        echo -e "${GREEN}${BOLD}✓ Worktree removed successfully${NC}"
    else
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Failed to remove worktree${NC}"
        return 1
    fi
    
    # Ask about deleting the branch
    echo
    echo -n -e "${YELLOW}Would you also like to delete the branch '${current_branch}'?${NC} [y/N] "
    
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}${BOLD}Deleting branch...${NC}"
        if git branch -D "$current_branch"; then
            echo -e "${GREEN}${BOLD}✓ Branch deleted successfully${NC}"
        else
            echo -e "${RED}${BOLD}Error:${NC} ${RED}Failed to delete branch${NC}"
            echo -e "${YELLOW}You may need to delete it manually${NC}"
        fi
    else
        echo -e "${BLUE}Branch '${current_branch}' was kept${NC}"
    fi
}

gwt-go() {
    # Define colors
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local NC='\033[0m' # No Color
    
    # Get the root of the git repository
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo -e "${RED}${BOLD}Error:${NC} ${RED}Not in a git repository${NC}"
        return 1
    fi
    
    # Check if we're in a worktree
    local git_dir=$(git rev-parse --git-dir 2>/dev/null)
    local main_repo=""
    local repo_name=""
    local parent_dir=""
    local trees_dir=""
    
    if [[ -f "$repo_root/.git" ]]; then
        # We're in a worktree, get the main repository
        local main_repo=$(git worktree list | head -n1 | awk '{print $1}')
        repo_name=$(basename "$main_repo")
        parent_dir=$(dirname "$main_repo")
        trees_dir="${parent_dir}/${repo_name}-trees"
    else
        # We're in the main repository
        main_repo="$repo_root"
        repo_name=$(basename "$repo_root")
        parent_dir=$(dirname "$repo_root")
        trees_dir="${parent_dir}/${repo_name}-trees"
    fi
    
    # Check if branch name is provided
    if [[ -n "$1" ]]; then
        # Special case for "main" to go to main repository
        if [[ "$1" == "main" ]]; then
            echo -e "${MAGENTA}${BOLD}📁 Navigating to main repository:${NC} ${CYAN}$main_repo${NC}"
            cd "$main_repo"
            return 0
        fi
        
        # Direct navigation to specified branch
        local branch_name="$1"
        local worktree_path="${trees_dir}/${branch_name}"
        
        if [[ -d "$worktree_path" ]]; then
            echo -e "${MAGENTA}${BOLD}📁 Navigating to worktree:${NC} ${CYAN}$worktree_path${NC}"
            cd "$worktree_path"
        else
            echo -e "${RED}${BOLD}Error:${NC} ${RED}Worktree for branch '${branch_name}' not found at:${NC}"
            echo -e "       ${CYAN}$worktree_path${NC}"
            return 1
        fi
    else
        # Interactive selection mode
        # Get list of worktrees sorted by modification time (most recent first)
        local worktrees=()
        local worktree_times=()
        local worktree_branches=()
        
        # Add the main repository as an option (unless we're already in it)
        if [[ "$repo_root" != "$main_repo" ]]; then
            local main_mod_time=$(stat -f "%m" "$main_repo" 2>/dev/null || stat -c "%Y" "$main_repo" 2>/dev/null)
            worktrees+=("$main_repo")
            worktree_times+=("$main_mod_time")
            worktree_branches+=("[main repository]")
        fi
        
        # Check if trees directory exists
        if [[ -d "$trees_dir" ]]; then
            # Use a temporary file to avoid subshell issues
            local temp_file=$(mktemp)
            find "$trees_dir" -type f -name ".git" -print0 > "$temp_file" 2>/dev/null
            
            # Find all .git files and process their parent directories
            while IFS= read -r -d '' gitfile; do
                local worktree_path=$(dirname "$gitfile")
                
                # Skip if this is the current repository root
                if [[ "$worktree_path" == "$repo_root" ]]; then
                    continue
                fi
                
                # Extract branch name from the path relative to trees_dir
                local relative_path="${worktree_path#$trees_dir/}"
                local mod_time=$(stat -f "%m" "$worktree_path" 2>/dev/null || stat -c "%Y" "$worktree_path" 2>/dev/null)
                
                worktrees+=("$worktree_path")
                worktree_times+=("$mod_time")
                worktree_branches+=("$relative_path")
            done < "$temp_file"
            
            rm -f "$temp_file"
        fi
        
        if [[ ${#worktrees[@]} -eq 0 ]]; then
            echo -e "${YELLOW}${BOLD}No worktrees found in:${NC} ${CYAN}$trees_dir${NC}"
            return 0
        fi
        
        # Sort by modification time (bubble sort for simplicity)
        # Skip first element (main repo) and sort the rest
        local n=${#worktrees[@]}
        if [[ $n -gt 2 ]]; then
            for ((i = 2; i <= n; i++)); do
                for ((j = 2; j <= n - i + 1; j++)); do
                    local next=$((j + 1))
                    if [[ $next -le $n ]] && [[ ${worktree_times[$j]} -lt ${worktree_times[$next]} ]]; then
                        # Swap elements
                        local temp_path=${worktrees[$j]}
                        local temp_time=${worktree_times[$j]}
                        local temp_branch=${worktree_branches[$j]}
                        worktrees[$j]=${worktrees[$next]}
                        worktree_times[$j]=${worktree_times[$next]}
                        worktree_branches[$j]=${worktree_branches[$next]}
                        worktrees[$next]=$temp_path
                        worktree_times[$next]=$temp_time
                        worktree_branches[$next]=$temp_branch
                    fi
                done
            done
        fi
        
        # Display worktrees
        echo -e "${BLUE}${BOLD}Available worktrees:${NC}"
        echo
        for ((i = 1; i <= ${#worktrees[@]}; i++)); do
            local human_time=$(date -r ${worktree_times[$i]} "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "@${worktree_times[$i]}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
            
            # Get the current branch for this worktree
            local current_branch=""
            if [[ "${worktree_branches[$i]}" == "[main repository]" ]]; then
                current_branch=$(cd "${worktrees[$i]}" && git branch --show-current 2>/dev/null)
            else
                current_branch=$(cd "${worktrees[$i]}" && git branch --show-current 2>/dev/null)
            fi
            
            echo -e "  ${GREEN}${i}${NC}) ${CYAN}${worktree_branches[$i]}${NC} @ ${MAGENTA}${current_branch:-unknown}${NC}"
            echo -e "     ${YELLOW}Last modified:${NC} $human_time"
        done
        
        echo
        echo -n -e "${YELLOW}Enter number to navigate to (or 'q' to quit):${NC} "
        read -r selection
        
        if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        
        # Default to first option if empty
        if [[ -z "$selection" ]]; then
            selection=1
        fi
        
        # Validate selection
        if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#worktrees[@]} ]]; then
            echo -e "${RED}${BOLD}Error:${NC} ${RED}Invalid selection${NC}"
            return 1
        fi
        
        # Navigate to selected worktree (zsh arrays are 1-indexed)
        local selected_path=${worktrees[$selection]}
        echo -e "${MAGENTA}${BOLD}📁 Navigating to worktree:${NC} ${CYAN}$selected_path${NC}"
        cd "$selected_path"
    fi
}