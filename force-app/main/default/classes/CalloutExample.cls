// TaxJar callout POC
public with sharing class CalloutExample {
  @TestVisible
  private class ProviderRequestTaxObj {
    @TestVisible
    String id;

    @TestVisible
    String customer_id;

    @TestVisible
    String from_country;

    @TestVisible
    String from_zip;

    @TestVisible
    String from_state;

    @TestVisible
    String from_city;

    @TestVisible
    String from_street;

    @TestVisible
    String to_country;

    @TestVisible
    String to_zip;

    @TestVisible
    String to_state;

    @TestVisible
    String to_city;

    @TestVisible
    String to_street;

    @TestVisible
    Decimal amount;

    @TestVisible
    Decimal shipping;

    @TestVisible
    String exemption_type;

    @TestVisible
    List<ProviderNexusAddress> nexus_addresses;

    @TestVisible
    List<ProviderLineItem> line_items;
  }

  @TestVisible
  private class ProviderNexusAddress {
    String id;
    String country;
    String zip;
    String city;
    String state;
    String street;
  }

  @TestVisible
  private class ProviderLineItem {
    @TestVisible
    String id;

    @TestVisible
    Integer quantity;

    @TestVisible
    String product_tax_code;

    @TestVisible
    Decimal unit_price;
  }

  @future(callout=true)
  public static void getSalesTaxFromProvider(Id opportunityId) {
    Map<Id, Opportunity> fullOpportunityDataMap = getFullOpportunityMap(
      opportunityId
    );

    Opportunity fullOpp = fullOpportunityDataMap.get(opportunityId);
    List<OpportunityLineItem> fullOppLineItems = fullOpp.OpportunityLineItems;

    ProviderRequestTaxObj ProviderRequest = getProviderRequest(
      fullOpp,
      fullOppLineItems
    );
    String providerRequestJson = JSON.serialize(ProviderRequest);

    HttpResponse response;
    if (Test.isRunningTest()) {
      // test request and response
      HttpRequest request = new HttpRequest();
      request.setMethod('POST');
      request.setEndpoint('callout:taxjar/v2/taxes');
      CalloutExampleMockHttpResponse mock = new CalloutExampleMockHttpResponse();
      response = mock.respond(request);
    } else {
      // true callout to provider
      response = calloutToProvider(providerRequestJson);
    }

    if (response != null && response.getStatusCode() == 200) {
      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      handleCalloutResponse(result, opportunityId);
    } else {
      // send to whatever error logging is available (if any)
      System.debug(
        'The status code returned was not expected: ' +
        response.getStatusCode() +
        ' ' +
        response.getStatus()
      );
    }
  }

  @TestVisible
  private static Map<Id, Opportunity> getFullOpportunityMap(Id opportunityId) {
    // add fields needed for Provider callout (only if not already in the map)
    Map<Id, Opportunity> fullOpportunityDataMap = new Map<Id, Opportunity>(
      [
        SELECT Id, (SELECT Id FROM OpportunityLineItems)
        FROM Opportunity
        WHERE Id = :opportunityId
      ]
    );

    return fullOpportunityDataMap;
  }

  @TestVisible
  private static HttpResponse calloutToProvider(String providerRequestJson) {
    // setup callout request parameters and objects
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');

    // json serialize the object
    request.setBody(providerRequestJson);

    // will implement named credentials for the security aspect of this
    request.setEndpoint('callout:taxjar/v2/taxes');
    request.setHeader('Authorization', 'Token token={!$Credential.Password}');

    // send request
    Http http = new Http();
    HttpResponse response = http.send(request);

    return response;
  }

  @TestVisible
  private static ProviderRequestTaxObj getProviderRequest(
    Opportunity fullOpp,
    List<OpportunityLineItem> fullOppLineItems
  ) {
    // map request fields with full opportunity data map fields
    ProviderRequestTaxObj providerRequest = new ProviderRequestTaxObj();
    providerRequest.from_country = 'US';
    providerRequest.from_zip = '07001';
    providerRequest.from_state = 'NJ';
    providerRequest.to_country = 'US';
    providerRequest.to_zip = '07446';
    providerRequest.to_state = 'NJ';
    providerRequest.amount = 16.50;
    providerRequest.shipping = 1.5;
    providerRequest.line_items = new List<ProviderLineItem>();

    Integer test = 0;
    for (OpportunityLineItem oppLineItem : fullOppLineItems) {
      ProviderLineItem ProviderLineItem = new ProviderLineItem();
      ProviderLineItem.id = 'testId' + test;
      ProviderLineItem.quantity = 1;
      ProviderLineItem.unit_price = 15;
      ProviderLineItem.product_tax_code = '31000';

      if (providerRequest.line_items != null) {
        providerRequest.line_items.add(ProviderLineItem);
      }
      test++;
    }

    return providerRequest;
  }

  @TestVisible
  private static void handleCalloutResponse(
    Map<String, Object> response,
    Id opportunityId
  ) {
    Opportunity oppToUpdate = new Opportunity(
      Id = opportunityId //,
      // Sales_Tax__c = 0 // field should exist in org
    );

    // take the response and parse out the tax amount and put it on the new opp for update
    Map<String, Object> taxObj = (Map<String, Object>) response.get('tax');
    Decimal salesTax = (Decimal) taxObj.get('amount_to_collect');

    System.debug(salesTax);

    if (salesTax != null) {
      //   oppToUpdate.Sales_Tax__c = salesTax; // field should exist in org
    }

    update oppToUpdate;
  }
}
