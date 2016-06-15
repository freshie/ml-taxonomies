import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

let $assert := user:assertPrivilege("editor")

let $title := xdmp:get-request-field( "title", "" )
let $key := xdmp:get-request-field( "key", "" )
let $description := xdmp:get-request-field( "description", "" )

let $taxonmyPath := $core:baseURI || "admin/taxonomies/"

let $path := $taxonmyPath || $key || ".xml"

(: Error conditions :)
let $error-key-exists := xs:string(fn:doc-available($path))
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
        <owner>{ $user:user }</owner>
    </taxonomy>
return
    (:
        if Any of the error checks come back as true we redirect
    :)  
    if (  $errors eq "true" ) then (
        xdmp:redirect-response( $core:siteRootURL || "taxonomy/add.xqy" || $response ) 
    ) else (
        let $update :=
            xdmp:invoke(
                "/utility/insert.xqy",
                (
                    xs:QName("URI"), $path,
                    xs:QName("ROOT"), $new-taxonomy,
                    xs:QName("PERMISSIONS"), <permissions>{xdmp:default-permissions()}</permissions>,
                    xs:QName("COLLECTIONS"), <collections/>,
                    xs:QName("QUALITY"), 0,
                    xs:QName("FORESTS"), <forests/>
                )
            )
        return
            xdmp:redirect-response( $core:siteRootURL )
    )