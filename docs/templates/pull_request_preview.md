# Feature: Introduce Account domain, postal code strategy, and trigger integration; refine Order domain/service/tests

## Summary
This pull request adds a full Account domain layer with trigger wiring and supporting services/utilities, introduces a Postal Code strategy framework (including a Brazil implementation), and adds an async queuable for billing code integration. It refines existing Order domain/service/test classes and framework utilities to align with enterprise patterns and improve maintainability.

## Related Issues
*   Closes #[Issue Number]
*   Relates to:
    - docs/features/FEATURE-0007-account-postal-code-validation.md
    - docs/adr/ADR-0001-trigger-framework.md
    - Diagrams:
        - docs/diagrams/architecture-overview.mmd
        - docs/diagrams/postal-pattern.mmd
        - docs/diagrams/trigger-flow.mmd

## Changes Made
*   New Apex classes (and metadata):
    * AccountDomain.cls: Trigger-aware domain handler implementing TriggerHandler lifecycle and recursion guards.
    * AccountService.cls / IAccountService.cls: Service abstraction for Account operations to encapsulate business logic.
    * BillingCodeAPIQueuable.cls: Asynchronous job for external billing-code related processing.
    * Postal Code framework:
        * IPostalCodeStrategy.cls: Strategy interface for postal code logic.
        * BrazilPostalCodeStrategy.cls: Country-specific validation/normalization strategy.
        * PostalCodeStrategyFactory.cls: Factory selecting appropriate country strategy.
*   New Trigger and metadata:
    * AccountTrigger.trigger (+ -meta.xml): Dispatches to AccountDomain for all contexts.
*   Modified classes:
    * domain/OrderDomain.cls: Adjusted domain logic (e.g., lifecycle handling or dependency interactions).
    * framework/TriggerDispatcher.cls and framework/TriggerHandler.cls: Improvements to trigger dispatch pattern and lifecycle consistency.
    * service/OrderService.cls: Refactor/adjustments to align with domain/service patterns and new strategy usage.
    * classes/tests/OrderControllerTest.cls: Updated tests to reflect new/changed behavior.
    * utils/RecursionCheck.cls: Tuning recursion guard logic to ensure idempotent trigger runs.

## Rationale (The "Why")
* Establishes a clear domain-service pattern for Account-related logic, mirroring the enterprise design used for Orders.
* Encapsulates country-specific postal code behavior behind a strategy/factory, enabling scalable internationalization without scattered conditionals.
* Introduces async processing (queuable) for external billing code operations to improve transaction health and scalability.
* Aligns trigger handling to a consistent dispatcher/handler approach, with recursion safety and single-responsibility boundaries.
* Refines Order code to ensure consistency with the expanded domain pattern and improves testability.

## Testing
1. Deploy to a scratch/sandbox org: `sf project deploy start --source-dir force-app`.
2. Create/update/delete Account records to exercise AccountTrigger and AccountDomain flows; confirm no recursion and correct side effects (logs, related updates).
3. Validate postal code behavior:
   - Set Account BillingCountry="Brazil" and provide a CEP; verify BrazilPostalCodeStrategy runs (validation/normalization).
4. Enqueue BillingCodeAPIQueuable via anonymous apex or by the service path; verify job runs and completes without unhandled exceptions.
5. Run local tests to verify Order and controller changes: `sf apex run test --test-level RunLocalTests` and confirm `OrderControllerTest` passes.
6. Optional: Add tests for the new postal code strategies and Account service methods; verify coverage and assertions.

## Screenshots/Visuals (if applicable)
N/A – backend/domain and trigger logic. No UI changes in this PR.

## Areas for Reviewer Scrutiny
* Trigger lifecycle coverage in `AccountDomain` (before/after hooks) and recursion guard correctness.
* Strategy selection logic in `PostalCodeStrategyFactory` (default behavior when country not supported).
* `BillingCodeAPIQueuable` error handling and retry/idempotency considerations.
* Any `OrderDomain` and `OrderService` changes that could affect existing automations or integrations.

## Checklist
*   [x] My code follows the project's style guidelines.
*   [x] I have performed a self-review of my own code.
*   [ ] I have added tests that prove my fix is effective or my feature works (recommend tests for AccountService, postal strategies, and queuable).
*   [x] I have updated the documentation where necessary (see links above).
*   [x] I have resolved all merge conflicts.

---

### Docs & Diagrams Changes (this PR)
- Added:
  - `docs/adr/ADR-0001-trigger-framework.md`
  - `docs/features/FEATURE-0007-account-postal-code-validation.md`
  - `docs/runbooks/RUNBOOK-account.md`
  - `docs/diagrams/architecture-overview.mmd`
  - `docs/diagrams/trigger-flow.mmd`
  - `docs/diagrams/postal-pattern.mmd`
- Replaced/Consolidated (superseded by the new structure):
  - `docs/architecture.md` → covered by `docs/diagrams/architecture-overview.mmd` and linked from Feature/ADR
  - `docs/architecture-flow.mmd` → consolidated into `docs/diagrams/architecture-overview.mmd`
  - `docs/architecture-trigger.mmd` → replaced by `docs/diagrams/trigger-flow.mmd`
  - `docs/architecture-postal.mmd` → replaced by `docs/diagrams/postal-pattern.mmd`
  - `docs/architecture-sequence.mmd` and `docs/architecture-pricing.mmd` → can be reintroduced under `docs/diagrams/` as needed
