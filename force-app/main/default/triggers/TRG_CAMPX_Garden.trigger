/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Triggers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Trigger on CAMPX__Garden__c.
 * @comments
 **************************************************************************************************/
trigger TRG_CAMPX_Garden on CAMPX__Garden__c (before insert, after insert, after update) {
    new TRG_CAMPX_GardenHandler().run();
}