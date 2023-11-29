public with sharing class FlsService {

    public static void doInsert(List<SObject> entities) {
        checkFls(AccessType.CREATABLE, entities);
        insert entities;
    }

    public static void doUpdate(List<SObject> entities) {
        checkFls(AccessType.UPDATABLE, entities);
        update entities;
    }

    public static void doUpsert(List<SObject> entities) {
        checkFls(AccessType.UPSERTABLE, entities);
        upsert entities;
    }

    public static void doInsert(SObject entity) {
        checkFls(AccessType.CREATABLE, entity);
        insert entity;
    }

    public static void doUpdate(SObject entity) {
        checkFls(AccessType.UPDATABLE, entity);
        update entity;
    }

    public static void doUpsert(SObject entity) {
        checkFls(AccessType.UPSERTABLE, entity);
        update entity;
    }
    
    public static void doDelete(SObject entity) {
        if (!entity.getSObjectType().getDescribe().isDeletable()) {
            throw new SecurityException('No delete permission on ' + entity);
        }

        delete entity;
    }

    public static void doDelete(List<SObject> entities) {
        for (SObject entity : entities) {
            if (!entity.getSObjectType().getDescribe().isDeletable()) {
                throw new SecurityException('No delete permission on ' + entity);
            }
        }
        
        delete entities;
    }

    public static SObjectAccessDecision checkFls(AccessType accessType, List<SObject> entities) {
        List<SObject> listToStrip = new List<SObject>();

        for (SObject entity : entities) {
            if (!entity.getSObjectType().getDescribe().isCustomSetting()) {
                listToStrip.add(entity);
            }
        }

        SObjectAccessDecision decision = Security.stripInaccessible(accessType, listToStrip, true);
        // if (!decision.getModifiedIndexes().isEmpty()) {
        //     throw new SecurityException(JSON.serialize(decision.getRemovedFields()));
        // }
        return decision;
    }

    public static SObjectAccessDecision checkFls(AccessType accessType, SObject entity) {
        return checkFls(accessType, new List<SObject> { entity });
    }

    public class SecurityException extends Exception{}
}