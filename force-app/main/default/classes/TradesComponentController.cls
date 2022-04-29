/**
 * @description       : Helper class for tradesComponent LWC
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-26-2022   Dario   Initial Version
**/
public class TradesComponentController {
    
    public class TradesWrapper {
        @AuraEnabled public List<Trade__c> records;
        @AuraEnabled public Integer totalRecords;
    }

    public class RateResponse {
        @AuraEnabled public String base;
        @AuraEnabled public Map<String, String> rates;
        @AuraEnabled public Boolean success;
        @AuraEnabled public Error error;
    }

    public class Error {
        @AuraEnabled public String code;
        @AuraEnabled public String type;
        @AuraEnabled public String info;
    }

    /**
    * @description Fetch the Trade__c records based on the entry parameters and the total number of records
    * @author Dario | 04-28-2022 
    * @param Integer pageNumber 
    * @param Integer recordsPerPage 
    * @param String sortBy 
    * @param String sortDirection 
    * @return TradesWrapper 
    **/
    @AuraEnabled
    public static TradesWrapper fetchRecords(Integer pageNumber, Integer recordsPerPage, String sortBy, String sortDirection){
        try{
            TradesWrapper tradesWrapper = new TradesWrapper();
            Integer offset = (pageNumber - 1) * recordsPerPage;
            String query = 'SELECT Id, Name, SellCurrency__c, SellAmount__c, BuyCurrency__c, BuyAmount__c, Rate__c, CreatedDate FROM Trade__c ORDER BY '+ sortBy +' '+ sortDirection +' LIMIT ' + recordsPerPage + ' OFFSET ' + offset;
            tradesWrapper.records = Database.query(query);
            String countQuery = 'SELECT COUNT() FROM Trade__c';
            tradesWrapper.totalRecords = Database.countQuery(countQuery);
            return tradesWrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage() + ' | ' + e.getStackTraceString());
        }
    }

    /**
    * @description Get the currency FROM-TO rate from fixer.io
    * @author Dario | 04-28-2022 
    * @param String sellCurrency 
    * @param String buyCurrency 
    * @return RateResponse 
    **/
    @AuraEnabled
    public static RateResponse getRate(String sellCurrency, String buyCurrency) {
        try{
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('http://data.fixer.io/api/latest?access_key='+TradeSetting__mdt.getInstance('Default').FixerAPIKey__c+'&base='+sellCurrency+'&symbols='+buyCurrency);
            httpRequest.setMethod('GET');
            Http http = new Http();
            HTTPResponse httpResponse = http.send(httpRequest);
            RateResponse rateResponse = (RateResponse) JSON.deserialize(httpResponse.getBody(), RateResponse.class);
            return rateResponse;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage() + ' | ' + e.getStackTraceString());
        }
    }
}