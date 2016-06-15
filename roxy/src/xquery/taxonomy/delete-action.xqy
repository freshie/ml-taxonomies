import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

let $assert := user:assertPrivilege("editor")

let $key := xdmp:get-request-field( "key", "" )

let $taxonmyPath := $core:baseURI || "admin/taxonomies/"

let $path := $taxonmyPath || $key || ".xml"

(:
    TODO: update this so it will delete the triples that are assigned to this taxonmiy 
:)
let $delete :=
    xdmp:invoke(
        "/utility/delete.xqy",
        (
            xs:QName("URI"), $path
        )
    )
return
    xdmp:redirect-response( $core:siteRootURL )