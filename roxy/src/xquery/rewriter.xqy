xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

let $requestPath := xdmp:get-request-url()
return 
   fn:replace($requestPath, $core:siteRootURL, "/")