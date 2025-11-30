public with sharing class OrderController {
    
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
    }
}