@RestResource(urlMapping='/project/*')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status) {
        Savepoint sp = Database.setSavepoint();
        try {
            Project__c project = new Project__c();
            project.Name = ProjectName;
            project.Opportunity__c = OpportunityId;
            project.ProjectRef__c = ProjectRef;
            project.Start_Date__c = StartDate;
            project.End_Date__c = EndDate;
            project.Billable_Amount__c = Amount;
            project.Status__c = Status;
            upsert project;

            Opportunity oppToUpdate = new Opportunity(Id = OpportunityId);
            oppToUpdate.DeliveryInstallationStatus__c = 'In Progress';
            update oppToUpdate;
            
            return 'OK';
        }
        catch(Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
    }
}