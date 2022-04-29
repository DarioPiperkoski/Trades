/**
 * @description       : Test class for TradeUtility
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-29-2022   Dario   Initial Version
**/
@isTest
public class TradeUtilityTest {
    
    @IsTest
    static void createRecordsAfterInsert_positiveTest(){
        // Prepare
        Trade__c trade = new Trade__c(SellCurrency__c = 'EUR', SellAmount__c = 10, BuyCurrency__c = 'USD', Rate__c = 1.05);
        
        // Test
        test.startTest();
        insert trade;
        test.stopTest();
        
        // Assert
        system.assertEquals(1, [SELECT COUNT() FROM FeedItem WHERE ParentId =: TradeUtility.getChatterPostParentId(trade.id)], 'ChatterPost was not created');
    }

}