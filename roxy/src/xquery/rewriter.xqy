xquery version "1.0-ml";

let $requestPath := xdmp:get-request-url()
return 
   fn:replace($requestPath, "/gte20/", "/")