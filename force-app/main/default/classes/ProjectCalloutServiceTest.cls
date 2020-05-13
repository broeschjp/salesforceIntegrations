@isTest
private class ProjectCalloutServiceTest {
    //Implement mock callout tests here
    private static Opportunity createOpp(){
		insert new ServiceTokens__c(Name = 'ProjectServiceToken' , Token__c='testtoken');
 
		Account newAcct = new Account(
			Name = 'new account'
		);
		
		insert newAcct;
		
		Opportunity newOpp = new Opportunity(
			AccountId = newAcct.Id,
			Name = 'new opp',
			CloseDate = Date.today() + 10,
			Amount = 10,
			StageName = 'Closed Won'
		);

		insert newOpp;

		return newOpp;
    }

    @isTest
    static void testCalloutServiceSuccess() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
		Opportunity opp = createOpp();
		List<Id> oppIdList = new List<Id>();
		oppIdList.add(opp.Id);

		Test.startTest();
			ProjectCalloutService.postOpportunityToPMS(oppIdList);
		Test.stopTest();

		Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('Submitted Project', updatedOpp.StageName, 'Incorrect stage name returned');
	}
	
	@isTest
	static void testCalloutServiceFailure() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
		Opportunity opp = createOpp();
		List<Id> oppIdList = new List<Id>();
		oppIdList.add(opp.Id);

		Test.startTest();
			ProjectCalloutService.postOpportunityToPMS(oppIdList);
		Test.stopTest();

		Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('Resubmit Project', updatedOpp.StageName, 'Incorrect stage name returned');
	}
}