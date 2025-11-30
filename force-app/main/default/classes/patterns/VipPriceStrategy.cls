/**
 * @description Concrete implementation of Pricing Strategy for VIP Customers.
 * Applies a 15% discount.
 * * @author Lucas Duque
 * @group Patterns
 */
public with sharing class VipPriceStrategy implements IPricingStrategy {
    public Decimal calculatePrice(Decimal subTotal) {
        // VIP customers get a 15% discount
        return subTotal * 0.85;
    }
}