public inherited sharing class OrderSelector implements IOrderSelector{
    
    // In a full fflib, this would override getSObjectFieldList()
    
    public List<Order> selectRecentOrders(Integer recordLimit) {
        List<Order> orders = [
            SELECT Id, OrderNumber, TotalAmount, Status 
            FROM Order 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC 
            LIMIT :recordLimit
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, orders);

        return (List<Order>) decision.getRecords();
    }
}