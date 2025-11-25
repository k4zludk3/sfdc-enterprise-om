/**
 * @description Virtual base class for Trigger Handlers.
 * Implements the ITriggerHandler interface with empty virtual methods.
 * Domain classes should extend this to avoid implementing unused methods.
 * * Pattern: Adapter / Template Method
 * @author Lucas Duque
 * @group Framework
 */
public virtual class TriggerHandler implements ITriggerHandler {
    public virtual void beforeInsert(List<SObject> newRecords) {}
    public virtual void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public virtual void beforeDelete(Map<Id, SObject> oldItems) {}
    public virtual void afterInsert(Map<Id, SObject> newItems) {}
    public virtual void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public virtual void afterDelete(Map<Id, SObject> oldItems) {}
    public virtual void afterUndelete(Map<Id, SObject> oldItems) {}
}