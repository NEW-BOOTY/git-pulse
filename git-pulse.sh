/*
 * Copyright © 2025 Devin B. Royal.
 * All Rights Reserved.
 */
#!/bin/bash

# ==============================================================================
# Script: git-pulse.sh - Enterprise Git Project Health Checker
# Author: Devin B. Royal, CTO
# Version: 1.1.0-PRODUCTION (Enhanced for non-repository environment)
# Description: Provides a concise, colorful, and immediate status summary
#              of the local Git repository's health, or a clean status message.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Configuration & Constants
# ------------------------------------------------------------------------------

# Define ANSI Color Codes
RED='\033[0;31m'    # Danger/Behind
GREEN='\033[0;32m'  # Success/Clean
YELLOW='\033[0;33m' # Warning/Diverged
BLUE='\033[0;34m'   # Information
CYAN='\033[0;36m'   # Highlight/Header
BOLD='\033[1m'      # Bold text
NC='\033[0m'        # No Color (reset)

# Policy: Max days a branch is inactive before being marked "STALE"
STALE_THRESHOLD_DAYS=30

# ------------------------------------------------------------------------------
# 2. Defensive Programming & Setup
# ------------------------------------------------------------------------------

# Function for secure logging/error handling (uses stderr for true errors)
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function for clean informational output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if required commands exist
if ! command -v git >/dev/null 2>&1 || ! command -v awk >/dev/null 2>&1; then
    log_error "Required tools (git and awk) not found. Exiting."
    exit 1
fi

# Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # SOFT EXIT: Display a professional, non-failing status message for the LinkedIn demo
    echo -e "\n${BOLD}${CYAN}>>> Git Project Health Check (git-pulse) ${BOLD}(v1.1.0)${NC}"
    echo -e "${CYAN}------------------------------------------------${NC}"
    echo -e "${YELLOW}⚠️ WARNING:${NC} Not inside a Git repository."
    echo -e "  ${BLUE}Status:${NC} Ready to scan."
    echo -e "  ${BLUE}Run this command in any cloned Git project for full details.${NC}"
    echo -e "${CYAN}------------------------------------------------${NC}"
    log_info "Scan not performed. Exiting gracefully for user context."
    exit 0 # Exit successfully after informative warning
fi

# ------------------------------------------------------------------------------
# 3. Core Health Checks (Only runs if inside a Git repo)
# ------------------------------------------------------------------------------

echo -e "\n${BOLD}${CYAN}>>> Git Project Health Check (git-pulse) ${BOLD}(v1.1.0)${NC}"
echo -e "${CYAN}------------------------------------------------${NC}"

# --- CHECK 1: WORKING DIRECTORY CLEANLINESS ---
echo -e "${BOLD}1. Working Directory Status:${NC}"
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "  ${RED}🚨 DIRTY:${NC} You have ${BOLD}uncommitted changes${NC} (staged or unstaged)."
else
    echo -e "  ${GREEN}✅ CLEAN:${NC} Working directory is tidy."
fi

# --- CHECK 2: BRANCH SYNC STATUS (Remote vs. Local) ---
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
UPSTREAM_INFO=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null)

echo -e "\n${BOLD}2. Branch Sync Status (${CURRENT_BRANCH}):${NC}"

if [ -z "$UPSTREAM_INFO" ]; then
    echo -e "  Branch ${CYAN}${CURRENT_BRANCH}${NC} is local only or no upstream set."
else
    AHEAD=$(echo "$UPSTREAM_INFO" | awk '{print $1}')
    BEHIND=$(echo "$UPSTREAM_INFO" | awk '{print $2}')
    
    if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
        echo -e "  Branch is ${YELLOW}DIVERGED${NC} (${AHEAD} ${GREEN}↑ Push${NC} / ${BEHIND} ${RED}↓ Pull${NC} required)."
    elif [ "$AHEAD" -gt 0 ]; then
        echo -e "  Branch is ${GREEN}${AHEAD} commits ahead${NC} (↑ Push required)."
    elif [ "$BEHIND" -gt 0 ]; then
        echo -e "  Branch is ${RED}${BEHIND} commits behind${NC} (↓ Pull required)."
    else
        echo -e "  Branch is ${GREEN}UP-TO-DATE${NC} with remote."
    fi
fi

# --- CHECK 3: BRANCH STALENESS (The "Wow" Factor) ---
echo -e "\n${BOLD}3. Branch Activity Check:${NC}"

# Get the last commit date for the current branch in Unix timestamp format
LAST_COMMIT_TS=$(git log -1 --pretty=format:'%at' 2>/dev/null)

if [ -z "$LAST_COMMIT_TS" ]; then
    log_info "  Could not determine last commit time for this branch."
else
    CURRENT_TS=$(date +%s)
    
    # Calculate difference in seconds, then convert to days
    DIFF_SECONDS=$((CURRENT_TS - LAST_COMMIT_TS))
    DIFF_DAYS=$((DIFF_SECONDS / 86400)) # 86400 seconds in a day

    LAST_COMMIT_DATE_REL=$(git log -1 --pretty=format:'%cr' 2>/dev/null)
    
    if [ "$DIFF_DAYS" -gt "$STALE_THRESHOLD_DAYS" ]; then
        echo -e "  Branch is ${RED}🔥 STALE:${NC} Last commit was ${DIFF_DAYS} days ago (${LAST_COMMIT_DATE_REL})."
        echo -e "  ${RED}>> Policy Alert: Branch hasn't been touched in over ${STALE_THRESHOLD_DAYS} days.${NC}"
    elif [ "$DIFF_DAYS" -gt 7 ]; then
        echo -e "  Branch is ${YELLOW}AGING:${NC} Last commit was ${DIFF_DAYS} days ago (${LAST_COMMIT_DATE_REL})."
    else
        echo -e "  Branch is ${GREEN}FRESH:${NC} Last commit was ${LAST_COMMIT_DATE_REL}."
    fi
fi

# --- CHECK 4: LAST COMMIT DETAILS ---
echo -e "\n${BOLD}4. Head Commit Summary:${NC}"
LAST_COMMIT_HASH=$(git log -1 --pretty=format:'%h' 2>/dev/null)
LAST_COMMIT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null)
LAST_COMMIT_AUTHOR=$(git log -1 --pretty=format:'%an' 2>/dev/null)

echo "  Hash: ${BLUE}${LAST_COMMIT_HASH}${NC}"
echo "  Author: ${LAST_COMMIT_AUTHOR}"
echo "  Message: ${YELLOW}${LAST_COMMIT_MSG}${NC}"

echo -e "${CYAN}------------------------------------------------${NC}"
log_info "Scan complete. Status: $CURRENT_BRANCH."

/*
 * Copyright © 2025 Devin B. Royal.
 * All Rights Reserved.
 */
