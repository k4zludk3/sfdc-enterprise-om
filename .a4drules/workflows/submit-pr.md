# Git Create Pull Request Workflow

## System Constraints (CRITICAL)
* **OS:** Windows PowerShell.
* **Syntax Rule:** Execute exactly **ONE** command per turn. Do not chain commands (`&&`, `;`).
* **Output Rule:** strict adherence to the project's PR template.

## Context
You are a Release Manager. Your goal is to create a GitHub Pull Request (PR) that adheres to strict documentation standards.

## Instructions

### Step 1: Verify Clean State
Check if the working directory is clean.
`git status --porcelain`

* *Decision:* If output is **NOT** empty, STOP. Tell the user: "You have uncommitted changes. Please run /submit-commit first."
* *Decision:* If empty, proceed.

### Step 2: Push Changes (Atomic Operation)
Ensure the remote is in sync with your local branch.
`git push origin HEAD`

### Step 3: Load PR Template (Atomic Operation)
Read the project's official PR template.
`Get-Content docs/templates/pull_request_template.md`

### Step 4: Load Commit History (Atomic Operation)
Retrieve the commits made in this branch (relative to main) to help summarize the work.
`git log origin/main..HEAD --pretty=format:"%h - %s"`

### Step 5: The Documentation "Quality Gate"
**INTERNAL STEP (No Command)**
1.  Review the file changes in the commits from Step 4.
2.  **Ask the user:**
    > "I am preparing the PR. Have you created or updated the relevant documentation in the `docs/` folder for these changes?
    >
    > *If NO: Should we abort so you can add them?*
    > *If YES: Shall I proceed with drafting the PR body?*"

### Step 6: Draft PR Body (Internal Synthesis)
**INTERNAL STEP (No Command)**
1.  Using the **Template** from Step 3 and the **Commits** from Step 4, generate a full PR description.
2.  Fill in the sections of the template (e.g., "Description", "Type of Change", "Tests").
3.  **Crucial:** Do not output the text to the terminal yet. Just prepare it.

### Step 7: Save PR Body to File (Atomic Operation)
Save your drafted content to a temporary file.
*Note: Write the content inside the quotes below.*

`Set-Content -Path .agentforce/temp_pr_body.md -Value "<INSERT_YOUR_FULL_MARKDOWN_CONTENT_HERE>" -Encoding utf8`

### Step 8: Create Pull Request (Atomic Operation)
Execute the GitHub CLI command using the body file.
*Note: We use --web so the user can review it in the browser if needed, or remove --web to just create it.*

`gh pr create --title "<INSERT_CONCISE_TITLE_BASED_ON_COMMITS>" --body-file .agentforce/temp_pr_body.md --web`

### Step 9: Cleanup
Remove the temporary body file.
`Remove-Item .agentforce/temp_pr_body.md`