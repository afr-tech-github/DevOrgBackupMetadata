/***********************************************************************************************
This abstract class is to implement all operations in ITrigger interface with default behavior.
Any handler to implement ITrigger just extends this class and override necessary operations
instead of providing all implementation. It will help to reduce code duplication.

Modification Log
---------------------------------------------------------------------------------------
* Developer								Date			Description
---------------------------------------------------------------------------------------
* Khanh Pham (khanhphamngoc@gmail.com)	09/06/15		Initial implementation
************************************************************************************************/
public abstract class AbstractTriggerHandler implements ITrigger {
    public virtual void bulkBefore() {}
    public virtual void bulkAfter() {}

    public virtual void beforeInsert(SObject so) {}
    public virtual void beforeUpdate(SObject oldSo, SObject so) {}
    public virtual void beforeDelete(SObject so) {}

    public virtual void afterInsert(SObject so) {}
    public virtual void afterUpdate(SObject oldSo, SObject so) {}
    public virtual void afterDelete(SObject so) {}

    public virtual void bulkBeforeInsert() {}
    public virtual void bulkBeforeUpdate() {}
    public virtual void bulkBeforeDelete() {}

    public virtual void bulkAfterInsert() {}
    public virtual void bulkAfterUpdate() {}
    public virtual void bulkAfterDelete() {}


    public virtual void andFinally() {}
    
    public virtual String getHandlerName() {
        return 'AbstractTriggerHandler';
    }    
}