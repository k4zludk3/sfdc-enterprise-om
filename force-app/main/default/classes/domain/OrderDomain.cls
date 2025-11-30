public inherited sharing class OrderDomain extends TriggerHandler {

    // The domain holds the data context for the trigger
    private List<Order> orders;
    private Map<Id, Order> oldOrderByIdMap;

    // Service instance for business logic operations
    // LAZY LOADING: Define the Service ONCE
    // We use a 'getter' so it initializes only when we need it.
    private IOrderService service {
        get {
            if (service == null) {
                service = Application.Service.newInstance(OrderService.class);
            }
        }
        set;
    }

    // Constructor to initialize the domain with trigger context //

    // Constructor A: For the Trigger (Clean & Easy)
    // "this(...)" calls Constructor B.
    public OrderDomain() {
        this((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }

    // Constructor B: For Unit Tests (Testable)
    // We can inject fake lists here
    public OrderDomain(List<Order> newRecords, Map<Id, Order> oldRecordMap) {
        this.order = newRecords;
        this.oldOrderByIdMap = oldRecordMap;
    }

    // --- TRIGGER INTERFACE IMPLEMENTATION --- //

    public override void beforeInsert(List<SObject> newRecords) {
        validateActivedOrders(this.orders);
        this.service.calculatePricing(this.orders);
    }

    public override void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        validateActivedOrders(this.orders);
        this.service.calculatePricing(this.orders);
    }

    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Publish event if order status changed to 'Finalized'
        this.service.publishOrderFinalized(validateUpdatedStatus(ordersNew, oldItems));
    }

    // --- DOMAIN LOGIC METHODS --- //

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
}