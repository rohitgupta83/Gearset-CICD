public with sharing class OpportunityTriggerHandler {
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
