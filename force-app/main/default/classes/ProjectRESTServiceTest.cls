@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
  @isTest 
  static void testPostProjectDataSuccess() {
    // create opp
    Account acct = new Account(Name = 'new account');
    insert acct;

    Opportunity newOpp = new Opportunity(
			AccountId = acct.Id,
			Name = 'new opp',
			CloseDate = Date.today() + 10,
			Amount = 10,
			StageName = 'Closed Won'
		);

		insert newOpp;

    String response = ProjectRESTService.postProjectData('testextid1', 'ProjectName', newOpp.Id, Date.Today() + 2, Date.Today() + 200, 100, 'Billable');
    System.assert(response != null, 'response was null');
    System.assertEquals('OK', response, 'response was not ok');

    // query for opp
    Opportunity updatedOpp = [Select Id, DeliveryInstallationStatus__c From Opportunity where Id = :newOpp.Id];
    System.assertEquals('In progress', updatedOpp.DeliveryInstallationStatus__c, 'status was not updated to in progress');

    // query for project
    Project__c project = [select Id, Name from project__c where Opportunity__c = :newOpp.Id Limit 1];
    System.assertEquals('ProjectName', project.name, 'wrong name inserted');
  }

  @isTest
  static void testPostProjectDataFailure() {
    String response = ProjectRESTService.postProjectData('testextid1', 'ProjectName', null, Date.Today() + 2, Date.Today() + 200, 100, 'Billable');
    System.assert(response != null, 'response was null');
  }
}