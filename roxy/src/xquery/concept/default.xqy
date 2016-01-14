xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

import module namespace concept = "org.lds.gte.concept.functions" at "/concept/modules/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $subject := xdmp:get-request-field( "s", "" );

if   ($subject ne "")
then (xdmp:redirect-response($core:siteRootURL || "concept/outbound.xqy?s=" || $subject))
else 
    let $selected-scheme := xdmp:get-request-field( "scheme", "All" )
    let $letter := xdmp:get-request-field( "letter", "a" )
    let $concepts := concept:getConceptByLetter($letter, $selected-scheme)
    return
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
        
        {display:head("Browse")}
        
        <body xmlns="">

        {display:nav("Explore")} 

        <div class="container">
        
            <div class="row">
                <div class="col-lg-4">
                    <form class="form-inline" method="get" action="{$core:siteRootURL}concept/">
                        <p>
                           <select name="scheme" class="form-control">
                            {
                                if ( $selected-scheme = "All" )
                                then <option value="All" selected="selected">All concept schemes</option>
                                else <option value="All">All concept schemes</option>
                            }
                            {
                                for $scheme in semantics:get-schemes-list()/scheme
                                return
                                    if ( $scheme/xs:string(.) = $selected-scheme )
                                    then <option value="{ $scheme/xs:string(.) }" selected="selected">{ xs:string( $scheme/@label ) }</option>
                                    else <option value="{ $scheme/xs:string(.) }">{ xs:string( $scheme/@label ) }</option>
                            }
                            </select>
                        </p>
                        <p>
                            <select name="letter" class="form-control">
                            {
                            for $l in ("All","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
                            let $lower :=  fn:upper-case( $l )
                            return
                                if ( $l = $letter )
                                    then <option value="{ $l }" selected="selected">{$lower}</option>
                                    else <option value="{ $l }">{$lower}</option>
                            }
                            </select>
                        </p>
                        <p>
                            <button class="btn btn-default" type="submit">Filter</button>
                        </p>
                    </form>
                </div>
                <div class="col-lg-8"><!-- First column -->
                    <ul class="list-group">
                    {
                    for $concept in $concepts/concept
                    order by $concept/label
                    return
                        <li class="list-group-item">
                            <h4><a href="{$core:siteRootURL}concept/outbound.xqy?s={ xs:string( $concept/@uri ) }">{ $concept/label/xs:string(.) }</a></h4>
                            { if ( $concept/parent/xs:string(.) ) then <h6>Narrower than: { $concept/parent/xs:string(.) }</h6> else () }
                            <h6 class="text-muted"><em>{ $concept/scheme/xs:string(.) }</em></h6>
                        </li>
                    }
                    </ul>
                </div>
            </div><!-- /row -->

        </div> <!-- /container -->

      </body>
       {display:bottomIncludes()}
    </html>