/**
 * @description       : 
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-27-2022   Dario   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import fetchRecords from '@salesforce/apex/TradesComponentController.fetchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TradesComponent extends LightningElement {

    @track channelName = "/event/TradeBooked__e"
    @track pageNumber = 0;
    @track recordsPerPage = '5';
    @track recordsPerPageValues = [
        {label: '1', value: '1'},
        {label: '5', value: '5'},
        {label: '10', value: '10'},
        {label: '25', value: '25'}
    ];
    @track records;
    @track totalRecords;
    @track totalPages;
    @track sortBy = 'CreatedDate';
    @track sortDirection = 'desc';
    
    @track columns = [
        { label: 'ID', fieldName: 'recordUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' },  target: '_blank'}, sortable: "true"},
        { label: 'Sell Currency', fieldName: 'SellCurrency__c', sortable: "true"},
        { label: 'Sell Amount', fieldName: 'SellAmount__c', type: "number", typeAttributes: {  minimumFractionDigits: 2 }, sortable: "true"},
        { label: 'Buy Currency', fieldName: 'BuyCurrency__c', sortable: "true"},
        { label: 'Buy Amount', fieldName: 'BuyAmount__c', type: "number", typeAttributes: { minimumFractionDigits: 2 } , sortable: "true"},
        { label: 'Rate', fieldName: 'Rate__c', type: "number", typeAttributes: {  minimumFractionDigits: 4 } , sortable: "true"},
        { label: 'Date Booked', fieldName: 'CreatedDate', type: "date", typeAttributes: { year: "numeric", month: "numeric", day: "numeric", hour: '2-digit', minute: '2-digit', second: '2-digit' }, sortable: "true"}
    ];
    @track showSpinner;
;

    constructor() {
        super();
        this.subscribeToTradesBooked();
        this.fetchRecords();
    }

    get disablePreviousButtons() {
        if(this.pageNumber <= 1){
            return true;
        }  
    }

    get disableNextButtons() {
        if(this.pageNumber == this.totalPages){
            return true;
        }
    }

    get disableCombobox() {
        if(!this.records || this.totalRecords == 0){
           return true;
        }  
    }

    get recordViewMessage() {
        return 'Total Records - ' + this.totalRecords + ' | Current Page - ' + this.pageNumber + '/' + this.totalPages;
    }

    subscribeToTradesBooked() {
        const thisReference = this;
        // Callback invoked whenever a new event event is created
        const messageCallback = function (response) {
            thisReference.fetchRecords();
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback);
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            this.showNotification(JSON.stringify(error), 'error');
        });
    }

    handleNavigation(event){
        let buttonName = event.target.label;
        if(buttonName == 'First') {
            this.pageNumber = 1;
        } else if(buttonName == 'Next') {
            this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if(buttonName == 'Previous') {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        } else if(buttonName == 'Last') {
            this.pageNumber = this.totalPages;
        }
        this.fetchRecords();
    }

    handleRecordsPerPageChange(event) {
        this.recordsPerPage = event.detail.value;
        this.pageNumber = 1;
        this.fetchRecords();
    }

    fetchRecords() {
        this.showSpinner = true;
        fetchRecords({
            pageNumber : this.pageNumber,
            recordsPerPage : Number(this.recordsPerPage),
            sortBy  : this.sortBy == 'recordUrl' ? 'Name' : this.sortBy,
            sortDirection : this.sortDirection
        })
        .then(result => {
            if(result != null && result != undefined) {
                this.records = result.records.map(row => { 
                    let recordUrl = '/' + row.Id;
                    return {...row , recordUrl} 
                })
                this.totalRecords = result.totalRecords;
                this.totalPages = Math.ceil(result.totalRecords / Number(this.recordsPerPage));
            }
            this.showSpinner = false;
        }).catch(error => {
            if(error && error.body && error.body.message){
                this.showNotification(error.body.message, 'error');
            } 
            this.showSpinner = false;
        })
    }

    showNotification(message, variant) {
        let event = new ShowToastEvent({
            'message': message,
            'variant': variant
        });
        this.dispatchEvent(event);
    }

    childNotification(event){
        this.showNotification(event.detail.message, event.detail.variant);
    }

    doSorting(event) {
        this.sortDirection = event.detail.sortDirection;
        this.sortBy = event.detail.fieldName;
        this.fetchRecords();
    }
    

}