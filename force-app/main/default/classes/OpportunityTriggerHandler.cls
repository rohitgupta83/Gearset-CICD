public with sharing class OpportunityTriggerHandler {


    private static Boolean hasRun = false;


    /* Create follow - up tasks . */

    public static void createFollowUpTasks(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.isEmpty() || hasRun) return;
        hasRun = true;

        // ✅ CRUD check — verify user has Create permission on Task before DML
        if (!Schema.sObjectType.Task.isCreateable()) {
            throw new SecurityException(
                'Insufficient permissions: Current user cannot create Task records.'
            );
        }

        List<Task> tasks = new List<Task>();
        for (Opportunity opp : opportunities) {
            Task t         = new Task();
            t.Subject      = 'Follow up on Opportunity: ' + opp.Name;
            t.WhatId       = opp.Id;
            t.OwnerId      = opp.OwnerId != null ? opp.OwnerId : UserInfo.getUserId();
            t.ActivityDate = Date.today().addDays(3);
            t.Status       = 'Not Started';
            t.Priority     = 'Normal';
            t.Description  = 'Auto-created follow-up task for new opportunity.';
            tasks.add(t);
        }

        try {
            insert tasks;
        } catch (DmlException e) {
            System.debug(
                LoggingLevel.ERROR,
                'OpportunityTriggerHandler.createFollowUpTasks failed: ' + e.getMessage()
            );
            throw e;
        }
    }
}
