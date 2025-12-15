public abstract class ICallout {
    protected String endpoint, body, method;
    protected Integer timeout;
    protected Map<String, String> headers;
    protected HttpResponse response;
    
    public String makeCallout() {
        try {
            HttpRequest req = this.buildRequest(this.endpoint, this.method, this.body, this.timeout, this.headers);
            Http http = new Http();
            this.response = http.send(req);
            
            if (this.response.getStatusCode() != 200) {
                Logger.warning('ICallout', 'Failed to retrieve data. Status Code: ' + this.response.getStatusCode());
                Logger.warning('ICallout', 'Failed to retrieve data.' + this.response.getBody());
                return null;
            }
            
            Logger.info('ICallout', 'Successfully retrieved data. Status Code: ' + this.response.getBody());
            return this.response.getBody();

        } catch (Exception e) {
            Logger.error('ICallout exception during service callout: ', e);
            return null;
        }
    }

    virtual HttpRequest buildRequest(String endpoint, String method, String body, Integer timeout, Map<String, String> headers) {
        HttpRequest req = new HttpRequest();
        String resource = endpoint + body;
        req.setEndpoint(resource);
        req.setMethod(method);
        req.setTimeout(timeout);

        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }

        return req;
    }

    virtual Map<String, Object> parseResponse() {
        if (this.response == null) return null;
        if (this.response.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(this.response.getBody());
        } else {
            Logger.warning('ICallout', 'Failed to retrieve data. Status Code: ' + this.response.getStatusCode());
            return null;
        }
    }
}