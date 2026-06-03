import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTopRevenueAccounts from '@salesforce/apex/TopRevenueAccountsController.getTopRevenueAccounts';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'accountUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency', typeAttributes: { currencyCode: 'USD' }, sortable: true },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Type', fieldName: 'Type', type: 'text' }
];

export default class TopRevenueAccounts extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    accounts = [];
    error;
    isLoading = true;

    @wire(getTopRevenueAccounts)
    wiredAccounts({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.accounts = data.map(acc => ({
                ...acc,
                accountUrl: `/lightning/r/Account/${acc.Id}/view`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || 'Unknown error fetching accounts.';
            this.accounts = [];
        }
    }

    get hasAccounts() {
        return this.accounts.length > 0;
    }

    get hasError() {
        return !!this.error;
    }
}
