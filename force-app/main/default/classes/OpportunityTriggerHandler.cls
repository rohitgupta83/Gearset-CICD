/**
 * @description Handler class for Opportunity trigger logic.
 *              Processes trigger events and performs DML operations.
 */
public with sharing class OpportunityTriggerHandler {

    /**
     * @description Creates follow-up tasks for each opportunity in the provided list.
     * @param opportunities List of Opportunity records to process.
     */

    /* Create follow - up tasks . */

    public static void createFollowUpTasks(List<Opportunity> opportunities) {
        List<Task> tasks = new List<Task>();

        for (Opportunity opp : opportunities) {
            Task t = new Task();
            t.Subject = 'Follow up on Opportunity: ' + opp.Name;
            t.WhatId = opp.Id;
            t.OwnerId = opp.OwnerId;
            t.ActivityDate = Date.today().addDays(3);
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.Description = 'Auto-created follow-up task for new opportunity.';
            tasks.add(t);
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }
}
