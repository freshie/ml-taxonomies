import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $title := xdmp:get-request-field( "title", "" )
let $key := xdmp:get-request-field( "key", "" )
let $description := xdmp:get-request-field( "description", "" )
let $path := fn:concat( "/published/gospel-topical-explorer/", $key, ".xml" )

(: Error conditions :)
let $error-key-exists := xs:string( fn:exists( fn:doc()//taxonomy[@key = $key] ) )
let $error-key-missing := xs:string( $key = "" )
let $error-title-missing := xs:string( $title = "" )
let $error-description-missing := xs:string( $description = "" )
let $errors := ($error-key-exists,$error-key-missing,$error-title-missing,$error-description-missing)
let $response := fn:concat(
        "?errors=", fn:string-join( $errors, "," ),
        "&amp;key=", $key,
        "&amp;title=", $title,
        "&amp;description=", $description
    )
let $new-taxonomy :=
    <taxonomy key="{ $key }">
        <title>{ $title }</title>
        <description>{ $description }</description>
        <owner>{ $user }</owner>
    </taxonomy>
return
    if ( $user = "public" )
        then xdmp:redirect-response( "sign-in.xqy?error=timeout" )
        else
    if ( fn:index-of( $errors, "true" ) > 0 )
        then xdmp:redirect-response( fn:concat( "taxonomy-add.xqy", $response ) )
        else (xdmp:document-insert( $path, $new-taxonomy ),xdmp:redirect-response( "default.xqy" ))