public class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
   //Implement http mock callout failure here 
   public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(400);
      return res;
   }
}