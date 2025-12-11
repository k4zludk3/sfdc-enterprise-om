public inherited sharing class BrazilPostalCodeStrategy implements IPostalCodeStrategy{
    
    public Boolean isValidPostalCode(String postalCode) {
        // Brazilian postal code format: 00000-000
        String postalCodePattern = '^[0-9]{5}-[0-9]{3}$';
        Pattern pattern = Pattern.compile(postalCodePattern);
        Matcher matcher = pattern.matcher(postalCode);
        return matcher.matches();
    }
}