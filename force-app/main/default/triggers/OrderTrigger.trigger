trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Pass a new instance of the Domain
    // The Dispatcher handles the complexity. 
    TriggerDispatcher.run(new OrderDomain());
}