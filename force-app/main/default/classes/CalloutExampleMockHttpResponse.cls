@isTest
global class CalloutExampleMockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('callout:taxjar/v2/taxes', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(getTestProviderResponseJson());
        res.setStatusCode(200);
        return res;
    }

    public static String getTestProviderResponseJson() {
        return '{"tax":{"amount_to_collect":2.09,"breakdown":{"city_tax_collectable":0.0,"city_tax_rate":0.0,"city_taxable_amount":0.0,"combined_tax_rate":0.06625,"county_tax_collectable":0.0,"county_tax_rate":0.0,"county_taxable_amount":0.0,"line_items":[{"city_amount":0.0,"city_tax_rate":0.0,"city_taxable_amount":0.0,"combined_tax_rate":0.06625,"county_amount":0.0,"county_tax_rate":0.0,"county_taxable_amount":0.0,"id":"testId0","special_district_amount":0.0,"special_district_taxable_amount":0.0,"special_tax_rate":0.0,"state_amount":0.99,"state_sales_tax_rate":0.06625,"state_taxable_amount":15.0,"tax_collectable":0.99,"taxable_amount":15.0},{"city_amount":0.0,"city_tax_rate":0.0,"city_taxable_amount":0.0,"combined_tax_rate":0.06625,"county_amount":0.0,"county_tax_rate":0.0,"county_taxable_amount":0.0,"id":"testId1","special_district_amount":0.0,"special_district_taxable_amount":0.0,"special_tax_rate":0.0,"state_amount":0.99,"state_sales_tax_rate":0.06625,"state_taxable_amount":15.0,"tax_collectable":0.99,"taxable_amount":15.0}],"shipping":{"city_amount":0.0,"city_tax_rate":0.0,"city_taxable_amount":0.0,"combined_tax_rate":0.06625,"county_amount":0.0,"county_tax_rate":0.0,"county_taxable_amount":0.0,"special_district_amount":0.0,"special_tax_rate":0.0,"special_taxable_amount":0.0,"state_amount":0.1,"state_sales_tax_rate":0.06625,"state_taxable_amount":1.5,"tax_collectable":0.1,"taxable_amount":1.5},"special_district_tax_collectable":0.0,"special_district_taxable_amount":0.0,"special_tax_rate":0.0,"state_tax_collectable":2.09,"state_tax_rate":0.06625,"state_taxable_amount":31.5,"tax_collectable":2.09,"taxable_amount":31.5},"freight_taxable":true,"has_nexus":true,"jurisdictions":{"city":"RAMSEY","country":"US","county":"BERGEN","state":"NJ"},"order_total_amount":31.5,"rate":0.06625,"shipping":1.5,"tax_source":"destination","taxable_amount":31.5}}';
    }
}
