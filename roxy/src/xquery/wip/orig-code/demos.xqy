xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";

declare function local:select-degree( $selected-degree ) {
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
            if ( $degree/@value = $selected-degree )
                then <option value="{ xs:string( $degree/@value ) }" selected="selected">{ $degree/text() }</option>
                else <option value="{ xs:string( $degree/@value ) }">{ $degree/text() }</option>
        }
        </select>
};


let $keywords := xdmp:get-request-field( "keywords", "" )
let $selected-degree := xdmp:get-request-field( "degree", "0" )
let $matches :=
    if ( $selected-degree gt "0" )
        then xdmp:directory( $core, "infinity" )//sem:triple[(
            sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel" or
            sem:predicate = "http://www.w3.org/2004/02/skos/core#altLabel" or
            sem:predicate = "http://www.w3.org/2004/02/skos/core#hiddenLabel") and 
            fn:lower-case( sem:object ) = fn:lower-case( $keywords )]/sem:subject/text()
        else ()
let $expanded-keywords :=
    for $match in $matches
    let $rels := xdmp:directory( $core, "infinity" )//sem:triple[
        sem:subject = $match and
        sem:predicate = "http://www.w3.org/2004/02/skos/core#related"]/sem:object/text()
    let $rels2 :=
        if ( $selected-degree = "2" )
            then
                for $subject in $rels
                return
                    xdmp:directory( $core, "infinity" )//sem:triple[
                        sem:subject = $subject and
                        sem:predicate = "http://www.w3.org/2004/02/skos/core#related"]/sem:object/text()
            else ()
    return
        for $rel in fn:distinct-values( ($rels,$rels2) )
        let $label := xdmp:directory( $core, "infinity" )//sem:triple[
            sem:subject = $rel and
            sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/text()
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
                then cts:search( //ldswebml[@type = "image"], cts:element-value-query( xs:QName( "subject" ), $expanded-keywords, ("case-insensitive") ) )[1 to 20]
                else cts:search( //ldswebml[@type = "image"], cts:element-value-query( xs:QName( "subject" ), $keywords, ("case-insensitive") ) )[1 to 20]
        else ()
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content=""/>
    <meta name="author" content=""/>

    <title>Doctrine T-Core</title>

    <!-- Latest compiled and minified CSS -->
    <link href="/sem/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    
    <!-- Custom styles for this template -->
    <link href="/sem/bootstrap/css/jumbotron-narrow.css" rel="stylesheet"/>

    <!-- GlyphIcons -->
    <link href="/sem/bootstrap/css/bootstrap-glyphicons.css" rel="stylesheet"/>

    <!-- Latest compiled and minified JavaScript -->
    <script src="http://code.jquery.com/jquery.js"></script>

    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/sem/bootstrap/js/bootstrap.min.js"></script>
    
  </head>

  <body xmlns="">

    <div class="container-narrow">
        <div class="header">
            <ul class="nav nav-pills pull-right">
            { core:main-menu( "Demos" ) }        
            </ul>
            <h3 class="text-muted">Core Taxonomies</h3>
        </div>
        
        <div class="row">
            <div class="col12 col-sm-12 col-lg-12">
                <form class="form-inline" method="get" action="demos.xqy">
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
                        { local:select-degree( $selected-degree ) }
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
            let $img := $result//download-url[label eq "Mobile"]/path/text()
            let $subject-tags :=
                <p>
                {
                fn:string-join( 
                    for $subject in $result//subject/text()
                    return $subject
                , ", " )
                }
                </p>
            (: let $img := $result//images/small/text() :)
            return
                if ( $img )
                    then
                        <div class="col3 col-sm-3 col-lg-3">
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
</html>


(:
                    <div class="col-lg-6">
                        <div class="input-group">
                            <input name="keywords" value="{ $keywords }" type="text" class="form-control"/>
                            <span class="input-group-btn">
                                <button type="submit" class="btn btn-default">Search</button>
                            </span>
                        </div><!-- /input-group -->
                    </div><!-- /.col-lg-6 -->
                    <div class="col-lg-6">
                        <div class="input-group">
                        {
                        if ( $semantic = "true" )
                            then <input name="semantic" value="true" type="checkbox" checked="checked"> Expand search</input>
                            else <input name="semantic" value="true" type="checkbox"> Expand search</input>
                        }    
                        </div>
                    </div>
:)