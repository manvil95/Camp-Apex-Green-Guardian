/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Handlers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Trigger Handler on CAMPX__Garden__c.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_GardenHandler extends TriggerHandler{

    private List<CAMPX__Garden__c>     listNew;
    private List<CAMPX__Garden__c>     listOld;
    private Map<Id, CAMPX__Garden__c>  mapNew;
    private Map<Id, CAMPX__Garden__c>  mapOld;
    private String                     objectHandler;

    public TRG_CAMPX_GardenHandler ()  {
        this.listNew        = Trigger.new;
        this.listOld        = Trigger.old;
        this.mapOld         = (Map<Id, CAMPX__Garden__c>) Trigger.oldMap;
        this.mapNew         = (Map<Id, CAMPX__Garden__c>) Trigger.newMap;
        this.objectHandler  = 'CAMPX__Garden__c';
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description Handler method on before insert.
     * @comments
    **************************************************************************************************/
    public override void beforeInsert() {
        TRG_CAMPX_GardenHelper.initializeGardenFieldsUponRecordCreation(this.listNew);
        TRG_CAMPX_GardenHelper.setUnsetManagerStartDate(this.listNew, null);
        TRG_CAMPX_GardenHelper.calculateCapacity(this.listNew, null);
        TRG_CAMPX_GardenHelper.calculateHealthIndex(this.listNew, null);
        TRG_CAMPX_GardenHelper.setGardenStatus(this.listNew, null);
    }
    
    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description Handler method on after insert.
     * @comments
    **************************************************************************************************/
    public override void afterInsert() {
        TRG_CAMPX_GardenHelper.createTaskForNewGardeningManagers(this.listNew, null);
    }
    
    /**************************************************************************************************
     * @author      manvil95
     * @date        24/05/2024
     * @modifiedBy
     * @description Handler method on before update.
     * @comments
    **************************************************************************************************/
    public override void beforeUpdate() {
        TRG_CAMPX_GardenHelper.setUnsetManagerStartDate(this.listNew, this.mapOld);
        TRG_CAMPX_GardenHelper.calculateCapacity(this.listNew, this.mapOld);
        TRG_CAMPX_GardenHelper.calculateHealthIndex(this.listNew, this.mapOld);
        TRG_CAMPX_GardenHelper.setGardenStatus(this.listNew, this.mapOld);
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description Handler method on after update.
     * @comments
    **************************************************************************************************/
    public override void afterUpdate() {
        TRG_CAMPX_GardenHelper.createTaskForNewGardeningManagers(this.listNew, this.mapOld);
        TRG_CAMPX_GardenHelper.reassignTaskWhenManagerChanges(this.listNew, this.mapOld);
        TRG_CAMPX_GardenHelper.deleteTaskWhenManagerIsUnassigned(this.listNew, this.mapOld);
    }
}