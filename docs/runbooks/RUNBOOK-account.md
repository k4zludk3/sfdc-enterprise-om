# RUNBOOK: Account Domain

Owner: Domain: Account
Last Updated: 2025-12-11

## What It Does
- Validates Account BillingPostalCode format per BillingCountry (currently Brazil supported).
- Enriches Account address data via AccountService when postal code is valid.
- Runs in trigger contexts (before/after insert/update) using the Trigger framework.
- Logs key steps via Logger and prevents recursion with guard flags.

## Entry Points
- Trigger: AccountTrigger.trigger → AccountDomain.run()
- Lifecycle Hooks Used:
  - afterInsert, afterUpdate → validation & enrichment
  - before* → currently minimal/no logic (subject to future changes)
- Related Services:
  - IAccountService / AccountService.populateAddressInfoFromPostalCodeAPI(List<Account>)

## Dependencies
- Postal Code Strategy:
  - PostalCodeStrategyFactory
  - BrazilPostalCodeStrategy (current implementation)
- Framework:
  - TriggerHandler, TriggerDispatcher, Application
  - Logger, RecursionCheck (if used)
- Security: with sharing classes; use USER_MODE where configured

## Common Failures and Remediation
1) NullPointerException on trigger context setup
- Symptom:
  - System.NullPointerException at AccountDomain.setContextTriggerRecords
- Cause:
  - Dereferencing Trigger.newMap/oldMap without null checks
- Remediation:
  - Ensure AccountDomain.setContextTriggerRecords guards null maps for different operations
  - Deploy fix and re-run the failing operation
  - See FEATURE-0007 for defensive pattern

2) Invalid postal code addError
- Symptom:
  - User cannot save Account; message: "Invalid postal code format for country: {BillingCountry}"
- Cause:
  - Postal code format validation failed (e.g., Brazil CEP incorrect)
- Remediation:
  - Correct BillingPostalCode to a valid format
  - If country-specific rules are missing, consider implementing the strategy or using a safe fallback
  - If false positive, update strategy or tests accordingly

3) Address enrichment service errors
- Symptom:
  - Unhandled exception during afterInsert/afterUpdate, or missing expected address fields
- Cause:
  - External service failure or AccountService error
- Remediation:
  - Check logs (Logger) for service call details
  - Temporarily disable enrichment if causing incidents; hotfix service try/catch and fallback
  - Re-run with minimal batch size if volume-related

## Observability
- Logs:
  - Logger.info in AccountDomain afterInsert/afterUpdate
  - Ensure sensitive data is not logged
- Suggested Dashboards/Monitoring:
  - Apex Exception Events (if configured)
  - Platform Event metrics (if later used)

## Manual Procedures
- Re-try Enrichment for a Set of Accounts:
  1. Prepare a SOQL to fetch target Accounts with valid country/postal code.
  2. Use Anonymous Apex to call AccountService.populateAddressInfoFromPostalCodeAPI with a small batch.
  3. Monitor logs for completion and errors.

- Temporarily Bypass Enrichment:
  - Comment or feature-flag the callout in AccountService for incident mitigation; document change in an incident note and revert ASAP.

## Versioning / Change Management
- ADR: docs/adr/ADR-0001-trigger-framework.md
- Feature Spec: docs/features/FEATURE-0007-account-postal-code-validation.md
- PRs must reference the Feature and ADR; updates to behavior should update this runbook.

## Quick Links
- Feature: docs/features/FEATURE-0007-account-postal-code-validation.md
- ADR: docs/adr/ADR-0001-trigger-framework.md
- Diagrams:
  - docs/diagrams/architecture-overview.mmd
  - docs/diagrams/postal-pattern.mmd
  - docs/diagrams/trigger-flow.mmd
