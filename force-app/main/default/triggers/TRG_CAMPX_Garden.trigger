trigger TRG_CAMPX_Garden on CAMPX__Garden__c (before insert) {
    new TRG_CAMPX_GardenHandler().run();
}