/**
 * @description       : Test Class for TradesComponentController
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-29-2022   Dario   Initial Version
**/
@isTest
public class TradesComponentControllerTest {
    
    @TestSetup
    private static void insertTrade() {
        List<Trade__c> listTradesToInsert = new List<Trade__c>();
        for(Integer i = 0; i < 5; i++){
            Trade__c trade = new Trade__c(SellCurrency__c = 'EUR', SellAmount__c = 10, BuyCurrency__c = 'USD', Rate__c = 1.05);
            listTradesToInsert.add(trade);
        }
        
        insert listTradesToInsert;
    }
    
    @IsTest
    static void fetchRecords_positiveTest(){
        Integer pageNumber = 1;
        Integer recordsPerPage = 1;
        String sortBy = 'CreatedDate';
        String sortDirection = 'DESC';
        // Test
        test.startTest();
        TradesComponentController.TradesWrapper fetchRecordsResult = TradesComponentController.fetchRecords(pageNumber, recordsPerPage, sortBy, sortDirection);
        test.stopTest();
        
        // Assert
        system.assertEquals(5, fetchRecordsResult.totalRecords, 'Wrong total number of records');
        system.assertEquals(recordsPerPage, fetchRecordsResult.records.size(), 'Wrong number of returned records');
    }
    
    @IsTest
    static void fetchRecords_negativeTest(){
        Integer pageNumber = 1;
        Integer recordsPerPage = 1;
        String sortBy = 'someInvalidField';
        String sortDirection = 'DESC';
        Boolean exceptionWasReceived = false;
        
        // Test
        test.startTest();
        try {
            TradesComponentController.TradesWrapper fetchRecordsResult = TradesComponentController.fetchRecords(pageNumber, recordsPerPage, sortBy, sortDirection);
        }
        catch (AuraHandledException e) {
            exceptionWasReceived = true;
        }
        test.stopTest();
        
        // Assert
        system.assertEquals(true, exceptionWasReceived, 'Exception was not triggered');
    }
    
    private class Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{ "success": true, "timestamp": 1519296206, "base": "EUR", "date": "2022-04-28", "rates": { "USD": 1.23396 } }');
            return res;
        }
    }
    
    @IsTest
    static void getRate_positiveTest(){
        String sellCurrency = 'EUR';
        String buyCurrency = 'USD';
        
        // HTTP calls get routed to mock instead of out to the internet
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        // Test
        test.startTest();
        TradesComponentController.RateResponse rateResponse = TradesComponentController.getRate(sellCurrency, buyCurrency);
        test.stopTest();
        
        // Assert
        system.assertEquals(true, rateResponse.success, 'Request failed');
    }
    
}