xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $ontology := xdmp:get-request-field( "ontology", "cpg-out" );
declare variable $ontologies :=
    <options>
        <option value="doctrine-filtered-out">Doctrine T-Core</option>
        <option value="cpg-out">Curriculum Planning Guide</option>
        <option value="core-out">Combined (no clustering)</option>
        <option value="core-out2">Combined</option>
    </options>;

declare option xdmp:output "method = html";

declare function local:select(
    $name as xs:string, 
    $options as element (options), 
    $selected as xs:string
) as element(select) {
    <select name="{$name}" class="form-control ui-widget">
    {
    for $option in $options/option
    return
        if ($selected eq $option/@value)
        then <option value="{ xs:string( $option/@value ) }" selected="selected">{ $option/xs:string(.) }</option>
        else <option value="{ xs:string( $option/@value ) }">{ $option/xs:string(.) }</option>
    }
    </select>
};

let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $onto-file := fn:concat( "data/", $ontology, ".gexf" )
return
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        {display:head("Visualize")/element()}

        <!-- Sigma Javascript -->
        <link href="{$core:cdnURL}css/sigma.css" rel="stylesheet"/>
        <script src="{$core:cdnURL}js/sigma/prettify.js"></script>
        <script src="{$core:cdnURL}js/sigma/sigma.js"></script>
        <script src="{$core:cdnURL}js/sigma/sigma.parseGexf.js"></script>
        <script src="{$core:cdnURL}js/sigma/sigma-{ $ontology }.js"></script>
    </head>

    <body onload="init('{ $onto-file }');" xmlns="">

        <!-- Fixed navbar -->
        {display:nav("Visualize")} 
        
       <div class="container">
        
            <div class="row">
                <div class="col-lg-12 sigma-parent" id="sigma-example-parent">
                    <div class="sigma-expand" id="sigma-example"></div>
                </div>                    
            </div>
            
            <div class="row">
                <div class="col-lg-12">
                    <p>
                        <form method="get" action="{$core:siteRootURL}visualize.xqy" class="form-inline">
                            <p class="input-group">
                                <span class="input-group-addon input-sm">Visualization</span>
                                { local:select( "ontology", $ontologies, $ontology ) }
                            </p>
                            <button type="submit" class="btn btn-primary">Display</button>
                        </form>
                    </p>
                </div>
            </div>

        </div>  <!-- /container -->
    </body>
    {display:bottomIncludes()}
</html>