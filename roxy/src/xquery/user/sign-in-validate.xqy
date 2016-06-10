import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

let $username := xdmp:get-request-field( "username", "" )
let $password := xdmp:get-request-field( "password", "" )
let $success := xdmp:login(  $core:applicationConfig/name/text() || "-" ||  $username, $password)
return
    if ( $success ) then (
    	xdmp:redirect-response( $core:siteRootURL )
    ) else (
    	xdmp:redirect-response( $core:siteRootURL || "user/sign-in.xqy?error=failed" )
    )