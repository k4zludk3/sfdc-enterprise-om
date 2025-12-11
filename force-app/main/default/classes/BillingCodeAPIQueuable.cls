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
        // 3. Query the Accounts again to ensure data is fresh
        List<Account> accsToProcess = [SELECT Id, BillingPostalCode 
                                        FROM Account 
                                        WHERE Id IN :accountIds];
        List<Account> accsToUpdate = new List<Account>();
        Set<Id> processedAccountIds = new Set<Id>(); 

        for (Account acct : acctsToProcess) {
        
            // Checks Limits.getLimitCallouts() dynamically
            // if Salesforce increases the limit from 100 to 200 in the future, your code auto-adjusts.
            if (Limits.getCallouts() >= Limits.getLimitCallouts() - 1) {
                break;  // if it hits the limit. Stop the loop immediately. 
            }

            processedAccountIds.add(acct.Id);

            if (String.isBlank(acc.BillingPostalCode)) continue;

            // Prepare the Request
            // Remove the hyphen for the URL if ViaCEP expects numbers (ViaCEP accepts both, but cleaning is good practice)
            String cleanCep = acc.BillingPostalCode.replace('-', '').trim();

            HttpRequest req = new HttpRequest();
            // No hardcoded URLs
            // Use Named Credentials for better security and easier management, decoupling configuration from code
            req.setEndpoint('callout:ViaCEP/ws' + cleanCep + '/json/');
            req.setMethod('GET');
            req.setTimeout(12000); // 12 seconds timeout

            Http http = new Http();

            try {
                // Callout (Inside loop - see warning below)
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    // Parse the JSON response
                    // ViaCEP returns: {"cep": "01001-000", "logradouro": "Praça da Sé", ...}
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    // Check if API returned an error (ViaCEP returns { "erro": true } for invalid CEPs)
                    if (results.containsKey('erro') && (Boolean) results.get('erro')) {
                        Logger.warn('BillingCodeAPIQueuable', 'Invalid postal code: ' + cleanCep);
                        continue; // Skip to next account
                    }

                    // Update the Account fields based on API response
                    acct.BillingStreet = (String) responseMap.get('logradouro');
                    acct.BillingCity = (String) responseMap.get('localidade');
                    acct.BillingState = (String) responseMap.get('uf');
                    acct.BillingCountry = 'Brasil'; // Assuming all addresses are in Brazil for this example
                    accsToUpdate.add(acct);
                    acctsToProcess.remove(acct);
                } else {
                    Logger.error('BillingCodeAPIQueuable', 'Failed to retrieve data for postal code: ' + cleanCep + '. Status Code: ' + res.getStatusCode());
                } 
            } catch (Exception e) {
                Logger.error('BillingCodeAPIQueuable', 'Exception during callout for postal code: ' + cleanCep + '. Error: ' + e.getMessage());
            }
        }

        // Update what were finished on this transaction
        if (!accsToUpdate.isEmpty()) {
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