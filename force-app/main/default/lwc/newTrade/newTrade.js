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
import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues  } from 'lightning/uiObjectInfoApi';
import TRADE_FIELD_SELL_CURRENCY from '@salesforce/schema/Trade__c.SellCurrency__c';
import TRADE_FIELD_BUY_CURRENCY from '@salesforce/schema/Trade__c.BuyCurrency__c';
import TRADE_FIELD_SELL_AMOUNT from '@salesforce/schema/Trade__c.SellAmount__c';
import TRADE_FIELD_BUY_AMOUNT from '@salesforce/schema/Trade__c.BuyAmount__c';
import TRADE_FIELD_RATE from '@salesforce/schema/Trade__c.Rate__c';
import getRate from '@salesforce/apex/TradesComponentController.getRate';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';

export default class NewTrade extends LightningElement {

    tradeObject = TRADE_OBJECT;
    sellCurrencyField = TRADE_FIELD_SELL_CURRENCY;
    buyCurrencyField = TRADE_FIELD_BUY_CURRENCY;
    sellAmountField = TRADE_FIELD_SELL_AMOUNT;
    buyAmountField = TRADE_FIELD_BUY_AMOUNT;
    rateField = TRADE_FIELD_RATE;
    @track showModal = false;
    @track sellCurrency = null;
    @track buyCurrency = null;
    @track rate;
    @track buyAmount;
    @track sellAmount;
    @wire(getObjectInfo, { objectApiName: TRADE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TRADE_FIELD_SELL_CURRENCY
    })
    sellCurrencyOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TRADE_FIELD_BUY_CURRENCY
    })
    buyCurrencyOptions;

    handleCurrencyChange(event){
        let fieldApiName = event.target.fieldName;
        if(fieldApiName == this.buyCurrencyField.fieldApiName){
            this.buyCurrency = event.target.value;
        } else if (fieldApiName == this.sellCurrencyField.fieldApiName){
            this.sellCurrency = event.target.value;
        }
        if(this.sellCurrency && this.buyCurrency){
            getRate({
                sellCurrency : this.sellCurrency,
                buyCurrency : this.buyCurrency
            })
            .then(result => {
                if(result != null && result != undefined) {
                    console.log(result);
                    if(result.success == true){
                        this.rate = result.rates[this.buyCurrency];
                        this.calculateBuyAmount();
                    } else {
                        this.rate = null;
                        this.showNotification(result.error.code + ': ' + (result.error.info ? result.error.info : result.error.type), 'error');
                    }
                }
            }).catch(error => {
                if(error && error.body && error.body.message){
                    this.showNotification(error.body.message, 'error');
                } 
            })
        } else {
            this.rate = null;
            this.calculateBuyAmount();
        }
    }

    handleSellAmountChange(event){
        this.sellAmount = event.target.value;
        this.calculateBuyAmount();
    }

    calculateBuyAmount(){
        if(this.rate && this.sellAmount){
            this.buyAmount = this.sellAmount * this.rate;
        } else {
            this.buyAmount = null;
        }
    }

    showNotification(message, variant) {
        let paramData = {'message': message, 'variant': variant};
        let event = new CustomEvent('childnotification', { detail : paramData});
        this.dispatchEvent(event);
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleTradeBooked(event){
        this.showNotification('Trade Booked!','success');
        this.closeModal();
    }
    
}