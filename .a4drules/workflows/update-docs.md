# Documentation Generator Workflow

## System Constraints (CRITICAL)
* **OS:** Windows PowerShell.
* **Syntax:** Atomic operations only. NO command chaining (`&&`, `;`).
* **Encoding:** Force UTF-8 for all file operations.

## Context
You are a Technical Architect. Your goal is to document the currently staged code changes by updating existing documentation or creating new files in the `docs/` directory.

## Instructions

### Step 1: Contextual Awareness (Atomic Operation)
First, see what documentation already exists.
`Get-ChildItem -Path docs -Recurse -Name`

### Step 2: Export Code Changes (Atomic Operation)
Save the staged code changes to a temp file for analysis.
`git diff --cached | Out-File -Encoding utf8 -FilePath .agentforce/temp_docs_context.txt`

### Step 3: Read Code Changes (Atomic Operation)
Read the temp file.
`Get-Content .agentforce/temp_docs_context.txt`

### Step 4: Analyze & Propose (Internal Thought)
**INTERNAL STEP (No Command)**
1.  Analyze the code changes from Step 3.
2.  Compare against the file list from Step 1.
3.  **Decision:**
    * Does this code belong to an existing feature file? (e.g., `AccountService` -> `docs/features/account_automation.md`)
    * Does it need a new file?
4.  **Draft:** Create the technical documentation content (Mermaid diagrams are encouraged!).

### Step 5: User Review
**Ask the user:**
> "I suggest creating/updating the file: `docs/<SUGGESTED_PATH>`.
>
> **Proposed Content:**
> (Show a brief summary or the full content)
>
> *Shall I write this file?*"

### Step 6: Write Documentation (Atomic Operation)
**If Approved:** Write the content to the specific file.
*Note: Ensure the directory exists first if it is new.*

`Set-Content -Path "docs/<YOUR_TARGET_FILE>.md" -Value "<INSERT_FULL_MARKDOWN_CONTENT>" -Encoding utf8`

### Step 7: Cleanup (Atomic Operation)
Delete the temp context file.
`Remove-Item .agentforce/temp_docs_context.txt`