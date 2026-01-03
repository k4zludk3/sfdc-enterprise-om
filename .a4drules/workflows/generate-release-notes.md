# Release Notes Generator Workflow

## System Constraints (CRITICAL)
* **OS:** Windows PowerShell.
* **Syntax:** Atomic operations only. NO command chaining.
* **Formatting:** "Keep a Changelog" standard (Markdown).

## Context
You are a Release Manager. Your goal is to generate a semantic versioning changelog update based on the recent git history.

## Instructions

### Step 1: Capture Raw History (Atomic Operation)
Retrieve the list of commits that are in the current branch but not yet in main.
*Note: We focus on the 'Subject' of the commit only.*

`git log origin/main..HEAD --pretty=format:"%s" | Out-File -Encoding utf8 -FilePath .agentforce/temp_git_log.txt`

### Step 2: Read History (Atomic Operation)
Read the captured log file.
`Get-Content .agentforce/temp_git_log.txt`

### Step 3: Read Existing Changelog (Atomic Operation)
Check if a changelog already exists to preserve history.
*Note: It is okay if this file does not exist yet.*

`if (Test-Path CHANGELOG.md) { Get-Content CHANGELOG.md } else { echo "No existing changelog." }`

### Step 4: Synthesize Release Notes (Internal Thought)
**INTERNAL STEP (No Command)**
1.  Analyze the commits from Step 2.
2.  **Categorize them:**
    * `feat` -> **🚀 New Features**
    * `fix` -> **🐛 Bug Fixes**
    * `perf` -> **⚡ Performance Improvements**
    * *Ignore:* `chore`, `style`, `test` (unless critical).
3.  **Draft the content:**
    * Header: `## [Unreleased] - <YYYY-MM-DD>`
    * Body: The categorized list.
    * Footer: The content from Step 3 (Existing Changelog).

### Step 5: Verify with User
**Ask the user:**
> "I have drafted the release notes for the unreleased changes.
>
> **Preview:**
> (Show the generated Markdown)
>
> *Shall I save this to CHANGELOG.md?*"

### Step 6: Save Changelog (Atomic Operation)
**If Approved:** Write the *full* content (New Notes + Old Notes) to the file.

`Set-Content -Path CHANGELOG.md -Value "<INSERT_FULL_COMBINED_CONTENT>" -Encoding utf8`

### Step 7: Cleanup
Delete the temp file.
`Remove-Item .agentforce/temp_git_log.txt`