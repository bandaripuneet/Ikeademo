public with sharing class AccountTriggerHandler {
    static Set<String> defaultOpptyNames = new Set<String>{'Default Residential Opp','Default Commercial Opp'};
    public static void afterInsert(List<Account> newAccList) {
        List<Opportunity> insertOpptys = new List<Opportunity>();
        for(Account acc : newAccList) {
            Opportunity defResOpp = new Opportunity(Name='Default Residential Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
            Opportunity defComOpp = new Opportunity(Name='Default Commercial Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
            insertOpptys.add(defResOpp);
            insertOpptys.add(defComOpp);
        }
        if(!insertOpptys.isEmpty())
            insert insertOpptys;
    }
    
    public static void afterUpdate(Map<Id,Account> newAccMap) {
        Set<Id> accIdsForDefOpptys = new Set<Id>();
        for(Id accId : newAccMap.keySet()) {
            if(newAccMap.get(accId).Type == 'Prospect') {
                accIdsForDefOpptys.add(accId);
            }
        }
        Map<Id,Account> accOpptysMap = getAccOpptysMap(accIdsForDefOpptys);
        List<Opportunity> insertOpptys = new List<Opportunity>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Account acc : accOpptysMap.values()) {
            Set<String> opptyNames = new Set<String>();
            List<String> missingOpptyNames = new List<String>();
            if(acc.Opportunities.size() > 0) {
                for(Opportunity opp: acc.Opportunities) {
                	opptyNames.add(opp.Name);
                }
                if(!opptyNames.contains('Default Residential Opp')) {
                    Opportunity defResOpp = new Opportunity(Name='Default Residential Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
                    insertOpptys.add(defResOpp);
                    missingOpptyNames.add('Default Residential Opp');
                }
                if(!opptyNames.contains('Default Commercial Opp')) {
            		Opportunity defComOpp = new Opportunity(Name='Default Commercial Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
                    insertOpptys.add(defComOpp);
                    missingOpptyNames.add('Default Commercial Opp');
                }
            } else {
                Opportunity defResOpp = new Opportunity(Name='Default Residential Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
                insertOpptys.add(defResOpp);
                Opportunity defComOpp = new Opportunity(Name='Default Commercial Opp',AccountId=acc.Id,StageName='Prospecting',CloseDate=System.today()+5);
                insertOpptys.add(defComOpp);
            }
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {acc.OwnerId};
            message.subject = 'Opportunities were deleted and replaced for your account';
            message.setHtmlBody('Dear '+acc.Owner.Name+',<br/><br/>We noticed following default opportunities were deleted on Account: '+acc.Name+' and were replaced.<br/><br/>'+missingOpptyNames.toString()+'<br/><br/>Regards,<br/>IKEA Sales Team');
            messages.add(message);
        }
        if(!insertOpptys.isEmpty()) {
            insert insertOpptys;
            Messaging.sendEmail(messages);
        }
    }
    
    public static Map<Id,Account> getAccOpptysMap(Set<Id> accountIds) {
        Map<Id,Account> accOpptysMap = new Map<Id,Account>([SELECT Id,Name,OwnerId,Owner.Name,(SELECT Id,Name FROM Opportunities WHERE Name IN ('Default Residential Opp','Default Commercial Opp')) FROM Account WHERE Id IN : accountIds]);
        return accOpptysMap;
    }
}