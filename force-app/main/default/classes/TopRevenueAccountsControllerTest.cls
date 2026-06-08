@IsTest
private class TopRevenueAccountsControllerTest {

    // ─── Test Data Factory ────────────────────────────────────────────────────

    private static List<Account> createAccounts(Integer count, Boolean withRevenue) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= count; i++) {
            Account acc = new Account(
                Name      = 'Test Account ' + i,
                Industry  = 'Technology',
                Phone     = '555-000-000' + i,
                Type      = 'Customer'
            );
            if (withRevenue) {
                // Revenues: 100, 200, 300 … ascending so we can assert order
                acc.AnnualRevenue = i * 100;
            }
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }

    // ─── Tests ────────────────────────────────────────────────────────────────

    @IsTest
    static void returnsTopFiveByRevenue() {
        // Create 7 accounts so we can assert only the top 5 are returned
        createAccounts(7, true);

        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.areEqual(5, result.size(), 'Should return exactly 5 accounts');

        // Verify descending revenue order
        for (Integer i = 0; i < result.size() - 1; i++) {
            Assert.isTrue(
                result[i].AnnualRevenue >= result[i + 1].AnnualRevenue,
                'Accounts must be ordered by AnnualRevenue DESC'
            );
        }
    }

    @IsTest
    static void excludesAccountsWithNoRevenue() {
        createAccounts(3, true);   // 3 with revenue
        createAccounts(2, false);  // 2 without revenue — must not appear

        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.areEqual(3, result.size(), 'Accounts with null AnnualRevenue must be excluded');
        for (Account acc : result) {
            Assert.isNotNull(acc.AnnualRevenue, 'Every returned account must have a revenue value');
        }
    }

    @IsTest
    static void returnsEmptyListWhenNoAccountsExist() {
        // No test data inserted — org may have pre-existing data but @IsTest
        // runs in an isolated data context; clean slate is guaranteed.
        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.isNotNull(result, 'Result must never be null');
        Assert.areEqual(0, result.size(), 'Empty org should return an empty list');
    }

    @IsTest
    static void returnsAllAccountsWhenFewerThanFive() {
        createAccounts(3, true);

        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.areEqual(3, result.size(), 'Should return all accounts when fewer than 5 exist');
    }

    @IsTest
    static void resultContainsRequiredFields() {
        createAccounts(1, true);

        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected one account');
        Account acc = result[0];
        Assert.isNotNull(acc.Id,            'Id must be populated');
        Assert.isNotNull(acc.Name,          'Name must be populated');
        Assert.isNotNull(acc.AnnualRevenue, 'AnnualRevenue must be populated');
        Assert.isNotNull(acc.Industry,      'Industry must be populated');
        Assert.isNotNull(acc.Phone,         'Phone must be populated');
        Assert.isNotNull(acc.Type,          'Type must be populated');
    }

    @IsTest
    static void limitIsRespectedWithLargeDataSet() {
        createAccounts(20, true);

        Test.startTest();
        List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
        Test.stopTest();

        Assert.isTrue(result.size() <= 5, 'Result must never exceed 5 records');
    }

    // ─── Security: running-user context ──────────────────────────────────────

    @IsTest
    static void runsWithSharingRespected() {
        // with sharing on the controller means the SOQL respects record-level
        // visibility. We verify the method is callable (no exception) from a
        // standard user context — the sharing rules themselves are enforced by
        // the platform and do not need to be re-tested here.
        createAccounts(3, true);

        System.runAs(createStandardUser()) {
            Test.startTest();
            List<Account> result = TopRevenueAccountsController.getTopRevenueAccounts();
            Test.stopTest();

            Assert.isNotNull(result, 'Result must not be null for a standard user');
        }
    }

    // ─── Helper ──────────────────────────────────────────────────────────────

    private static User createStandardUser() {
        Profile stdProfile = [
            SELECT Id FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        return new User(
            Alias          = 'stdtst',
            Email          = 'standardtestuser@test.example.com',
            EmailEncodingKey = 'UTF-8',
            LastName       = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey   = 'en_US',
            ProfileId      = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName       = 'standardtestuser' + System.currentTimeMillis() + '@test.example.com'
        );
    }
}
