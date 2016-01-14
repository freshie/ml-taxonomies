xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";

declare function local:display-triples( $triples, $predicate ) {
    let $predicate-label := semantics:get-label( $predicate )
    for $triple in $triples//sem:triple[sem:predicate = $predicate]
    let $object := $triple/sem:object/text()
    let $object-label :=
        if ( fn:starts-with( $object, "http:" ) )
            then semantics:get-label( $object )
            else $object
    let $object-label :=
        if ( fn:starts-with( $object, "http:" ) )
            then <a href="concept.xqy?s={ $object }">{ $object-label }</a>
            else $object-label
    let $s := fn:escape-uri( $triple/sem:subject/text(), fn:true() )
    let $p := fn:escape-uri( $predicate, fn:true() )
    let $o := fn:escape-uri( $object, fn:true() )
    order by $object-label
    return
        <li class="list-group-item">
            <div class="pull-right"><a href="concept-delete.xqy?s={ $s }&amp;p={ $p }&amp;o={ $o }"><span class="glyphicon glyphicon-remove"></span></a></div>
            <div class="text-muted">
                <div><em>{ $predicate-label }</em></div>
                <div>{ $object-label }</div>
            </div>
        </li>
};

declare function local:display-children( $triples, $s ) {
    for $subject in xdmp:directory( $core, "infinity" )//sem:triple[
        sem:object = $s and
        sem:predicate = "http://www.w3.org/2004/02/skos/core#narrower"]/sem:subject/text()
    let $label := semantics:get-label( $subject )
    return
        <li class="list-group-item">
            <div class="text-muted"><em>Broader than</em></div>
            <div><a href="concept.xqy?s={ $subject }">{ $label }</a></div>
        </li>
};


let $predicates := semantics:get-predicates-list()
let $subject := xdmp:get-request-field( "s", "" )
let $selected-predicate := xdmp:get-request-field( "p", "" )
let $triples :=
    xdmp:directory( $core, "infinity" )//sem:triple[
        sem:subject = $subject and
        sem:object = "http://www.w3.org/2004/02/skos/core#Concept"]/..
let $pref-label := $triples//sem:triple[
    sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/text()
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
        
        <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
        <!-- <script src="http://code.jquery.com/jquery-1.9.1.js"></script> -->
        <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  
        <script>
        $(function() {{
            $( "#object" ).autocomplete({{
                source: "concept-find.xqy",
                minLength: 3
            }});
        }});
        </script>
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
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading"><h3>{ $pref-label }</h3></div>
                    <p></p>
                
                    <!-- List group -->
                    <ul class="list-group">
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#narrower" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#narrowerTransitive" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#narrowMatch" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#broader" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#broaderTransitive" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#broadMatch" ) }
                    { local:display-children( $triples, $subject ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#closeMatch" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#exactMatch" ) }
                    { local:display-triples( $triples, "http://www.lds.org/core#doctrinalStatement" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#Collection" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#hiddenLabel" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#altLabel" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#mappingRelation" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#member" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#memberList" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#OrderedCollection" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#related" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#relatedMatch" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#semanticRelation" ) }
                    { local:display-triples( $triples, "http://www.lds.org/Thing#entity-type" ) }
                    { local:display-triples( $triples, "http://www.w3.org/2004/02/skos/core#inScheme" ) }
                    </ul>
                    <div>    
                        <form action="concept-add-triple.xqy" method="post" class="form-inline">
                            <input type="hidden" name="subject" value="{ $subject }"/>
                            <p class="input-group">
                                <span class="input-group-addon input-sm">Predicate</span>
                                <select name="predicate" class="form-control input-sm">
                                {
                                for $predicate in $predicates//predicate
                                order by $predicate
                                return
                                    if ( xs:string( $predicate/@value ) = $selected-predicate )
                                        then <option value="{ xs:string( $predicate/@value ) }" selected="selected">{ $predicate/text() }</option>
                                        else <option value="{ xs:string( $predicate/@value ) }">{ $predicate/text() }</option>
                                }
                                </select>
                            </p>
                            <p class="input-group">
                                <span class="input-group-addon input-sm">Object</span>
                                <input id="object" name="object" type="text" class="form-control ui-widget" placeholder="Object"/>
                            </p>
                            <button type="submit" class="btn btn-primary">Add triple</button>
                        </form>
                    </div>
            </div><!-- Panel -->
        </div>
    </div>
    </div> <!-- /container -->
    
    <!-- Delete Modal -->
    <div class="modal fade" id="delete-modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">Delete Triple</h4>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this triple?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-danger">Delete</button>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    </body>
</html>
