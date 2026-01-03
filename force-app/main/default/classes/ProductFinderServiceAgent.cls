/**
* @File Name : ProductFinderServiceAgent.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : 
* @description Invocable Apex class designed to be called by a Salesforce Service Agent (Bot) 
* in Experience Cloud. It dynamically constructs and executes a SOQL query against the 
* Product2 object to find items matching customer-provided criteria.
*
* NOTE: Replace placeholder custom field API names (e.g., 'Product_Type__c', 'Specification_Field__c') 
* with the actual field names in your Salesforce org.
*/
public with sharing class ProductFinderServiceAgent {

    // 1. Input Class: Defines the structure of data passed from the Service Agent.
    public class ProductInput {
        @InvocableVariable(required=false)
        public String productName =''; // Used for Name LIKE search or is empty
        
        @InvocableVariable(required=false)
        public String brand ='';// E.g., 'Samsung', 'Whirlpool'
        
        @InvocableVariable(required=false)
        public String productType ='';  // E.g., 'Washing Machine', 'Laptop'
        
        @InvocableVariable(required=false)
        public String specification =''; // Generic term for features/constraints (e.g., 'top-loading', 'less than 30 inches deep')
    }

    // 2. Output Class: Defines the structure of data returned to the Service Agent.
    public class ProductOutput {
        @InvocableVariable(label='Product Name')
        public String name;
        @InvocableVariable(label='Product SKU')
        public String productCode ;

        @InvocableVariable(label='Product Description')
        public String description ;
        
        @InvocableVariable(label='Matching Specifications')
        public String matchingSpecs ;
        
        @InvocableVariable(label='Success Message')
        public String message ;
    }

    /**
     * @description Main method invoked by the Service Agent. Takes a list of inputs 
     * (the Agent usually sends only one item) and returns matching products.
     * @param inputs List of ProductInput objects from the Agent.
     * @return List of ProductOutput objects.
     */
    @InvocableMethod(label='Find Products by Specification' description='Finds matching Product2 records based on customer criteria.')
    public static List<ProductOutput> findMatchingProducts(List<ProductInput> inputs) {
        List<ProductOutput> results = new List<ProductOutput>();
        
        // Safety check: The Agent typically calls this method with a list containing a single element.
        if (inputs == null || inputs.isEmpty()) {
            return results;
        }

        ProductInput input = inputs[0];
        
        // Initialize a list to hold all conditional statements
        List<String> conditions = new List<String>();

        // The 'IsActive = TRUE' is always mandatory
        conditions.add('IsActive = TRUE');
        
        // --- 3. Dynamic SOQL Construction (REWRITTEN LOGIC) ---

        // 3.1 Filter by Product Type (Mandatory field in the input)
        if (String.isNotBlank(input.productType)) {
            // **ACTION: Replace 'Product_Type__c' with your actual product type field API name.**
            conditions.add('Family LIKE \'%' + String.escapeSingleQuotes(input.productType) + '%\'');
        }

        // 3.2 Filter by Brand (Optional)
        if (String.isNotBlank(input.brand)) {
            // **ACTION: Replace 'Brand__c' with your actual brand field API name.**
            conditions.add('Brand__c = \'' + String.escapeSingleQuotes(input.brand) + '\'');
        }
        
        // 3.3 Filter by Product Name (Optional, broad search)
        // NOTE: If using an OR for Name, it's best to wrap it in parentheses 
        // or handle it as a separate query if it conflicts with other AND conditions. 
        // Keeping it as an AND for simplicity here, assuming the user expects all criteria to match.
        if (String.isNotBlank(input.productName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(input.productName) + '%\'');
        }

        // 3.4 Filter by Specification (The most complex part: features & constraints)
        if (String.isNotBlank(input.specification)) {
            String spec = String.escapeSingleQuotes(input.specification.toLowerCase());
            // **ACTION: Customize the complex logic here.**
            conditions.add('Specification__c LIKE \'%' + spec + '%\'');
        }

        // Join all conditions with ' AND '
        String whereClause = String.join(conditions, ' AND ');

        // Construct the final SOQL query
        String soqlQuery = 'SELECT Name, ProductCode, Description FROM Product2 WHERE ' + whereClause + ' LIMIT 5';
        
        System.debug('Executing SOQL: ' + soqlQuery);

        try {
            List<Product2> matchingProducts = Database.query(soqlQuery);

            if (matchingProducts.isEmpty()) {
                ProductOutput noMatch = new ProductOutput();
                noMatch.message = 'No products were found matching ALL criteria. Try refining your search.';
                results.add(noMatch);
                return results;
            }

            // 4. Process Results
            for (Product2 p : matchingProducts) {
                ProductOutput output = new ProductOutput();
                output.name = p.Name;
                output.productCode = p.ProductCode;
                output.description = p.Description;
                
                // For demonstration, we just confirm criteria met. In a real scenario, you'd 
                // pull the specific matching specs (e.g., 'Depth: 28 inches, Type: Top-Loading')
                output.matchingSpecs = 'Type: ' + input.productType + ', Brand: ' + (String.isNotBlank(input.brand) ? input.brand : 'Any');
                output.message = 'SUCCESS';
                results.add(output);
            }

        } catch (QueryException qe) {
            ProductOutput errorOutput = new ProductOutput();
            errorOutput.message = 'An error occurred during product search: ' + qe.getMessage();
            results.add(errorOutput);
        } catch (Exception e) {
            // Catch all other exceptions, like FLS/CRUD issues or dynamic SOQL errors
            ProductOutput errorOutput = new ProductOutput();
            errorOutput.message = 'A system error occurred: ' + e.getMessage();
            results.add(errorOutput);
        }

        return results;
    }
}