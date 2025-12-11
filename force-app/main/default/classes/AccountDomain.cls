public with sharing class AccountDomain extends TriggerHandler{

    private List<Account> accounts;
    private Map<Id, Account> oldAccountsByIdMap;
    // Prevents multiple executions in same context
    private static Boolean ranBeforeInsert = false;
    private static Boolean ranBeforeUpdate = false;
    private static Boolean ranBeforeDelete = false;
    private static Boolean ranAfterInsert = false;
    private static Boolean ranAfterUpdate = false; 
    private static Boolean ranAfterDelete = false;

    public IAccountService service {
        get {
            if (service == null) {
                service = (IAccountService) Application.Service.newInstance(AccountService.class);
            }
            return service;
        }
        set;
    }

    // --- TRIGGER INTERFACE IMPLEMENTATION --- //

    public override void setContextTriggerRecords(Map<Id, SObject> newRecordsById, Map<Id, SObject> oldRecordsById) {
        // Guard against nulls from different trigger contexts
        this.accounts = newRecordsById == null ? new List<Account>() : (List<Account>) newRecordsById.values();
        this.oldAccountsByIdMap = oldRecordsById == null ? new Map<Id, Account>() : (Map<Id, Account>) oldRecordsById;
    }

    public override void afterInsert() {
        if (!ranAfterInsert) {
            ranAfterInsert = true;
            Logger.info('AccountDomain', 'After Insert Trigger executed for Accounts: ' + this.accounts);
            this.validateAccountPostalCodes(this.accounts);
        }
    }

    public override void afterUpdate() {
        if (!ranAfterUpdate) {
            ranAfterUpdate = true;
            this.validateAccountPostalCodes(this.accounts, this.oldAccountsByIdMap);
        }
    }

    // --- DOMAIN LOGIC METHODS --- //

    private void validateAccountPostalCodes(List<Account> accts) {
        List<Account> acctsToUpdate = new List<Account>();
        for (Account acct : accts) {   
            if (String.isNotBlank(acct.BillingPostalCode) && String.isNotBlank(acct.BillingCountry)) {
                IPostalCodeStrategy strategy = PostalCodeStrategyFactory.getStrategy(acct.BillingCountry);
                if (strategy != null) {
                    Boolean validPostalCode = strategy.isValidPostalCode(acct.BillingPostalCode);
                    if (validPostalCode) {
                        acctsToUpdate.add(acct);
                    } else {
                        acct.addError('Invalid postal code format for country: ' + acct.BillingCountry);
                    }   
                }
            }
        }

        if(!acctsToUpdate.isEmpty()) {
            this.calloutPostalCodeService(acctsToUpdate);
        }
    }

    // Overloaded method for update context, loosely coupled for reusability 
    private void validateAccountPostalCodes(List<Account> accts, Map<Id, Account> oldAcctByIdMap) {
        List<Account> acctsToUpdate = new List<Account>();
        for (Account acctNew : accts) {
            Account oldAccount = oldAcctByIdMap.get(acctNew.Id);
            if (acctNew.BillingPostalCode != null && acctNew.BillingPostalCode != oldAccount.BillingPostalCode) {
                acctsToUpdate.add(acctNew);
            }
        }

        if(!acctsToUpdate.isEmpty()) {
            this.validateAccountPostalCodes(acctsToUpdate);
        }
    }

    private void calloutPostalCodeService(List<Account> acctsUpdate) {
        this.service.populateAddressInfoFromPostalCodeAPI(acctsUpdate);
    }
}