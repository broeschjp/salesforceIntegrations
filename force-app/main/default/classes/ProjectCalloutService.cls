public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod(label='Post Opportunity To PMS')
	public static void postOpportunityToPMS(List<Id> oppIds) {
        List<Opportunity> opps = [
            SELECT Id, Name, Account.Name, CloseDate, Amount 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ];

        QueueablePMSCall queueableInst = new QueueablePMSCall(opps);
        System.enqueueJob(queueableInst);
    }
    
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        List<Opportunity> oppsToSend;

        public QueueablePMSCall(List<Opportunity> opps) {
            this.oppsToSend = opps;
        }
    
        public void execute(QueueableContext context) {
            ServiceTokens__c token = ServiceTokens__c.getValues('ProjectServiceToken');

            // get requests
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setEndpoint('callout:ProjectService');
            request.setHeader('token', token.Token__c);

            // set json list
            JSONGenerator jsonGen = Json.createGenerator(true);
            jsonGen.writeStartArray();
            for (Opportunity opp : this.oppsToSend) {
                jsonGen.writeStartObject();
                jsonGen.writeIdField('opportunityId', opp.Id);
                jsonGen.writeStringField('opportunityName', opp.Name);
                jsonGen.writeStringField('accountName', opp.Account.Name);
                jsonGen.writeDateField('closeDate', opp.CloseDate);
                jsonGen.writeNumberField('amount', opp.Amount);
                jsonGen.writeEndObject();
            }
            jsonGen.writeEndArray();

            // set json list as body
            request.setBody(jsonGen.getAsString());
            
            // send request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // handle requests
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            if (response.getStatusCode() == 201) {
                // successful so set the field
                for (Opportunity opp : this.oppsToSend) {
                    Opportunity updateOpp = new Opportunity(
                        Id = opp.Id,
                        StageName = 'Submitted Project'
                    );

                    oppsToUpdate.add(updateOpp);
                }
            }
            else {
                // unsuccessful so set the field differently
                for (Opportunity opp : this.oppsToSend) {
                    Opportunity updateOpp = new Opportunity(
                        Id = opp.Id,
                        StageName = 'Resubmit Project'
                    );

                    oppsToUpdate.add(updateOpp);
                }
            }

            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
        }
    }
}