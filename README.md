/*
 * Copyright © 2025 Devin B. Royal.
 * All Rights Reserved.
 */
# git-pulse.sh: Enterprise Git Project Health Checker

**Author:** Devin B. Royal, CTO
**Version:** 1.1.0-PRODUCTION
**License:** All Rights Reserved (Proprietary)

## 🎯 Overview

`git-pulse.sh` is a secure, single-file Bash utility engineered to provide an immediate, visually rich status summary of any Git repository. It consolidates four critical development checks into one authoritative terminal output, enabling rapid operational awareness of a project's state.

This script is built for production environments, prioritizing clear color-coded alerts and defensive error handling.

## ✨ Features

1.  **Working Directory Cleanliness:** Instant status check (✅ **CLEAN** or 🚨 **DIRTY** with uncommitted changes).
2.  **Branch Sync Status:** Clear reporting of local vs. remote status, indicating commits **AHEAD (↑ Push)** or **BEHIND (↓ Pull)**.
3.  **Branch Staleness Policy:** Checks the age of the last commit against a configurable **30-day policy** (`STALE_THRESHOLD_DAYS`), alerting the user with a 🔥 **STALE** warning for inactive branches.
4.  **Head Commit Summary:** Displays the hash, author, and message of the current branch's latest commit for quick context.
5.  **Secure and Robust:** Features defensive checks for utility existence (`git`, `awk`) and handles execution outside a Git repository gracefully.

## 🛠️ Installation and Setup

Since `git-pulse.sh` is a self-contained Bash script, no compilation or external dependencies (beyond standard Linux/macOS tooling) are required.

### Prerequisites

* A compatible Unix-like environment (Linux, macOS, WSL).
* The **`git`** command-line tool.
* The **`awk`** utility.

### Step-by-Step Deployment

1.  **Download/Create the File:** Save the provided script content as `git-pulse.sh`.
2.  **Grant Execution Permission:**
    ```bash
    chmod +x git-pulse.sh
    ```
3.  **(Optional) Add to PATH:** For system-wide access, copy the script to a directory in your `$PATH` (e.g., `/usr/local/bin`).
    ```bash
    sudo cp git-pulse.sh /usr/local/bin/
    ```

## 🚀 Usage

Execute the script from within the top-level directory of any cloned Git repository.

```bash
# Run the script from inside your project directory
./git-pulse.sh

Example Output (In a Clean Repository)

>>> Git Project Health Check (git-pulse) (v1.1.0) <<<
------------------------------------------------
1. Working Directory Status:
  ✅ CLEAN: Working directory is tidy.

2. Branch Sync Status (main):
  Branch is UP-TO-DATE with remote.

3. Branch Activity Check:
  Branch is FRESH: Last commit was 3 days ago.

4. Head Commit Summary:
  Hash: a1b2c3d
  Author: Devin B. Royal
  Message: SEC-101: Implement enhanced JWT token validation

------------------------------------------------
[INFO] Scan complete. Status: main.
Example Output (Outside a Repository)

If run outside a Git repository, the script exits gracefully with an informative warning:

>>> Git Project Health Check (git-pulse) (v1.1.0) <<<
------------------------------------------------
⚠️ WARNING: Not inside a Git repository.
  Status: Ready to scan.
  Run this command in any cloned Git project for full details.
------------------------------------------------
[INFO] Scan not performed. Exiting gracefully for user context.
🔐 Security Notes and Design
Stateless Operation: The script operates purely on the local Git data (.git directory) and makes no external connections, ensuring zero external exposure risk.

Input Handling: All Git command outputs are processed using core Unix utilities (awk), and critical variable assignments are securely handled to prevent shell injection vectors.

Security Policy: The Staleness Check enforces an internal operational policy, highlighting branches that may pose a security or maintenance risk due to inactivity.

⚙️ Customization
The operational policy can be tuned directly within the script:

Variable	Description	Default Value
STALE_THRESHOLD_DAYS	Number of days after which a branch is flagged as STALE (🔥).	30
Edit the script file directly to adjust this constant for your organization's maintenance policy.

/*

Copyright © 2025 Devin B. Royal.

All Rights Reserved.
*/
