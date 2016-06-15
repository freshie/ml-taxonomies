xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

declare option xdmp:output "method = html";

let $assert := user:assertPrivilege("editor")
let $errors := fn:tokenize( xdmp:get-request-field( "errors", "" ), "," )
let $key := xdmp:get-request-field( "key")
let $title-error := 
    if ( $errors[1] = "true" or $errors[2] = "true" ) then (
    " has-error"
    ) else (
        ""
    )

let $key-error := 
    if ( $errors[3] = "true" ) then (
        " has-error"
    ) else ( 
        ""
    )

let $description-error := 
    if ( $errors[4] = "true" ) then (
        " has-error"
    ) else ( 
        ""
    )
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">

    {display:head("Home")}

    <body xmlns="">

        {display:nav("Add")} 

        <div class="container">
            <div class="row">
                
                    <div class="panel">
                        <!-- Default panel contents -->
                        <h2 class="panel-heading">Delete Taxonomy</h2>
                        <p> Are you Sure you want to delete the below taxonmy?</p>
                        {
                            let $taxonomy:= core:getTaxonomyByKey( $key)
                            return
                            <div class="col-lg-12">
                                <h2>{ $taxonomy/title/xs:string(.) }</h2>
                                <em class="text-muted">{$key}</em>
                                <p>{ $taxonomy/description/xs:string(.) }</p>
                                    
                            </div>
                        }
                        <p> </p>
                        <div class="btn-group" style="margin-top: 20px;">
                            <a class="btn btn-danger" href="{$core:siteRootURL}taxonomy/delete-action.xqy?key={ $key }" >Delete Taxonomy</a>
                        </div> 
                    </div><!-- Panel -->
            </div>
        </div> <!-- /container -->

    </body>
</html>