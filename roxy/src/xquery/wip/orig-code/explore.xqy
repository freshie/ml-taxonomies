xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";

let $letter := xdmp:get-request-field( "letter", "a" )
let $concepts :=
    <concepts>
    {
    for $triple in xdmp:directory( $core, "infinity" )//sem:triple[
        sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
        sem:object = "http://www.w3.org/2004/02/skos/core#Concept"]
    let $subject := $triple/sem:subject/text()
    let $scheme := xdmp:directory( $core, "infinity" )//sem:triple[
        sem:subject = $subject and
        sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme"]/sem:object/text()
    let $scheme :=
        if ( $scheme = "http://lds.org/concept-scheme/curriculum-planning-guide" )
            then "Curriculum Planning Guide"
            else
        if ( $scheme = "http://lds.org/concept-scheme/guide-to-the-scriptures" )
            then "Guide to the Scriptures"
            else "Indepenent"
    let $parent := xdmp:directory( $core, "infinity" )//sem:triple[
        sem:subject = $subject and
        sem:predicate = "http://www.w3.org/2004/02/skos/core#narrower"]/sem:object/text()
    let $rel-count := xs:string( $triple/../@rels )
    where $letter = "all" or fn:starts-with( fn:tokenize( $subject, "/" )[fn:last()], $letter )
    return
        <concept uri="{ xs:string( $subject ) }" rel-count="{ $rel-count }">
            <label>{ semantics:get-label( $subject ) }</label>
            <parent>{ semantics:get-label( $parent ) }</parent>
            <scheme>{ $scheme }</scheme>
        </concept>
    }
    </concepts>
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
            { core:main-menu( "Explore" ) }        
            </ul>
            <h3 class="text-muted">Core Taxonomies</h3>
        </div>
        
        <div class="row">
            <div class="col-11 col-sm-11 col-lg-11 col-offset-1 col-sm-offset-1 col-lg-offset-1">
                <p class="btn-group btn-group-justified">
                    <a href="concept.xqy?s=http://lds.org/concept/cpg/curriculum-planning-guide" class="btn btn-default">Curriculum Planning Guide</a>
                    <a href="concept.xqy?s=http://lds.org/concept/gs/jesus-christ" class="btn btn-default">Guide to the Scriptures</a>
                    <a href="concept-add.xqy" class="btn btn-default">Add Concept</a>
                </p>
            </div>
        </div>
        
        <div class="row">
            <div class="col-1 col-sm-1 col-lg-1">
                <div class="btn-group-vertical">
                {
                for $l in ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
                return
                    if ( $l = $letter )
                        then <button type="button" class="btn btn-default active"><a href="explore.xqy?letter={ $l }">{ fn:upper-case( $l ) }</a></button>
                        else <button type="button" class="btn btn-default"><a href="explore.xqy?letter={ $l }">{ fn:upper-case( $l ) }</a></button>
                }
                </div>
            </div>
            <div class="col-11 col-sm-11 col-lg-11"><!-- First column -->
                <table class="table table-striped table-bordered table-condensed">
                {
                for $concept in $concepts//concept
                order by $concept/label
                return
                    <tr>
                        <td>
                            <h3><a href="concept.xqy?s={ xs:string( $concept/@uri ) }">{ $concept/label/text() }</a> ({ xs:string( $concept/@rel-count ) })</h3>
                            { if ( $concept/parent/text() ) then <h6>Narrower than: { $concept/parent/text() }</h6> else () }
                            <h6 class="text-muted"><em>From the { $concept/scheme/text() }</em></h6>
                        </td>
                    </tr>
                }
                </table>
            </div>
        </div>
    </div> <!-- /container -->

  </body>
</html>
