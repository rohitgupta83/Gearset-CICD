@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void testSingleOpportunityCreatesTask() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Subject, WhatId, OwnerId, ActivityDate, Status, Priority, Description
            FROM Task
            WHERE WhatId = :opp.Id
        ];

        Assert.areEqual(1, tasks.size(), 'Exactly one task should be created for the opportunity.');

        Task t = tasks[0];
        Assert.areEqual('Follow up on Opportunity: Test Opportunity', t.Subject, 'Task subject should match.');
        Assert.areEqual(opp.Id, t.WhatId, 'Task should be related to the opportunity.');
        Assert.areEqual(UserInfo.getUserId(), t.OwnerId, 'Task owner should match the opportunity owner.');
        Assert.areEqual(Date.today().addDays(3), t.ActivityDate, 'Task due date should be 3 days from today.');
        Assert.areEqual('Not Started', t.Status, 'Task status should be Not Started.');
        Assert.areEqual('Normal', t.Priority, 'Task priority should be Normal.');
        Assert.areEqual('Auto-created follow-up task for new opportunity.', t.Description, 'Task description should match.');
    }

    @isTest
    static void testBulkOpportunitiesCreateTasks() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(
                Name = 'Bulk Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }

        Test.startTest();
        insert opps;
        Test.stopTest();

        List<Id> oppIds = new List<Id>();
        for (Opportunity o : opps) {
            oppIds.add(o.Id);
        }

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :oppIds];
        Assert.areEqual(200, tasks.size(), 'One task should be created per opportunity in bulk insert.');
    }

    @isTest
    static void testNoTaskCreatedOnUpdate() {
        Opportunity opp = new Opportunity(
            Name = 'Update Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        List<Task> tasksAfterInsert = [SELECT Id FROM Task WHERE WhatId = :opp.Id];
        Integer taskCountAfterInsert = tasksAfterInsert.size();

        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();

        List<Task> tasksAfterUpdate = [SELECT Id FROM Task WHERE WhatId = :opp.Id];
        Assert.areEqual(taskCountAfterInsert, tasksAfterUpdate.size(), 'No additional task should be created on opportunity update.');
    }
}
