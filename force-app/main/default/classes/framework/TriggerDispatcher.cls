
/**
 * @description Central dispatcher for the Trigger Framework.
 * Responsible for detecting the current trigger context (Insert, Update, Delete)
 * and invoking the appropriate method on the specific Domain handler.
 * * Pattern: Dispatcher Pattern
 * Security: Inherited Sharing (Adapts to the caller's context)
 * * @author Lucas Duque
 * @group Framework
 */
public inherited sharing class TriggerDispatcher {

    /**
     * @description Main entry point. called by the Trigger to route logic.
     * @param handler An instance of the Domain class (must implement ITriggerHandler)
     */
    public static void run(ITriggerHandler handler) {
        // Detect the current context automatically
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.oldMap);
            }
            when AFTER_INSERT {
                handler.afterInsert(Trigger.newMap);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_DELETE {
                handler.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.oldMap);
            }
        }
    }
}