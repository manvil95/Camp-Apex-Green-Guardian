/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Handlers
 * @group-content   ../../ApexDocContent/Accounts.htm
 *
 * @description     Trigger Handler on CAMPX__Garden__c.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_GardenHandler extends TriggerHandler{

    private List<CAMPX__Garden__c>     listNew;
    private List<CAMPX__Garden__c>     listOld;
    private Map<Id, CAMPX__Garden__c>  mapNew;
    private Map<Id, CAMPX__Garden__c>  mapOld;
    private String                      objectHandler;

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
     * @param       objectName the name of the object to look up
     * @param       fieldName the name of the field to look up
     * @return      the describe field result for the given field
     * @description Returns field describe data
     * @comments
     * @example
     * Account a = new Account();
    **************************************************************************************************/
    public override void beforeInsert() {
        TRG_CAMPX_GardenHelper.initializeGardenFieldsUponRecordCreation(this.listNew);
    }
}