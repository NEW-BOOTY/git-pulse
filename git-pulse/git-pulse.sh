#!/bin/bash

###########################################################

# Script: git-pulse - A Git Project Health Checker

# Author: Devin B. Royal

# Date: 2025-05-08

# Copyright (c) 2025, Devin B. Royal. All rights reserved.

# License: MIT 

###########################################################

# Define Colors for Visual Impact

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[0;33m'

CYAN='\033[0;36m'

BOLD='\033[1m'

NC='\033[0m' # No Color

# Check if we are inside a Git repository

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then

    echo -e "${RED}Error:${NC} This script must be run inside a Git repository."

    exit 1

fi

echo -e "\n${BOLD}${CYAN}>>> Git Project Health Check (git-pulse) <<<${NC}"

echo "------------------------------------------------"

# --- 1. DIRTY OR CLEAN? (The most crucial check) ---

echo -e "${BOLD}1. Working Directory Status:${NC}"

if ! git diff-index --quiet HEAD --; then

    echo -e "  ${RED}🚨 DIRTY:${NC} You have ${BOLD}uncommitted changes${NC}."

else

    echo -e "  ${GREEN}✅ CLEAN:${NC} Working directory is tidy."

fi

# --- 2. BRANCH STATUS (Remote vs. Local) ---

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

UPSTREAM_INFO=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null)

echo -e "\n${BOLD}2. Branch Sync Status (${CURRENT_BRANCH}):${NC}"

if [ -n "$UPSTREAM_INFO" ]; then

    AHEAD=$(echo $UPSTREAM_INFO | awk '{print $1}')

    BEHIND=$(echo $UPSTREAM_INFO | awk '{print $2}')

    

    if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then

        echo -e "  Branch is ${YELLOW}diverged${NC} (${AHEAD} ↑ / ${BEHIND} ↓)."

    elif [ "$AHEAD" -gt 0 ]; then

        echo -e "  Branch is ${GREEN}${AHEAD} commits ahead${NC} (↑ Push required)."

    elif [ "$BEHIND" -gt 0 ]; then

        echo -e "  Branch is ${RED}${BEHIND} commits behind${NC} (↓ Pull required)."

    else

        echo -e "  Branch is ${GREEN}up-to-date${NC} with remote."

    fi

else

    echo -e "  Branch is ${CYAN}local only${NC} or no upstream set."

fi

# --- 3. LAST COMMIT DETAILS (Aesthetic & Informative) ---

LAST_COMMIT_HASH=$(git log -1 --pretty=format:'%h')

LAST_COMMIT_MSG=$(git log -1 --pretty=format:'%s')

LAST_COMMIT_AUTHOR=$(git log -1 --pretty=format:'%an')

LAST_COMMIT_DATE=$(git log -1 --pretty=format:'%cr')

echo -e "\n${BOLD}3. Last Commit ($LAST_COMMIT_HASH):${NC}"

echo "  Message: ${YELLOW}${LAST_COMMIT_MSG}${NC}"

echo "  Author: ${LAST_COMMIT_AUTHOR}"

echo "  When: ${LAST_COMMIT_DATE}"

echo "------------------------------------------------"

# Footer for quick reference

echo -e "${CYAN}Run: bash git-pulse.sh${NC}"

echo -e "Copyright (c) 2025, Devin B. Royal"