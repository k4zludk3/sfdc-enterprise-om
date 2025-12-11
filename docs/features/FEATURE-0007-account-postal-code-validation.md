# FEATURE-0007: Account Postal Code Validation and Address Enrichment

Status: Accepted
Date: 2025-12-11
Owner: Domain: Account

## Summary
Introduce domain logic for Accounts to validate BillingPostalCode by country and, when valid, enrich address information via a service. Execution follows a standardized Trigger pattern: the trigger directly instantiates the AccountDomain (which extends TriggerHandler) and calls run().

## Scope
In Scope:
- Validation of Account.BillingPostalCode according to country-specific rules (initially Brazil)
- Trigger lifecycle handling in AccountDomain (before/after insert/update)
- Service call to enrich address information when the postal code is valid
- Logging and safe error handling (addError for invalid postal code)
- Recursion safety/idempotency

Out of Scope:
- UI components or flows to edit the postal code
- Additional country strategies beyond Brazil (can be added later)
- Changes to Order domain or pricing logic

## Design
- Pattern: TriggerHandler base class + concrete Domain class per sObject
- Entry point: AccountTrigger → new AccountDomain().run()
- Domain logic:
  - afterInsert/afterUpdate:
    - Validate postal code format based on BillingCountry via PostalCodeStrategyFactory
    - If valid → call AccountService to populate address info (callout)
    - If invalid → addError on the record with a user-friendly message
- Defensive programming in context setup:
  - Null-safe handling of Trigger.newMap / Trigger.oldMap for different operations
- Service:
  - IAccountService / AccountService with a method to populate address info from postal code API

## Objects and Fields
- Account
  - BillingCountry (String)
  - BillingPostalCode (String)
  - Other Billing fields may be set by the enrichment service (e.g., BillingCity, BillingState/Province)
- Platform Events / Async:
  - Not required for this feature; optional future enhancement

## Trigger Contexts
- before insert/update: Minimal validation (if needed)
- after insert/update: Postal code validation and enrichment logic
- delete/undelete: No specific behavior

## Error Handling
- Invalid postal code: addError("Invalid postal code format for country: {BillingCountry}")
- Service failures: Should be handled via try/catch inside the service layer; avoid unhandled exceptions in triggers

## Security
- Classes run with sharing where appropriate
- Queries should use WITH SECURITY_ENFORCED if accessing object fields in user mode contexts
- Use USER_MODE for DML in services where applicable (see org standards)

## Logging and Observability
- Use Logger utility to record key steps and outcomes
- Ensure logs capture the Account Ids processed and strategy decisions
- Avoid verbose logs in production paths

## Tests
Recommended classes and coverage:
- AccountDomainTest.cls
  - afterInsert/afterUpdate with BillingCountry="Brazil" and valid CEP → enrichment call path
  - invalid CEP → addError asserted; no enrichment call
  - unchanged postal code on update → no enrichment call
  - blank postal code → no validation/enrichment
  - defensive context: verify no NullPointerException in before contexts
- BrazilPostalCodeStrategyTest.cls
  - valid/invalid CEP patterns and boundary cases
- AccountServiceTest.cls
  - service call success and failure paths; assert exceptions are handled and don’t bubble up
- OrderControllerTest.cls (regression only if behavior intersects)
- OrderServiceTest.cls (regression only if behavior intersects)

Note: Align file placement under force-app/main/default/classes/tests/ for test classes (preferred). If some tests currently live outside that folder (e.g., OrderServiceTest.cls), consider moving them for consistency.

## Rollout / Backout
- Deploy classes and trigger via standard pipeline
- Backout: Disable/modify the trigger or revert the PR if critical issues arise
- No data migration required

## Links
- ADR: docs/adr/ADR-0001-trigger-framework.md
- Diagrams:
  - docs/diagrams/architecture-overview.mmd
  - docs/diagrams/postal-pattern.mmd
  - docs/diagrams/trigger-flow.mmd
- PR: Link to the feature PR introducing Account postal validation and enrichment
