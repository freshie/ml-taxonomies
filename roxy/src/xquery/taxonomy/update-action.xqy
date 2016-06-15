import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

let $assert := user:assertPrivilege("editor")

let $title := xdmp:get-request-field( "title", "" )
let $key := xdmp:get-request-field( "key", "" )
let $description := xdmp:get-request-field( "description", "" )
let $previousKey := xdmp:get-request-field( "previousKey")

let $taxonmyPath := $core:baseURI || "admin/taxonomies/"

let $previousPath := $taxonmyPath || $previousKey || ".xml"

let $path := $taxonmyPath || $key || ".xml"

(: Error conditions :)
let $error-key-exists :=
    if ($previousPath eq $path) then (
        "false"
    ) else ( 
        xs:string(fn:doc-available($path))
    )
let $error-key-missing := xs:string( $key = "" )
let $error-title-missing := xs:string( $title = "" )
let $error-description-missing := xs:string( $description = "" )
let $errors := ($error-key-exists,$error-key-missing,$error-title-missing,$error-description-missing)
let $response := fn:concat(
        "?errors=", fn:string-join( $errors, "," ),
        "&amp;previousKey=", $previousKey
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
        xdmp:redirect-response( $core:siteRootURL || "taxonomy/update.xqy" || $response ) 
    ) else (
        (:
            TODO: update code to update all the refs to the old uri
        :)
        let $update :=
            xdmp:invoke(
                "/utility/insert.xqy",
                (
                    xs:QName("URI"), $path,
                    xs:QName("ROOT"), $new-taxonomy,
                    xs:QName("PERMISSIONS"), <permissions>{xdmp:document-get-permissions($previousPath)}</permissions>,
                    xs:QName("COLLECTIONS"), <collections/>,
                    xs:QName("QUALITY"), 0,
                    xs:QName("FORESTS"), <forests/>
                )
            )
        (:
            Checks to see if we need to delete the old document
            if we do it delets it
        :)    
        let $delete :=
             if ($previousPath ne $path) then (
                xdmp:invoke(
                    "/utility/delete.xqy",
                    (
                        xs:QName("URI"), $previousPath
                    )
                )
            ) else ()
        
        return
            xdmp:redirect-response( $core:siteRootURL )
    )