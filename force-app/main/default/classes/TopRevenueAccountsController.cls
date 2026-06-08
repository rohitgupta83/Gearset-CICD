/**
 * @description Controller class for the topRevenueAccounts LWC component.
 *              Provides cacheable data access for top revenue accounts.
 */
public with sharing class TopRevenueAccountsController {
    /**
     * @description Retrieves the top 5 accounts by annual revenue, with FLS enforced.
     * @return List of up to 5 Account records ordered by AnnualRevenue descending.
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getTopRevenueAccounts() {
        List<Account> accounts = [
            SELECT Id, Name, AnnualRevenue, Industry, Phone, Type
            FROM Account
            WHERE AnnualRevenue != null
            ORDER BY AnnualRevenue DESC
            LIMIT 5
        ];
        return (List<Account>) Security.stripInaccessible(AccessType.READABLE, accounts).getRecords();
    }
}
