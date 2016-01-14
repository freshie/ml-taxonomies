xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

let $keywords := xdmp:get-request-field( "keywords", "" )
let $selected-degree := xdmp:get-request-field( "degree", "0" )
let $matches :=
    if ($selected-degree gt "0" )
    then 
        let $predicates :=
            ("http://www.w3.org/2004/02/skos/core#prefLabel", "http://www.w3.org/2004/02/skos/core#altLabel", "http://www.w3.org/2004/02/skos/core#hiddenLabel")
        let $lower := fn:lower-case($keywords)
        return 
         (: doing it this way for now because of the data string type of eng and the lowercasing :)
          xdmp:directory( $core:taxonomy-path, "infinity" )//sem:triple[
            sem:predicate eq ("http://www.w3.org/2004/02/skos/core#prefLabel","http://www.w3.org/2004/02/skos/core#altLabel","http://www.w3.org/2004/02/skos/core#hiddenLabel") and 
            fn:lower-case(sem:object) = $lower ]/sem:subject/text()
    else ()
let $expanded-keywords :=
    for $match in $matches
    let $rels := semantics:getObjectBySubjectPredicateDirectiory($match, "http://www.w3.org/2004/02/skos/core#related", $core:taxonomy-path)
    let $rels2 :=
        if ( $selected-degree eq "2" )
        then
            for $subject in $rels
            return
                 semantics:getObjectBySubjectPredicateDirectiory($subject,"http://www.w3.org/2004/02/skos/core#related", $core:taxonomy-path)
        else ()
    return
        for $rel in fn:distinct-values( ($rels,$rels2) )
        let $label := semantics:get-label( $rel )
        return $label
let $query :=
    if ( $selected-degree gt "0" )
    then
        cts:or-query((
            for $word in $expanded-keywords
            return cts:word-query( $word, "case-insensitive" )
        ))
    else
        cts:or-query( cts:word-query( $keywords, "case-insensitive" ) )
let $results :=
    if ( $keywords )
    then
        if ( $selected-degree gt "0" )
        then cts:search(/ldswebml[@type eq "image"], cts:element-value-query( xs:QName( "subject" ), $expanded-keywords, ("case-insensitive") ) )[1 to 20]
        else cts:search(/ldswebml[@type eq"image"], cts:element-value-query( xs:QName( "subject" ), $keywords, ("case-insensitive") ) )[1 to 20]
    else ()
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
   {display:head("Image Demo")}

    <body xmlns="">
        {display:nav("Explore")} 
        
        <div class="container">
            <div class="row">
                <div class="col12 col-sm-12 col-lg-12">
                    <form class="form-inline" method="get" action="{$core:siteRootURL}search/images.xqy">
                        <div class="col-lg-8">
                            <div class="input-group">
                                <input name="keywords" value="{ $keywords }" type="text" class="form-control"/>
                                <span class="input-group-btn">
                                    <button type="submit" class="btn btn-default">Search</button>
                                </span>
                            </div><!-- /input-group -->
                        </div><!-- /.col-lg-6 -->
                        <div class="col-lg-4">
                            <div class="input-group">
                            { 
                                let $degrees :=
                                    <degrees>
                                        <degree value="0">Normal</degree>
                                        <degree value="1">Expand 1 degree</degree>
                                        <degree value="2">Expand 2 degrees</degree>
                                    </degrees>
                                return
                                    <select name="degree" class="form-control">
                                    {
                                    for $degree in $degrees/degree
                                    return
                                        if ( $degree/@value eq $selected-degree )
                                        then <option value="{ xs:string( $degree/@value ) }" selected="selected">{ $degree/xs:string(.) }</option>
                                        else <option value="{ xs:string( $degree/@value ) }">{ $degree/xs:string(.) }</option>
                                    }
                                    </select>
                            }
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <hr/>
            
            <div class="row">
                <div class="col12 col-sm-12 col-lg-12">
                {
                    if ( $results or fn:not( $keywords ) )
                    then ()
                    else
                        <div class="alert">
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                            <strong>Sorry.</strong> No triples match your query.
                        </div>
                }
                {
                for $result in $results
                let $img := $result//download-url[label eq "Mobile"]/path/xs:string(.)
                let $subject-tags :=
                    <p>
                    {
                    fn:string-join( 
                        for $subject in $result//subject/xs:string(.)
                        return $subject
                    , ", " )
                    }
                    </p>
                (: let $img := $result//images/small/xs:string(.) :)
                return
                    if ( $img )
                        then
                            <div class="col2 col-sm-2 col-lg-2">
                                <div class="thumbnail">
                                    <img src="{ $img }"/>
                                    <div class="caption">
                                    { cts:highlight( $subject-tags, $query, <b>{ $cts:text }</b> ) }
                                    </div>
                                </div>
                            </div>
                    else ()
                    }
                </div>
            </div>
            {
            if ( $expanded-keywords )
                then
                    (<hr/>,
                    <div class="row">
                        <div class="col-lg-12">
                            <h6 class="text-muted">Expanded keywords: { fn:string-join( $expanded-keywords, "; " ) }</h6>
                        </div>
                    </div>)
                else ()
            }

    </div> <!-- /container -->

    </body>
    {display:bottomIncludes()}
</html>
