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

    // --- DOMAIN LOGIC METHODS ---

    public static void validate(List<Order> orders) {
        for (Order o : orders) {
            if (o.Status?.equalsIgnoreCase('Actived') && o.TotalAmount == null) {
                o.addError('Total Amount must be specified when the order is activated.');
            }
        }
    }

    private static void calculatePricing(List<Order> orders) {
        OrderService.calculatePricing(orders);
    }
}