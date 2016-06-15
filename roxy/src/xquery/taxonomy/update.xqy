xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

declare option xdmp:output "method = html";

let $assert := user:assertPrivilege("editor")
let $errors := fn:tokenize( xdmp:get-request-field( "errors", "" ), "," )
let $previousKey := xdmp:get-request-field( "previousKey")
let $taxonomyData:= core:getTaxonomyByKey( $previousKey)

let $title := $taxonomyData/title/text()
let $key :=  xs:string($taxonomyData/@key)
let $description :=  $taxonomyData/description/text()

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

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <h2 class="panel-heading">Update Taxonomy</h2>
                    <p></p>

                    <form method="post" action="{$core:siteRootURL}taxonomy/update-action.xqy?previousKey={$previousKey}">
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                { if ( $errors[1] = "true" ) then <p class="text-danger">A taxonomy with key "{ $title }" already exists.</p> else () }
                                <div class="input-group{ $title-error }">
                                    <span class="input-group-addon">Title</span>
                                    <input name="title" value="{ $title }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group{ $key-error }">
                                    <span class="input-group-addon">Key</span>
                                    <input name="key" value="{ $key }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group{ $description-error }">
                                    <span class="input-group-addon">Description</span>
                                    <textarea name="description" rows="4" class="form-control">{ $description }</textarea>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <button type="submit" class="btn btn-success " style=" margin-right: .5em;">Update</button> <a class="btn btn-danger" href="{$core:siteRootURL}taxonomy/delete.xqy?key={ $previousKey }" style=" margin-right: .5em;">Delete</a>
                            </li>
                        </ul>
                        
                    </form>
                </div><!-- Panel -->
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <h3 class="panel-heading">Other Existing Taxonomies</h3>
                    <p class="panel-body">A taxonomy is a distinct grouping of terms. A taxonomy includes at least one concept scheme.</p>
                    
                    <div>
                        <ul class="list-group">
                        {
                            for $taxonomy in core:getTaxonomys()
                            let $title := $taxonomy/title/text()
                            let $key := xs:string( $taxonomy/@key )
                            let $description := $taxonomy/description/text()
                            let $owner := $taxonomy/owner/text()
                            where $previousKey ne $key
                            order by $title

                            return
                                <li class="list-group-item">
                                    <h4 class="list-group-item-heading">{ $title }  </h4>
                                    <em class="text-muted">{$key}</em>
                                    <div class="list-group-item-text">{ $description }</div>
                                </li>
                        }
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        
    </div> <!-- /container -->

    </body>
</html>