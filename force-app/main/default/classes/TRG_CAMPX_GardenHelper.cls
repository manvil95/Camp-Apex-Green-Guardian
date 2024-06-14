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
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class TRG_CAMPX_GardenHelper {
    
    private static final String NEW_TASK_SUBJECT            = 'Acquire Plants';
    private static final String STATUS_COMPLETED            = 'Completed';
    private static final String STATUS_PERMANENT_CLOSURE    = 'Permanent Closure';
	private static final String STATUS_OPERATIONAL          = 'Operational';
	private static final String STATUS_TEMPORARY_CLOSURE    = 'Temporary Closure';
	private static final String STATUS_OVER_CAPACITY        = 'Over Capacity';
	private static final String STATUS_AWAITING_RESOURCES   = 'Awaiting Resources';

    /**********************************************************************************************
     * @author      manvil95
     * @date        13/06/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description Method to calculate the health index.
     * @comments
    **********************************************************************************************/
    public static void setGardenStatus(List<CAMPX__Garden__c> newTriggerList, Map<Id,CAMPX__Garden__c> oldTriggerMap) {
		for (CAMPX__Garden__c currentGarden : newTriggerList) {  
			if (currentGarden.CAMPX__Status__c != STATUS_PERMANENT_CLOSURE
				&& (oldTriggerMap == null 
				|| (currentGarden.CAMPX__Total_Plant_Count__c      != oldTriggerMap.get(currentGarden.Id).CAMPX__Total_Plant_Count__c) 
				|| (currentGarden.CAMPX__Capacity__c               != oldTriggerMap.get(currentGarden.Id).CAMPX__Capacity__c) 
				|| (currentGarden.CAMPX__Health_Index__c           != oldTriggerMap.get(currentGarden.Id).CAMPX__Health_Index__c) 
				|| (currentGarden.CAMPX__Minimum_Plant_Count__c    != oldTriggerMap.get(currentGarden.Id).CAMPX__Minimum_Plant_Count__c))
            ) {
                if (currentGarden.CAMPX__Capacity__c >= 70 
                        && currentGarden.CAMPX__Capacity__c <= 100 
                        && currentGarden.CAMPX__Total_Plant_Count__c >= currentGarden.CAMPX__Minimum_Plant_Count__c 
                        && currentGarden.CAMPX__Health_Index__c >= 70
                ) {
                    currentGarden.CAMPX__Status__c = STATUS_OPERATIONAL;	
                } else if (currentGarden.CAMPX__Capacity__c == 0) {
                    currentGarden.CAMPX__Status__c = STATUS_TEMPORARY_CLOSURE;
                } else if (currentGarden.CAMPX__Capacity__c > 100) {
                    currentGarden.CAMPX__Status__c = STATUS_OVER_CAPACITY;
                } else if ((currentGarden.CAMPX__Capacity__c > 0
                        && currentGarden.CAMPX__Capacity__c < 70) 
                        || currentGarden.CAMPX__Health_Index__c < 70 
                        || currentGarden.CAMPX__Total_Plant_Count__c < currentGarden.CAMPX__Minimum_Plant_Count__c) {
                    currentGarden.CAMPX__Status__c = STATUS_AWAITING_RESOURCES;
                } else {
                    currentGarden.CAMPX__Status__c = '';
                }
            }
		}
	}
    
    /**********************************************************************************************
     * @author      manvil95
     * @date        13/06/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description Method to calculate the health index.
     * @comments
    **********************************************************************************************/
    public static void calculateHealthIndex(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (
                    oldTriggerMap == null 
                    || (currentGarden.CAMPX__Total_Plant_Count__c != oldTriggerMap.get(currentGarden.Id).CAMPX__Total_Plant_Count__c)
                    || (currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c != oldTriggerMap.get(currentGarden.Id).CAMPX__Total_Unhealthy_Plant_Count__c)
            ) {
                if (currentGarden.CAMPX__Total_Plant_Count__c != null && currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c != null && currentGarden.CAMPX__Total_Plant_Count__c != 0) {
                    currentGarden.CAMPX__Health_Index__c = ((currentGarden.CAMPX__Total_Plant_Count__c - currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c) / currentGarden.CAMPX__Total_Plant_Count__c) * 100;
                } else {
                    currentGarden.CAMPX__Health_Index__c = 0;
                }
            }
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        04/06/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description Method to calculate the capacity of a garden.
     * @comments
    **********************************************************************************************/
    public static void calculateCapacity(List<CAMPX__Garden__c> newTriggerList, Map<Id, CAMPX__Garden__c> oldTriggerMap) {
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if ((currentGarden.CAMPX__Total_Plant_Count__c == 0 || currentGarden.CAMPX__Max_Plant_Count__c == 0 
                    || currentGarden.CAMPX__Total_Plant_Count__c == null || currentGarden.CAMPX__Max_Plant_Count__c == null) 
                    && (oldTriggerMap != null || oldTriggerMap == null)
            ) {
                currentGarden.CAMPX__Capacity__c = 0;
                continue;
            }

            if (currentGarden.CAMPX__Total_Plant_Count__c != null && currentGarden.CAMPX__Max_Plant_Count__c != null && (oldTriggerMap != null || oldTriggerMap == null)) {
                currentGarden.CAMPX__Capacity__c = (currentGarden.CAMPX__Total_Plant_Count__c / currentGarden.CAMPX__Max_Plant_Count__c * 100);
                System.debug('NOT 0 -> ' + currentGarden.CAMPX__Capacity__c);
                continue;
            }
        }
    }
    
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
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if ((currentGarden.CAMPX__Manager__c != null && oldTriggerMap == null)
                    || (
                            currentGarden.CAMPX__Manager__c != null 
                            && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != currentGarden.CAMPX__Manager__c
                        )
            ) {
                currentGarden.CAMPX__Manager_Start_Date__c = Date.today();
            }
            
            if ((currentGarden.CAMPX__Manager__c == null && oldTriggerMap == null) || (currentGarden.CAMPX__Manager__c == null
                    && oldTriggerMap.get(currentGarden.Id) != null 
                    && oldTriggerMap.get(currentGarden.Id).CAMPX__Manager__c != null)
            ) {
                currentGarden.CAMPX__Manager_Start_Date__c = null;
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
        
        if (!taskToInsert.isEmpty()) {
            insert taskToInsert;
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
                    delete taskToDelete;
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
            
            if (!taskToUpdate.isEmpty()) {
                update taskToUpdate;
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
        }
    }
}