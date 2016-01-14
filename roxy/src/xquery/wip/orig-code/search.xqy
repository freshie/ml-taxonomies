xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";
declare variable $keywords := xdmp:get-request-field( "keywords", "" );
declare variable $selected-scheme := xdmp:get-request-field( "scheme", "All" );
declare variable $selected-order := xdmp:get-request-field( "order", "Relatedness" );

declare function local:select-scheme() {
    <select name="scheme" class="form-control">
    {
    if ( $selected-scheme = "All" )
        then <option value="All" selected="selected">All</option>
        else <option value="All">All</option>
    }
    {
    for $scheme in xdmp:directory( $core, "infinity" )//sem:triple[
        sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
        sem:object = "http://www.w3.org/2004/02/skos/core#ConceptScheme"]/sem:subject/text()
    let $label := semantics:get-label( $scheme )
    return
        if ( $scheme = $selected-scheme )
            then <option value="{ $scheme }" selected="selected">{ $label }</option>
            else <option value="{ $scheme }">{ $label }</option>
    }
    </select>
};

declare function local:select-order() {
    <select name="order" class="form-control">
    {
    for $order in ("Relatedness","Relevance")
    return
        if ( $order = $selected-order )
            then <option value="{ $order }" selected="selected">{ $order }</option>
            else <option value="{ $order }">{ $order }</option>
    }
    </select>
};


let $query :=
    cts:and-query((
        cts:directory-query( $core, "infinity" ),
        cts:element-value-query(
            xs:QName( "sem:predicate" ),
            (
            "http://www.w3.org/2004/02/skos/core#prefLabel",
            "http://www.w3.org/2004/02/skos/core#altLabel",
            "http://www.w3.org/2004/02/skos/core#hiddenLabel",
            "http://www.lds.org/core#doctrinalStatement"
            ) ),
        cts:word-query( $keywords )
    ))
let $results :=
    if ( $keywords )
        then cts:search( //sem:triple, $query )
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
                { core:main-menu( "Search" ) }        
                </ul>
                <h3 class="text-muted">Core Taxonomies</h3>
            </div>

            <form class="form-inline" method="get" action="search.xqy">

            <div class="row">
                <div class="col-lg-12">
                    <div class="input-group">
                        <input name="keywords" value="{ $keywords }" type="text" class="form-control"/>
                        <span class="input-group-btn">
                            <button class="btn btn-default" type="submit">Search</button>
                        </span>
                    </div><!-- /input-group -->
                </div><!-- /.col-lg-6 -->
            </div>
            <hr/>
            <div class="row">
                <div class="col-lg-4">
                    <p>{ local:select-scheme() }</p>
                    <p>{ local:select-order() }</p>
                </div>
                <div class="col-lg-8">
                    <ul class="list-group">
                    {
                    for $triple in $results
                    let $subject := $triple/sem:subject/text()
                    let $label := semantics:get-label( $subject )
                    let $rels := xs:int( $triple/../@rels )
                    order by
                        if ( $selected-order = "Relevance" )
                            then ()
                            else $rels
                        descending
                    return
                        <li class="list-group-item">
                            <span class="badge">{ $rels }</span>
                            <h4><a href="concept.xqy?s={ $subject }">{ $label }</a></h4>
                            { $subject }
                        </li>
                    }
                    </ul>
                </div>
            </div>
            </form>
            
        </div> <!-- /container -->

  </body>
</html>
