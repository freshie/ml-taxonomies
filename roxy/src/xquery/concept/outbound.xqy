xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

import module namespace concept = "org.lds.gte.concept.functions" at "/concept/modules/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $subject := xdmp:get-request-field( "s", "" );
declare variable $selected-predicate := xdmp:get-request-field( "p", "" );
declare variable $selected-language := xdmp:get-request-field( "lang", "eng" );

let $predicates := semantics:get-predicates-list()
let $triples := semantics:getTripleBySubjectDirectiory($subject, $core:taxonomy-path)
    
let $pref-label := $triples[sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/xs:string(.)
let $hasAdminEditor := core:has-role( $core:roles, "admin,editor" )
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
                            <p>The list below contains all of the properties and instances of this concept, as well as all of the concepts to which it is semantically related.</p>
                        </div>

                        {concept:nav("Outbound",$subject)}
                        <!-- List group -->
                        <ul class="list-group">
                        {
                            for $p in $predicates/predicate/@value
                                let $predicateLabel := semantics:get-label($p)
                                let $dataType := semantics:get-data-type( $p)
                                let $predicate := fn:escape-uri( $p, fn:true() )
                            return 
                                for $concept in concept:getConceptFromTriples($triples[sem:predicate eq $p])
                                    let $conceptSubject := $concept/subject/xs:string(.) 
                                    let $conceptObject := $concept/object/xs:string(.)
                                    let $objectLabel := $concept/objectLabel/xs:string(.)  
                                    let $schemeLabel := $concept/schemeLabel/xs:string(.)
                                    let $schemeLabel := if ($schemeLabel)  then "(" || $schemeLabel || ")" else ()
                                    let $lang := $concept/lang/xs:string(.)
                                return
                                    <li class="list-group-item">
                                        {
                                            if ($hasAdminEditor)
                                            then
                                                <div class="pull-right">
                                                    <a href="{$core:siteRootURL}concept/edit.xqy?s={$conceptSubject}&amp;p={$predicate}&amp;o={$conceptObject}"><span class="glyphicon glyphicon-file"></span></a>&nbsp;
                                                    <a href="{$core:siteRootURL}concept/delete.xqys={$conceptSubject}&amp;p={$predicate}&amp;o={$conceptObject}"><span class="glyphicon glyphicon-trash"></span></a>
                                                </div>
                                            else ()
                                        }
                                       
                                        <div class="text-muted">
                                            <div><em>{$predicateLabel}</em></div>
                                            <div>
                                                {
                                                    if ($dataType eq "http://www.w3.org/2001/XMLSchema#anyURI")
                                                    then 
                                                        <span>
                                                            <a href="{ $conceptObject }">{$conceptObject}</a> {$schemeLabel}
                                                        </span>
                                                    
                                                    else if ($dataType eq "http://www.marklogic.com/semantics#iri")
                                                    then 
                                                        <span>
                                                            <a href="{$core:siteRootURL}concept/outbound.xqy?s={ $conceptObject }">{$objectLabel}</a> {$schemeLabel}
                                                        </span>
                                                    
                                                    else 
                                                        <span>
                                                            { $objectLabel || " " || $schemeLabel }
                                                        </span>
                                                }
                                                { 
                                                    if ( $lang ) 
                                                    then " (" || $lang || ")"  
                                                    else () 
                                                }
                                            </div>
                                        </div>
                                    </li>
                        }
                        </ul>
                    { (:TODO: look at when we redo the users :)
                    if ($hasAdminEditor)
                        then
                            let $languages := 
                                cts:search(
                                  /languages/language, 
                                  cts:and-query((
                                    cts:document-query( $core:model || "languages.xml")
                                  ))
                                )
                            return
                                <div>    
                                    <form action="{$core:siteRootURL}concept-add-triple.xqy" method="post" class="form-inline">
                                        <input type="hidden" name="subject" value="{ $subject }"/>
                                        <p class="input-group">
                                            <span class="input-group-addon input-sm">Predicate</span>
                                            <select name="predicate" class="form-control input-sm">
                                            {
                                            for $predicate in $predicates/predicate
                                            order by $predicate
                                            return
                                                if ( xs:string( $predicate/@value ) eq $selected-predicate )
                                                    then <option value="{ xs:string( $predicate/@value ) }" selected="selected">{ $predicate/xs:string(.) }</option>
                                                    else <option value="{ xs:string( $predicate/@value ) }">{ $predicate/xs:string(.) }</option>
                                            }
                                            </select>
                                        </p>
                                        <p class="input-group">
                                            <span class="input-group-addon input-sm">Object</span>
                                            <input id="object" name="object" type="text" class="form-control ui-widget" placeholder="Enter a string or valid IRI"/>
                                        </p>
                                        <p class="input-group">
                                            <span class="input-group-addon input-sm">Language</span>
                                            <select name="language" class="form-control input-sm">
                                            {
                                            for $lang in $languages
                                            order by $lang/label/xs:string(.)
                                            return
                                                if ( xs:string( $lang/code/xs:string(.)) eq $selected-language )
                                                    then <option value="{ $lang/code/xs:string(.) }" selected="selected">{ $lang/label/xs:string(.) }</option>
                                                    else <option value="{ $lang/code/xs:string(.) }">{ $lang/label/xs:string(.) }</option>
                                            }
                                            </select>
                                        </p>
                                        <button type="submit" class="btn btn-primary">Add triple</button>
                                    </form>
                                </div>
                        else ()
                    }
                </div><!-- Panel -->
            </div>
        </div>
        
    </div> <!-- /container -->
    

    </body>
    {display:bottomIncludes()}
</html>
