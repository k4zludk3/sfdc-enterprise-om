public interface IAccountSelector {
    List<Account> selectAccountsById(Set<Id> accountIds);
}