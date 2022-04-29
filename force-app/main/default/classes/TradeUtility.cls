/**
 * @description       : Trade__c Object Utility Class
 * @author            : Dario
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : Dario
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-29-2022   Dario   Initial Version
**/
public class TradeUtility {
    private static String STRING_CHATTER_GROUP_NAME_TRADE_REVIEWS = 'Trade Reviews';
    
    /**
    * @description Create platform event and chatter post every time a new trade is created
    * @author Dario | 04-29-2022 
    * @param Map<Id Trade__c> mapInsertedTrades 
    **/
    public static void createRecordsAfterInsert(Map<Id, Trade__c> mapInsertedTrades){
        List<TradeBooked__e> listEvents = new List<TradeBooked__e>();
        List<FeedItem> listFeedItems = new List<FeedItem>();
        
        for(Trade__c trade : mapInsertedTrades.values()){
            listEvents.add(createEvent());
            listFeedItems.add(createFeedItem(trade));
        }
        
        Database.SaveResult[] eventSaveResults = EventBus.publish(listEvents);
        Database.SaveResult[] feedItemSaveResults = Database.insert(listFeedItems);
    }
    
    /**
    * @description Get the Chatter Group Trade Reviews ID
    * @author Dario | 04-29-2022 
    * @return List<CollaborationGroup> 
    **/
    private static List<CollaborationGroup> tradeReviewers;
    private static List<CollaborationGroup> getTradeReviewers() {
        if(tradeReviewers == null){
            tradeReviewers = [SELECT Id, Name FROM CollaborationGroup WHERE Name =: STRING_CHATTER_GROUP_NAME_TRADE_REVIEWS];
        }
        return tradeReviewers;
    }
    
    /**
    * @description Create TradeBooked__e event
    * @author Dario | 04-29-2022 
    * @return TradeBooked__e 
    **/
    private static TradeBooked__e createEvent(){
        TradeBooked__e event = new TradeBooked__e();
        return event;
    }
    
    /**
    * @description Create ChatterPost item
    * @author Dario | 04-29-2022 
    * @param Trade__c trade 
    * @return FeedItem 
    **/
    private static FeedItem createFeedItem(Trade__c trade){
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ trade.id;
        FeedItem feedItem = new FeedItem();
        feedItem.Body = 'A new trade has been created with the following data:\n'+
            'Sell Currency: '+trade.SellCurrency__c +'\n'+
            'Sell Amount: '+trade.SellAmount__c +'\n'+
            'Buy Currency: '+trade.BuyCurrency__c +'\n'+
            'Buy Amount: '+trade.BuyAmount__c +'\n'+
            'Rate: '+trade.Rate__c +'\n'+
            'Booked Date: '+trade.CreatedDate +'\n'+
            'Link to the trade: '+fullFileURL;
        feedItem.ParentId = getChatterPostParentId(trade.id);
        feedItem.Type = 'LinkPost';
        return feedItem;    
    }
    
    /**
    * @description Get the ChatterPost parentId. ChatterGroup Id if it exist, or the trade id otherwise
    * @author Dario | 04-29-2022 
    * @param Id tradeId 
    * @return Id 
    **/
    @TestVisible static private Id getChatterPostParentId(Id tradeId){
        return !getTradeReviewers().isEmpty() ? getTradeReviewers()[0].Id : tradeId;
    }
    
}