xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $keywords := xdmp:get-request-field( "keywords", "" );
declare variable $selected-scheme := xdmp:get-request-field( "scheme", "All" );
declare variable $selected-order := xdmp:get-request-field( "order", "Relatedness" );

declare function local:select-scheme() as element (select) {
    <select name="scheme" class="form-control">
    {
        if ( $selected-scheme eq "All" )
        then <option value="All" selected="selected">All</option>
        else <option value="All">All</option>
    }
    { 
    for $scheme in semantics:getSubjectByObjectPredicateDirectiory("http://www.w3.org/2004/02/skos/core#ConceptScheme","http://www.w3.org/1999/02/22-rdf-syntax-ns#type", $core:taxonomy-path)
    let $label := semantics:get-label($scheme)
    return
        if ( $scheme eq $selected-scheme )
        then <option value="{ $scheme }" selected="selected">{ $label }</option>
        else <option value="{ $scheme }">{ $label }</option>
    }
    </select>
};

declare function local:select-order() as element (select) {
    <select name="order" class="form-control">
    {
    for $order in ("Relatedness","Relevance")
    return
        if ( $order eq $selected-order )
            then <option value="{ $order }" selected="selected">{ $order }</option>
            else <option value="{ $order }">{ $order }</option>
    }
    </select>
};

let $results :=
    if ($keywords ne "")
        then 
            let $predicates := 
            (
                "http://www.w3.org/2004/02/skos/core#prefLabel", 
                "http://www.w3.org/2004/02/skos/core#hiddenLabel", 
                "http://www.lds.org/core#doctrinalStatement"
            )
            return semantics:getTripleByPredicateDirectioryWord($predicates, $core:taxonomy-path, $keywords)
        else ()
return
    if (fn:count( $results ) eq 1)
    then xdmp:redirect-response( $core:siteRootURL || "concept/outbound.xqy?s=" || $results/sem:subject/xs:string(.) )
    else       
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
       
        {display:head("Search")}
        
        <body xmlns="">
          <!-- Fixed navbar -->
           {display:nav("Search")}

            <div class="container">

                <div class="row">
                    <div class="col-lg-4">
                        <form class="form-inline" method="get" action="{$core:siteRootURL}search/">
                            <p class="input-group">
                                <input name="keywords" value="{ $keywords }" type="text" class="form-control typeahead"/>
                                
                            </p><!-- /input-group -->
                            <p>{ local:select-scheme() }</p>
                            <p>{ local:select-order() }</p>
                            <span class="input-group-btn">
                                    <button class="btn btn-default" type="submit">Search</button>
                                </span>
                        </form>
                    </div>
                    <div class="col-lg-8">
                        { if ( fn:count( $results ) = 0 and $keywords ne "" ) then <p>No results for { $keywords }</p> else () } 
                        <ul class="list-group">
                        {
                        for $triple in $results
                        let $subject := $triple/sem:subject/xs:string(.)
                        let $label := semantics:get-label($subject)
                        let $rels := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.lds.org/core#relCount", $core:taxonomy-path)
                        let $definition := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.w3.org/2004/02/skos/core#definition", $core:taxonomy-path)
                        let $highlightedDefinition := cts:highlight(<div>{$definition}</div>, $keywords,  <mark>{$cts:text}</mark>)
                        order by
                            if ($selected-order = "Relevance")
                            then ()
                            else xs:int($rels)
                            descending
                        return
                            <li class="list-group-item">
                                <span class="badge">{ $rels }</span>
                                <h4><a href="{$core:siteRootURL}concept/outbound.xqy?s={ $subject }">{ $label }</a></h4>
                                { if ( $definition ) then $highlightedDefinition else () }
                                <div class="text-muted"><em>{ $subject }</em></div>
                            </li>
                        }
                        </ul>
                    </div>
               </div>
                
            </div> <!-- /container -->

      </body>
      {display:bottomIncludes()}
    </html>