/**
 * @description Interface defining the contract for Trigger Handlers.
 * Define methods for each trigger context
 * @author Lucas Duque
 * @group Framework
 */
public Interface ITriggerHandler {
    void beforeInsert(List<SObject> newRecords);
    void beforeUpdate(Map<Id, SObject> newRecordsById, Map<Id, SObject> oldRecordsById);
    void beforeDelete(Map<Id, SObject> oldRecordsById);
    void afterInsert(Map<Id, SObject> newRecordsById);
    void afterUpdate(Map<Id, SObject> newRecordsById, Map<Id, SObject> oldRecordsById);
    void afterDelete(Map<Id, SObject> oldRecordsById);
    void afterUndelete(Map<Id, SObject> oldRecordsById);
}