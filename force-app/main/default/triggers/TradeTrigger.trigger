trigger TradeTrigger on Trade__c (after insert) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        TradeTriggerHandler.AfterInsert(trigger.newMap);
    }
}