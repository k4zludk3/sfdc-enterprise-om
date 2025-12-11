public with sharing class AccountService implements IAccountService {
 
    public void populateAddressInfoFromPostalCodeAPI(List<Account> accounts) {
        Set<Id> acctsIds = new Map<Id, Account>(accounts).keySet();
        if (acctsIds.isEmpty()) {
            System.enqueueJob(new BillingCodeAPIQueuable(acctsIds));   
        }
    }
}