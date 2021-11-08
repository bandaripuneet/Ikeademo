@isTest
private class AccountTriggerHandlerTest {
	@testSetup static void setup() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        acc.Type='Prospect';
        update acc;
    }
    
    static testMethod void loadAccounts() {
        List<Account> accs = [SELECT Id,Name,Type FROM Account LIMIT 1];
        List<Opportunity> opptys = [SELECT Id,Name FROM Opportunity WHERE AccountId =: accs[0].Id];
        System.assertEquals(opptys.size(), 2);
        delete opptys;
        accs[0].Name='Prospect Account';
        update accs[0];
        List<Opportunity> newOpptys1 = [SELECT Id,Name FROM Opportunity WHERE AccountId =: accs[0].Id AND Name='Default Residential Opp'];
        System.assertEquals(newOpptys1.size(), 1);
        delete newOpptys1[0];
        accs[0].BillingCountry='USA';
        update accs[0];
        List<Opportunity> newOpptys2 = [SELECT Id,Name FROM Opportunity WHERE AccountId =: accs[0].Id AND Name='Default Commercial Opp'];
        System.assertEquals(newOpptys2.size(), 1);
        delete newOpptys2[0];
        accs[0].ShippingCountry='USA';
        update accs[0];
    }
}