/**
 * @description Service Layer for Order logic. Contains pure business logic.
 * Acts as the "Chef" - receives clean data and executes operations.
 * @author Lucas Duque
 * @group Service
 */
public with sharing class OrderService {
    /**
     * Processes a list of orders: Validates them and calculates dynamic pricing.
     * @param orders List of Orders from Lightning Component
    */
    @AuraEnabled
    public static void processOrders(List<Order> orders) {
        try {

            Logger.info('OrderService', 'Starting order processing for ' + orders.size() + ' orders.');

            // Domain validation
            OrderDomain.validate(orders);

            // Pricing strategy application
            List<Order> ordersUpdate = this.calculatePricing(orders);

            Database.SaveResult[] svrs = Database.update(ordersUpdate, false);

            String errorMessages = '';
            for(Database.SaveResult svr : svrs) {
                if(!svr.isSuccess()) {
                    for(Database.Error err : svr.getErrors()) {
                        errorMessages += 'Error updating Order Id ' + svr.getId() + ': ' + err.getMessage() + '\n';
                    }
                }
            }

            if(errorMessages != '') {
                throw new AuraHandledException('Errors occurred during order processing:\n' + errorMessages);
            }

            Logger.info('OrderService', 'Completed order processing successfully.');

        } catch (Exception e) {
            Logger.error('OrderService.processOrders', e);
            throw AuraHandledException(e.getMessage());
        }
    }

    /**
     * Processes pricing for a list of orders.
     * @param orders List of Orders from Trigger or API
    */
    public static List<Order> calculatePricing(List<Order> orders) {
        try {
            Logger.info('OrderService', 'Starting pricing calculation for ' + orders.size() + ' orders.');

            for (Order o : orders) {
                String customerType = o.Customer_Type__c; // Assume a custom field indicating customer type
                IPricingStrategy priceStrategy = PricingStrategyFactory.getPricingStrategy(customerType);
                o.Description = 'Final price ' + priceStrategy.calculatePrice(o.Subtotal__c); // Just an example field
            }

            Logger.info('OrderService', 'Completed pricing calculation successfully.');

        } catch (Exception e) {
            Logger.error('OrderService.calculatePricing', e);
            throw new CustomException('An error occured: ' + e.getMessage() + '\n ' + e.getStackTraceString()); // Rethrow to ensure transaction rollback  
        }

        return orders;
    }
}