/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Helpers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Helper class for on TRG_CAMPX_GardenHandler.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_GardenHelper {
    
    private static final String NEW_TASK_SUBJECT = 'Acquire Plants';
    private static final String STATUS_COMPLETED = 'Completed';

    /**********************************************************************************************
     * @author      manvil95
     * @date        24/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description When a new garden record is created/update and a manager is assigned/unassigned, 
     *              the start date must be set/unset.
     * @comments
    **********************************************************************************************/
    public static void setUnsetManagerStartDate(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        List<CAMPX__Garden__c> gardensToUpdate              = new List<CAMPX__Garden__c>();
        List<CAMPX__Garden__c> gardensToUpdateWithDate      = new List<CAMPX__Garden__c>();
        List<CAMPX__Garden__c> gardensToUpdateWithoutDate   = new List<CAMPX__Garden__c>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Manager__c != null && oldTriggerMap == null
                    || (
                            currentGarden.CAMPX__Manager__c != null 
                            && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                            && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c == null
                        )
            ) {
                gardensToUpdateWithDate.add(currentGarden);
                continue;
            }
            
            try {
                if (currentGarden.CAMPX__Manager__c == null
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != null 
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                ) {
                    gardensToUpdateWithoutDate.add(currentGarden);
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        for (CAMPX__Garden__c currentGarden : gardensToUpdateWithDate) {
            currentGarden.CAMPX__Manager_Start_Date__c = Date.today();
            gardensToUpdate.add(currentGarden);
        }
        
        for (CAMPX__Garden__c currentGarden : gardensToUpdateWithoutDate) {
            currentGarden.CAMPX__Manager_Start_Date__c = null;
            gardensToUpdate.add(currentGarden);
        }

        
        if (!gardensToUpdate.isEmpty()) {
            try {
                update gardensToUpdate;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description When a new garden record is created/update and a manager is assigned, create a new 
     *              Task record and assign it to the manager
     * @comments
    **********************************************************************************************/
    public static void createTaskForNewGardeningManagers(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        List<Task> newTasks = new List<Task>();
        List<Task> taskToInsert = new List<Task>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Manager__c != null && oldTriggerMap == null
                    || (
                            currentGarden.CAMPX__Manager__c != null 
                            && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                            && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c == null
                        )
            ) {
                Task newTask = new Task(
                    WhatId  = currentGarden.Id,
                    OwnerId = currentGarden.CAMPX__Manager__c,
                    Subject = NEW_TASK_SUBJECT
                );
                
                taskToInsert.add(newTask);
            }
        }
        
        try {
            insert taskToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description When a new garden record is update and a manager is unassigned, delete 
     *              Task record with 'Acquire Plants' subject
     * @comments
    **********************************************************************************************/
    public static void deleteTaskWhenManagerIsUnassigned(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        List<Task> tasks = new List<Task>();
        List<Task> taskToDelete = new List<Task>();
        Set<Id> gardenIds = new Set<Id>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Manager__c == null
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != null 
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                
            ) {
                gardenIds.add(currentGarden.Id);
            }
        }

        if (!gardenIds.isEmpty()) {
            tasks = [SELECT Id, WhatId, OwnerId, Subject, Status 
                    FROM Task 
                    WHERE WhatId IN :gardenIds 
                        AND Status != :STATUS_COMPLETED
                        AND Subject =: NEW_TASK_SUBJECT
                    WITH USER_MODE];
            
            for (CAMPX__Garden__c currentGarden : newTriggerList) {
                for (Task currentTask : tasks) {
                    if (currentGarden.Id == currentTask.WhatId 
                            && currentTask.Subject  == NEW_TASK_SUBJECT 
                            && currentTask.Status   != STATUS_COMPLETED
                            && currentTask.OwnerId  == oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c 
                    ) {
                        taskToDelete.add(currentTask);
                    }
                }
            }
            if (!taskToDelete.isEmpty()) {
                try {
                    delete taskToDelete;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description When a new garden record is created/update and a manager is assigned, create a new 
     *              Task record and assign it to the manager
     * @comments
    **********************************************************************************************/
    public static void reassignTaskWhenManagerChanges(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        List<Task> tasks = new List<Task>();
        List<Task> taskToUpdate = new List<Task>();
        Set<Id> gardenIds = new Set<Id>();

        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Manager__c != null
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != null 
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                
            ) {
                gardenIds.add(currentGarden.Id);
            }
        }

        if (!gardenIds.isEmpty()) {
            tasks = [SELECT Id, WhatId, OwnerId 
                    FROM Task 
                    WHERE WhatId IN :gardenIds 
                        AND Status != :STATUS_COMPLETED 
                    WITH USER_MODE];
            
            for (CAMPX__Garden__c currentGarden : newTriggerList) {
                for (Task currentTask : tasks) {
                    if (currentGarden.Id == currentTask.WhatId) {
                        currentTask.OwnerId = currentGarden.CAMPX__Manager__c;
                        taskToUpdate.add(currentTask);
                    }
                }
            }
            
            try {
                update taskToUpdate;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new garden record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **********************************************************************************************/
    public static void initializeGardenFieldsUponRecordCreation(List<CAMPX__Garden__c> newTriggerList) {
        List<CAMPX__Garden__c> gardensToInsert = new List<CAMPX__Garden__c>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Status__c == null || currentGarden.CAMPX__Status__c == '') {
                currentGarden.CAMPX__Status__c = 'Awaiting Resources';
            }
            
            if (currentGarden.CAMPX__Max_Plant_Count__c == null) {
                currentGarden.CAMPX__Max_Plant_Count__c = 100;
            }
            
            if (currentGarden.CAMPX__Minimum_Plant_Count__c == null) {
                currentGarden.CAMPX__Minimum_Plant_Count__c = 1;
            }
            
            if (currentGarden.CAMPX__Total_Plant_Count__c == null) {
                currentGarden.CAMPX__Total_Plant_Count__c = 0;
            }
            
            if (currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c == null) {
                currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            }
            
            gardensToInsert.add(currentGarden);
        }
        
        try {
            insert gardensToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}