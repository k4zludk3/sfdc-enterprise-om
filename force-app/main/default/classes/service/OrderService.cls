/**
 * @description Service Layer for Order logic. Contains pure business logic.
 * Acts as the "Chef" - receives clean data and executes operations.
 * @author Lucas Duque
 * @group Service
 */
public with sharing class OrderService implements IOrderService {


    /**
     * @description Publishes a Platform Event to decouple the ERP integration.
     * Uses 'Fire and Forget' pattern.
     * @param orders List of activated orders
     */
    public void publishOrderFinalized(List<Order> orders) {
        List<Order_Notification__e> notifications = new List<Order_Notification__e>();

        for (Order ord : orders) {
            // Only notify for Activated orders
            if (ord.Status == 'Activated') {
                notifications.add(new Order_Notification__e(
                    Order_Id__c = ord.Id,
                    Type__c = 'ERP_SYNC'
                ));
            }
        }

        if (!notifications.isEmpty()) {
            // EventBus.publish is the API to fire events
            List<Database.SaveResult> results = EventBus.publish(notifications);
            
            // Check for publishing errors (Best Practice)
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    // In a real app, log this to a custom error object
                    Logger.error('OrderService.publish', new DmlException(sr.getErrors()[0].getMessage()));
                }
            }
        }
    }

      /**
     * Processes pricing for a list of orders.
     * @param orders List of Orders from Trigger or API
    */
    public List<Order> calculatePricing(List<Order> orders) {
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
}