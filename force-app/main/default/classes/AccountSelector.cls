public with sharing class AccountSelector implements IAccountSelector {
    public List<Account> selectAccountsById(Set<Id> accountIds) {
        return [SELECT Id, Name, BillingPostalCode 
                FROM Account 
                WHERE Id IN :accountIds];
    }
}