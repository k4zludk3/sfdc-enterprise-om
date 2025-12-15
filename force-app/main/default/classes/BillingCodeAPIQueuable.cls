public with sharing class BillingCodeAPIQueuable implements Queueable, Database.AllowsCallouts {
    
    // State variable to hold the IDs passed from the Service
    private Set<Id> accountIds;
    
    // Constructor: Receives the IDs when the class is instantiated
    // Do not pass the List<Account> with all the fields into the Queueable. 
    // If the record changes between the Trigger firing and the Queueable running, you might have stale data.
    public BillingCodeAPIQueuable(Set<Id> acctIds) {
        this.accountIds = acctIds;
    }

    public void execute(QueueableContext context) {
        List<Account> acctsToUpdate = new List<Account>();
        Set<Id> processedAccountIds = new Set<Id>();
        // Query the Accounts again to ensure data is fresh 
        IAccountSelector selector = (IAccountSelector) Application.Selector.newInstance(AccountSelector.class);
        List<Account> acctsToProcess = selector.selectAccountsById(this.accountIds);

        for (Account acct : acctsToProcess) {
        
            // Checks Limits.getLimitCallouts() dynamically
            // if Salesforce increases the limit from 100 to 200 in the future, your code auto-adjusts.
            if (Limits.getCallouts() >= Limits.getLimitCallouts() - 1) {
                break;  // if it hits the limit. Stop the loop immediately. 
            }

            processedAccountIds.add(acct.Id);

            if (String.isBlank(acct.BillingPostalCode)) continue;

            // Prepare the Request
            // Remove the hyphen for the URL if ViaCEP expects numbers (ViaCEP accepts both, but cleaning is good practice)
            String cleanCep = acct.BillingPostalCode.replace('-', '').trim();

            BillingCodeCalloutService calloutService = new BillingCodeCalloutService(cleanCep, 'GET');

            //Map<String, Object> response = (Map<String, Object>) calloutService.parseResponse();
            BillingCodeDTO billingCodeInfo = (BillingCodeDTO) JSON.deserialize(calloutService.makeCallout(), BillingCodeDTO.class);             

            if (billingCodeInfo != null) {
                // Update the Account fields based on API response
                IAccountService service = (AccountService) Application.Service.newInstance(AccountService.class);
                Account acctUpdate = service.populateBillingCodeFromAPI(billingCodeInfo);
                acctsToUpdate.add(acct);
            } else {
                Logger.warning('BillingCodeAPIQueuable', 'No data returned for postal code: ' + cleanCep);
            }

            // Update what were finished on this transaction
            if (!acctsToUpdate.isEmpty()) {
                update acctsToUpdate;
            }

            // Set subtraction 
            // Remove the IDs we just processed from the main list
            accountIds.removeAll(processedAccountIds);

            // If there are remaining IDs, enqueue another job
            // !Test.isRunningTest() prevents infinite loops during Unit Tests (which fail if you chain jobs without protection).
            if (!accountIds.isEmpty() && !Test.isRunningTest()) {
                System.enqueueJob(new BillingCodeAPIQueuable(accountIds));
            }
        }
    }
}