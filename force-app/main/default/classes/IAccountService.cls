public interface IAccountService {
    void populateAddressInfoFromPostalCodeAPI(List<Account> accounts);
    Account populateBillingCodeFromAPI(BillingCodeDTO billingCodeDTO);
}