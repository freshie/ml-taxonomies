let $username := xdmp:get-request-field( "username", "" )
let $password := xdmp:get-request-field( "password", "" )
let $success := xdmp:login( $username, $password, fn:true() )
let $foo :=
    if ( $success )
        then xdmp:set-session-field( "user", $username )
        else ()
return
    if ( $success )
        then xdmp:redirect-response( "default.xqy" )
        else xdmp:redirect-response( "sign-in.xqy?error=failed" )