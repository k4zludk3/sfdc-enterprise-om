
/**
 * @description Interface defining the contract for all Pricing Strategies.
 * Any new pricing algorithm must implement this method.
 * * Pattern: Strategy Pattern
 * @author Lucas Duque
 * @group Patterns
 */
public with sharing interface IPricingStrategy {
    Decimal calculatePrice(Decimal subTotal);
}