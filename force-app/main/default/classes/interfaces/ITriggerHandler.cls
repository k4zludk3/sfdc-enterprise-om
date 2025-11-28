/**
 * @description Interface defining the contract for Trigger Handlers.
 * Define methods for each trigger context
 * @author Lucas Duque
 * @group Framework
 */
public Interface ITriggerHandler {
    void beforeInsert(List<SObject> newRecords);
    void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    void beforeDelete(Map<Id, SObject> oldMap);
    void afterInsert(Map<Id, SObject> newMap);
    void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    void afterDelete(Map<Id, SObject> oldMap);
    void afterUndelete(Map<Id, SObject> oldMap);
}