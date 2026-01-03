# Start New Feature Workflow

## System Constraints
* **OS:** Windows PowerShell.
* **Syntax:** Atomic operations.

## Context
You are a Lead Architect. Your goal is to start a new workstream cleanly, ensuring the local environment is up-to-date before branching.

## Instructions

### Step 1: Input Validation (Internal Thought)
**INTERNAL STEP (No Command)**
1.  Ask the user: "What is the name of the feature or fix you want to work on?"
2.  Wait for the user's response.
3.  Sanitize the name (lowercase, hyphens instead of spaces).
    * *Input:* "Account Logic Update"
    * *Output:* `account-logic-update`
4.  Determine the type: `feat` (new), `fix` (bug), `chore` (maintenance).

### Step 2: Sync Main (Atomic Operation)
Switch to main and pull the latest changes to ensure we don't branch from stale code.
`git checkout main; git pull origin main`

### Step 3: Create Branch (Atomic Operation)
Create and switch to the new branch using the standardized name.
`git checkout -b <type>/<sanitized-name>`

### Step 4: Scaffold Documentation (Optional)
**Ask the user:**
> "Branch `<type>/<sanitized-name>` created!
>
> Do you want me to create a blank Feature Documentation file in `docs/features/`?"

* **If YES:**
    `Set-Content -Path "docs/features/FEATURE-<sanitized-name>.md" -Value "# Feature: <Original Name>`r`n`r`n## Objective`r`nTODO" -Encoding utf8`

### Step 5: Summary
Output: "You are now on branch `<type>/<sanitized-name>`. You may begin coding."