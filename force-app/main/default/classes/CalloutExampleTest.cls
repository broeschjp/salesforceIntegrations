@isTest
public with sharing class CalloutExampleTest {
    @isTest
    private static void test_getSalesTaxFromProvider() {
        // more an integration test of all things
        // create an opp, move it to Collect Payment,
        // let test mocks handle the rest,
        // then assert the right amount
    }

    @isTest
    private static void test_getFullOpportunityMap() {
        Opportunity newOpp = new Opportunity(
            Name = 'testopp',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        insert newOpp;

        Map<Id, Opportunity> oppMap = CalloutExample.getFullOpportunityMap(
            newOpp.Id
        );
        System.assert(
            oppMap.size() > 0,
            'no opportunities were retrieved from getFullOpportunityMap method'
        );
    }

    @isTest
    private static void test_calloutToProvider() {
        String providerJsonRequest = '{"to_zip": "07446","to_street": null,"to_state": "NJ","to_country": "US","to_city": null,"shipping": 1.5,"nexus_addresses": null,"line_items": [{"unit_price": 15,"quantity": 1,"product_tax_code": "31000","id": "testId0"},{"unit_price": 15,"quantity": 1,"product_tax_code": "31000","id": "testId1"}],"id": null,"from_zip": "07001","from_street": null,"from_state": "NJ","from_country": "US","from_city": null,"exemption_type": null,"customer_id": null,"amount": 16.50}';
        String expectedValue = CalloutExampleMockHttpResponse.getTestProviderResponseJson();
        Test.setMock(
            HttpCalloutMock.class,
            new CalloutExampleMockHttpResponse()
        );

        HttpResponse res = CalloutExample.calloutToProvider(
            providerJsonRequest
        );

        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }

    @isTest
    private static void test_getProviderRequest() {
        Opportunity newOpp = new Opportunity(
            Name = 'testopp',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        insert newOpp;

        Map<Id, Opportunity> oppMap = CalloutExample.getFullOpportunityMap(
            newOpp.Id
        );

        CalloutExample.ProviderRequestTaxObj newRequest = CalloutExample.getProviderRequest(
            oppMap.get(newOpp.Id),
            oppMap.get(newOpp.Id).OpportunityLineItems
        );
        System.assertEquals(16.50, newRequest.amount);
    }

    @isTest
    private static void test_getProviderRequest_withLineItems() {
        Opportunity newOpp = new Opportunity(
            Name = 'testopp',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        insert newOpp;

        Id pricebookId = Test.getStandardPricebookId();

        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;

        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 15.00,
            IsActive = true
        );
        insert pbEntry;

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = newOpp.Id,
            PricebookEntryId = pbEntry.Id,
            Quantity = 1,
            TotalPrice = 15
        );

        insert newOppLine;

        Map<Id, Opportunity> oppMap = CalloutExample.getFullOpportunityMap(
            newOpp.Id
        );

        CalloutExample.ProviderRequestTaxObj newRequest = CalloutExample.getProviderRequest(
            oppMap.get(newOpp.Id),
            oppMap.get(newOpp.Id).OpportunityLineItems
        );
        System.assertEquals(16.50, newRequest.amount);
        System.assertEquals(15, newRequest.line_items[0].unit_price);
    }

    @isTest
    private static void test_handleCalloutResponse() {
        Opportunity newOpp = new Opportunity(
            Name = 'testopp',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        insert newOpp;

        // test request and response
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:taxjar/v2/taxes');
        CalloutExampleMockHttpResponse mock = new CalloutExampleMockHttpResponse();
        HttpResponse response = mock.respond(request);
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
            response.getBody()
        );

        CalloutExample.handleCalloutResponse(result, newOpp.Id);

        Opportunity opp = [
            SELECT Id, Sales_Tax__c
            FROM Opportunity
            WHERE Id = :newOpp.Id
        ];
        System.assertEquals(2.09, opp.Sales_Tax__c);
    }
}
