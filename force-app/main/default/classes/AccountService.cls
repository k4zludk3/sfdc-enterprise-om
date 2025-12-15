public with sharing class AccountService implements IAccountService {
 
    public void populateAddressInfoFromPostalCodeAPI(List<Account> accounts) {
        Set<Id> acctsIds = new Map<Id, Account>(accounts).keySet();
        if (acctsIds.isEmpty()) {
            System.enqueueJob(new BillingCodeAPIQueuable(acctsIds));   
        }
    }

    public Account populateBillingCodeFromAPI(BillingCodeDTO billingCodeDTO) {
        Account acct = new Account();
        acct.BillingStreet = billingCodeDTO.logradouro;
        acct.BillingCity = billingCodeDTO.localidade;
        acct.BillingState = billingCodeDTO.uf;
        acct.BillingPostalCode = billingCodeDTO.cep;
        return acct;
    }
}