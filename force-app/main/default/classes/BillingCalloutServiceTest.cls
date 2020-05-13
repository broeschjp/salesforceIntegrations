@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
  private static Project__c createProject() {
    insert new ServiceCredentials__c(Name = 'BillingServiceCredential' , Username__c = 'testun', Password__c='testpw');
 
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
    
    Project__c newProject = new Project__c(
      Billable_Amount__c = 10,
      Opportunity__c = newOpp.Id,
      Status__c = 'Running'
    );

    insert newProject;

    return newProject;
  }

  @isTest
  static void testBillingCalloutSuccess() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    Project__c project = createProject();
    Map<Id, Project__c> oldProjects = new Map<Id, Project__c>();
    oldProjects.put(project.Id, project);

    project.Status__c = 'Billable';
    Map<Id, Project__c> projects = new Map<Id, Project__c>();
    projects.put(project.Id, project);
    
    Test.startTest();
      BillingCalloutService.callBillingService(projects, oldProjects);
    Test.stopTest();

    Project__c updatedProject = [select id, status__c from project__c where id = :project.Id];
    System.assertEquals('Billed', updatedProject.status__c, 'incorrect status returned on project');
  } 

  @isTest
  static void testBillingCalloutFailure() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
    Project__c project = createProject();
    Map<Id, Project__c> oldProjects = new Map<Id, Project__c>();
    oldProjects.put(project.Id, project);

    project.Status__c = 'Billable';
    Map<Id, Project__c> projects = new Map<Id, Project__c>();
    projects.put(project.Id, project);
    
    Test.startTest();
      BillingCalloutService.callBillingService(projects, oldProjects);
    Test.stopTest();

    Project__c updatedProject = [select id, status__c from project__c where id = :project.Id];
    System.assertEquals('Running', updatedProject.status__c, 'incorrect status returned on project');
  }
}