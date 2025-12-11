public with sharing class PostalCodeStrategyFactory {

    public static IPostalCodeStrategy getStrategy(String country) {
        switch on country {
            when String.equalsIgnoreCase('Brazil') {
                return new BrazilPostalCodeStrategy();
            } 
            when else {
                return null;
                //throw new PostalCodeStrategyException('No Postal Code Strategy found for country: ' + country);
            }
        }
    }
}