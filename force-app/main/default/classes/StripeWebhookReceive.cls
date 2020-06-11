@RestResource(urlMapping='/stripeWebhook/*')
global with sharing class StripeWebhookReceive {
  @HttpPost
  global static Void receiveStripeWebhook() {
    Savepoint sp = Database.setSavepoint();
    try {
      system.debug(RestContext.request.requestBody.toString());

      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        RestContext.request.requestBody.toString()
      );
      system.debug(result);

      Map<String, Object> data = (Map<String, Object>) result.get('data');
      system.debug(data);

      Map<String, Object> obj = (Map<String, Object>) data.get('object');
      system.debug(obj);

      String subscriptionId = (String) obj.get('id');
      system.debug(subscriptionId);

      RestContext.response.statusCode = 200;
    } catch (Exception ex) {
      Database.rollback(sp);
      RestContext.response.statusCode = 500;
    }
  }
}
