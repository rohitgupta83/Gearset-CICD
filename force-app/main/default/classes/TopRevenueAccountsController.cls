public with sharing class TopRevenueAccountsController {
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
