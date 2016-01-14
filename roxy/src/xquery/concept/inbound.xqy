xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

import module namespace concept = "org.lds.gte.concept.functions" at "/concept/modules/functions.xqy";


declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $subject := xdmp:get-request-field( "s", "" );

let $pref-label := semantics:get-label( $subject )
return
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head($pref-label)}

    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("Explore")}

        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading">
                            <h3>{ $pref-label }</h3>
                            <p>The list below contains all of the concepts that have a semantic relationship with this concept.</p>
                        </div>
                        {concept:nav("inbound",$subject)} 

                        <!-- List group -->
                        <ul class="list-group">
                        {
                            for $concept in concept:getInboundConceptFromSubject($subject)
                            return
                             <li class="list-group-item">
                                <div class="text-muted"><em>{ $concept/predicate-label/xs:string(.) }</em></div>
                                <div><a href="{$core:siteRootURL}concept/outbound.xqy?s={ $concept/subject/xs:string(.) }">{ $concept/label/xs:string(.) }</a></div>
                            </li>
                        }
                        </ul>
                    </div><!-- Panel -->
                </div>
            </div>
        </div> <!-- /container -->
    </body>
    {display:bottomIncludes()}
</html>