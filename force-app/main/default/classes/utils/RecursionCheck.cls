/**
 * @description Utility to prevent infinite Trigger loops (Recursion).
 * @author Lucas Duque
 * @group Utils
 */
public with sharing class RecursionCheck {
    private static set<Id> processedRecords = new Set<Id>();

    public static Boolean isRecordProcessed(Id recordId) {
        /**
         * Checks if a record has already been processed in this transaction.
         * @return true if we should SKIP processing.
        */
        if (processedRecords.contains(recordId)) {
            return true;
        } else {
            processedRecords.add(recordId);
            return false;
        }
    }
}