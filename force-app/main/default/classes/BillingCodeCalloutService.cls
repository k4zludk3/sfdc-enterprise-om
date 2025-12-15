public with sharing class BillingCodeCalloutService extends ICallout {
    
    public BillingCodeCalloutService(String body, String method) {
        // No hardcoded URLs
        // Use Named Credentials for better security and easier management, decoupling configuration from code
        this.endpoint = 'callout:ViaCEP/ws/';
        this.timeout = 12000; // 12 seconds
        this.method = method;
        this.body = body + '/json';
    }
}