/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Triggers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Trigger Handler on CAMPX__Plant__c.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_PlantHandler extends TriggerHandler {
    
    private List<CAMPX__Plant__c>     listNew;
    private List<CAMPX__Plant__c>     listOld;
    private Map<Id, CAMPX__Plant__c>  mapNew;
    private Map<Id, CAMPX__Plant__c>  mapOld;
    private String                    objectHandler;

    public TRG_CAMPX_PlantHandler ()  {
        this.listNew        = Trigger.new;
        this.listOld        = Trigger.old;
        this.mapOld         = (Map<Id, CAMPX__Plant__c>) Trigger.oldMap;
        this.mapNew         = (Map<Id, CAMPX__Plant__c>) Trigger.newMap;
        this.objectHandler  = 'CAMPX__Plant__c';
    }
    
    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description Handler method on before insert.
     * @comments
    **************************************************************************************************/
    public override void beforeInsert() { 
        TRG_CAMPX_PlantHelper.initializePlantFields(this.listNew);
    }
}