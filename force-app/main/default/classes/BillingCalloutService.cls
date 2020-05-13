public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(Map<Id, Project__c> projects, Map<Id, Project__c> oldProjects) {
        ServiceCredentials__c creds = ServiceCredentials__c.getValues('BillingServiceCredential');
        for (Project__c project : projects.values()) {
            if (project.Status__c == 'Billable') {
                calloutToBillingService(project.Id, project.ProjectRef__c, project.Billable_Amount__c, creds.Username__c, creds.Password__c);
            }
        }
    }
    
    @future(callout=true)
    public static void calloutToBillingService(String projectId, String projectRef, Decimal amount, String username, String password) {
        BillingServiceProxy.project bspProject = new BillingServiceProxy.project();
        bspProject.projectid = projectRef;
        bspProject.billAmount = amount;
        bspProject.username = username;
        bspProject.password = password;
        
        BillingServiceProxy.InvoicesPortSoap11 bsp = new BillingServiceProxy.InvoicesPortSoap11();
        String response = bsp.billProject(bspProject);
        
        if (response == 'ok') {
            Project__c updateProjectStatus = new Project__c(Id = projectId);
            updateProjectStatus.ProjectRef__c = projectRef;
            updateProjectStatus.Status__c = 'Billed';

            update updateProjectStatus;
        }
    }
}