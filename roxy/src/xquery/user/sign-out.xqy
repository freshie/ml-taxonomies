import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

let $_ := xdmp:logout()
return
	xdmp:redirect-response( $core:siteRootURL || "user/sign-in.xqy?logout=true" )