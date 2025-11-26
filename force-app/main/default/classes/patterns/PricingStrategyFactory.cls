/**
 * @description Factory class responsible for instantiating the correct Pricing Strategy.
 * Decouples the client (Service Layer) from the specific Algorithm implementations.
 * * Pattern: Factory Pattern
 * @author Lucas Duque
 * @group Patterns
 */
public inherited sharing class PricingStrategyFactory {

    /**
     * @description Returns the specific strategy implementation based on account type.
     * @param accountType The type of account (e.g., 'VIP', 'Standard')
     * @return IPricingStrategy The concrete implementation
     */
    public static IPricingStrategy getPricingStrategy(string customerType) {
        if (customerType?.equalsIgnoreCase('VIP')) {
            return new VipPriceStrategy();
        } else {
            return new StandardPriceStrategy();
        }
    }
}