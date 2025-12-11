// Abstract class cannot be instantiated diectly
// Use an abstract class when you want to force inheritors to provide their own specific implementation for certain methods, 
// guaranteeing a particular structure or contract. 
// Use virtual class when you want to provide a default implementation that can be optionally overridden by subclasses.
public abstract class AbstractRepository {

    // abstract method can't have a body
    // child classes must implement this method
    public abstract void updateRecords(List<SObject> records);

    public virtual void save(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        } 
        try {
            upsert records;
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.save', e);
            System.debug('Error saving record: ' + e.getMessage());
            throw e;
        }
    }

    // overloaded save method for single SObject
    public virtual void save(SObject record) {
        if (record == null) {
            return;
        }
        try {
            upsert record;
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.save', e);
            System.debug('Error saving record: ' + e.getMessage());
            throw e;
        }
    }

    public virtual void save(List<SObject> records, Schema.SObjectField externalId) {
        if (records == null || records.isEmpty()) {
            return;
        } 
        try {
            Database.upsert(records, externalId);
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.save', e);
            System.debug('Error saving record: ' + e.getMessage());
            throw e;
        }
    }

    public virtual void save(SObject record, Schema.SObjectField externalId) {
        if (record == null) {
            return;
        }
        try {
            Database.upsert(record, externalId);
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.save', e);
            System.debug('Error saving record: ' + e.getMessage());
            throw e;
        }
    }

    public virtual void remove(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        } 
        try {
            delete records;
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.delete', e);
            System.debug('Error deleting record: ' + e.getMessage());
            throw e;
        }
    }

    public virtual void remove(SObject record) {
        if (record == null) {
            return;
        }
        try {
            delete record;
        } catch (DmlException e) {
            //Logger.error('AbstractRepository.delete', e);
            System.debug('Error deleting record: ' + e.getMessage());
            throw e;
        }
    }
}