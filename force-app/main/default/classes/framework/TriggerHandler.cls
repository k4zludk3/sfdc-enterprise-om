/**
 * @description Virtual base class for Trigger Handlers.
 * Implements the ITriggerHandler interface with empty virtual methods.
 * Domain classes should extend this to avoid implementing unused methods.
 * * Pattern: Adapter / Template Method
 * @author Lucas Duque
 * @group Framework
 */
@SuppressWarnings('PMD.EmptyStatementBlock')
public abstract class TriggerHandler {
    public abstract void setContextTriggerRecords(Map<Id, SObject> newRecordsById, Map<Id, SObject> oldRecordsById);
    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
    public virtual void beforeDelete() {}
    public virtual void afterInsert() {}
    public virtual void afterUpdate() {}
    public virtual void afterDelete() {}
    public virtual void afterUndelete() {}
    
    public virtual void run() {
        
        this.setContextTriggerRecords(Trigger.newMap, Trigger.oldMap);

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }
}