public inherited sharing class OrderDomain extends TriggerHandler {

    // --- TRIGGER INTERFACE IMPLEMENTATION ---

    public override void beforeInsert(List<SObject> newRecords) {
        validate((List<Order>) orders);
        calculatePricing((List<Order>) newItems.values());
    }

    public override void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        validate((List<Order>) newItems.values());
        calculatePricing((List<Order>) newItems.values());
    }

    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Cast SObjects to Orders
        List<Order> ordersNew = (List<Order>) newItems.values();
        Map<Id, Order> oldOrderMap = (Map<Id, Order>) oldItems;

        // Publish event if order status changed to 'Finalized'
        OrderService.publishOrderFinalized(validateUpdatedStatus(ordersNew, oldItems));
    }

    // --- DOMAIN LOGIC METHODS ---

    public static void validateActivedOrders(List<Order> orders) {
        for (Order o : orders) {
            if (o.Status?.equalsIgnoreCase('Actived') && o.TotalAmount == null) {
                o.addError('Total Amount must be specified when the order is activated.');
            }
        }
    }

    public static List<Order> validateUpdatedStatus(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        List<Order> validOrdersStatusUpdated = new List<Order>();

        for (Order o : newOrders) {
            Order oldOrder = oldOrderMap.get(o.Id);
            if (oldOrder != null && !oldOrder.Status.equalsIgnoreCase(o.Status)) {
                // Example rule: Prevent changing status back to 'Draft' once it's 'Finalized'
                validOrdersStatusUpdated.add(o);
                /*if (o.Status.equalsIgnoreCase('Draft') && oldOrder.Status.equalsIgnoreCase('Finalized')) {
                    o.addError('Cannot revert status from Finalized to Draft.');
                }*/
            }
        }

        return validOrdersStatusUpdated;
    }

    private static void calculatePricing(List<Order> orders) {
        OrderService.calculatePricing(orders);
    }
}