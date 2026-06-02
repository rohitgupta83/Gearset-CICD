public with sharing class TopRevenueAccountsController {
    /* Get the top revenue accounts in the sequence of accounts in the system . */
    @AuraEnabled(cacheable=true)
    public static List<Account> getTopRevenueAccounts() {
        return [
            SELECT Id, Name, AnnualRevenue, Industry, Phone, Type
            FROM Account
            WHERE AnnualRevenue != null
            ORDER BY AnnualRevenue DESC
            LIMIT 5
        ];
    }
}
