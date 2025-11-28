/**
 * @description Implementation of the Unit of Work pattern.
 * Manages lists of records to insert/update/delete and commits them in a single transaction.
 * Implements IUnitOfWork for Mocking capabilities.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class UnitOfWork implements IUnitOfWork {
    
    private List<SObject> newRecords = new List<SObject>();
    private List<SObject> dirtyRecords = new List<SObject>();
    private List<SObject> deletedRecords = new List<SObject>();

    // --- REGISTRATION METHODS --- //

    public void registerNew(SObject record) {
        if (record != null) {
            newRecords.add(record);
        }
    }

    public void registerDirty(SObject record) {
        if (record != null) {
            dirtyRecords.add(record);
        }
    }

    public void registerDeleted(SObject record) {
        if (record != null) {
            deletedRecords.add(record);
        }
    }

    // --- COMMIT METHOD --- //

    public void commitWork() {
        // Savepoints ensure "All or Nothing" atomicity
        SavePoint sp = Database.setSavePoint();

        try {

            if (!newRecords.isEmpty()) {
                insert newRecords;
            }
            if (!dirtyRecords.isEmpty()) {
                update dirtyRecords;
            }
            if (!deletedRecords.isEmpty()) {
                delete deletedRecords;
            }

        } catch (Exception e) {
            // Rollback ANY changes if one fails
            Database.rollback(sp);
            Logger.error('UnitOfWork.commitWork', e);
            throw e;
        }
    }

}