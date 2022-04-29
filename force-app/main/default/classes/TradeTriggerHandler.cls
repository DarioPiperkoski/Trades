/**
 * @description       : Trade__c object trigger handler
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-29-2022   Dario   Initial Version
**/
public class TradeTriggerHandler {
    
    public static void afterInsert(Map<Id, Trade__c> mapInsertedTrades){
        TradeUtility.createRecordsAfterInsert(mapInsertedTrades);
    }
    
}