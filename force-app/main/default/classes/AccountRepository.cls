public with sharing class AccountRepository extends AbstractRepository {
    
    // Child class must implement the abstract method
    public override void updateRecords(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        } 
        try {
            update records;
        } catch (DmlException e) {
            //Logger.error('AccountRepository.updateRecords', e);
            throw e;
        }
    }
}