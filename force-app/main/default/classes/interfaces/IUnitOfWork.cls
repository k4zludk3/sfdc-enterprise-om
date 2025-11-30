public interface IUnitOfWork {
    void registerNew(SObject record);
    void registerDirty(SObject record);
    void registerDeleted(SObject record);
    void commitWork();
}