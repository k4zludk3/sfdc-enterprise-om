public with sharing class OrderController {
    /**
     * Existing method assumed by orderList LWC to fetch recent orders.
     * Keeping signature as-is (implementation may already exist in repo).
     */
    @AuraEnabled(cacheable=true)
    public static List<Order> getRecentOrders() {
         try {
            // ARCHITECT PATTERN:
            // Delegate the SOQL to the Selector layer
            // Ask the Application for the implementation of IOrdersSelector.
            // The Controller doesn't know if it's getting the Real one or a Mock.
            IOrderSelector selector = (IOrderSelector) Application.Selector.newInstance(OrderSelector.class);
            return selector.selectRecentOrders(5);
            
        } catch (Exception e) {
            Logger.error('OrderController.getRecentOrders', e);
            throw new AuraHandledException(e.getMessage());
        }
        
        // If an implementation already exists in your repo, the deployment formatter will merge.
        // Provide a safe default to prevent compile errors if missing.
        /*return [
            SELECT Id, OrderNumber, Status, AccountId, EffectiveDate, TotalAmount
            FROM Order
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];*/
    }

    /**
     * Returns a single Order record with common fields plus related Account.Name and Owner.Name
     * for detail display in the new orderDetails LWC.
     */
    @AuraEnabled(cacheable=true)
    public static Order getOrderDetails(Id orderId) {
        if (orderId == null) {
            throw new AuraHandledException('orderId is required');
        }
        Order result = [
            SELECT Id,
                   OrderNumber,
                   Status,
                   EffectiveDate,
                   TotalAmount,
                   AccountId,
                   Account.Name,
                   OwnerId,
                   Owner.Name,
                   CreatedDate,
                   LastModifiedDate
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];
        return result;
    }
}
