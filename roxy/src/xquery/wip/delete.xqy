xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $base := "http://lds.org/sem/";
declare variable $core := "http://lds.org/sem/core/";

declare function local:update-rel-count( $subject, $predicate ) {
    (:
    1. Not a relationship predicate, so do nothing.
    2. Relationship predicate exists, so decrement it (node-replace)
    :)
    let $old-rel-triple :=
        xdmp:directory( $base, "infinity" )//sem:triple[
            sem:subject = $subject and
            sem:predicate = "http://www.lds.org/core#relCount"]
    let $action :=
        if ( $predicate = $core:SEM-RELS )
            then "decrement"
            else ()
    let $rel-count :=
        if ( $action = "decrement" )
            then xs:integer( $old-rel-triple/sem:object/text() ) - 1
            else 0
    let $new-rel-triple :=
        <sem:triple>
            <sem:subject>{ $subject }</sem:subject>
            <sem:predicate>http://www.lds.org/core#relCount</sem:predicate>
            <sem:object datatype="xsd:integer">{ $rel-count }</sem:object>
        </sem:triple>
    return
        if ( $action = "decrement" )
            then xdmp:node-replace( $old-rel-triple, $new-rel-triple )
            else ()
};


let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $subject := xdmp:get-request-field( "s", "" )
let $predicate := xdmp:get-request-field( "p", "" )
let $object := xdmp:get-request-field( "o", "" )
let $delete := xdmp:get-request-field( "delete", "false" )
let $node :=
    if ( $delete = "true" )
        then xdmp:directory( $core, "infinity" )//sem:triple[
            sem:subject = $subject and
            sem:predicate = $predicate and
            sem:object = $object]
        else ()
let $response :=
    fn:concat(
        "&amp;s=", fn:escape-uri( $subject, fn:true() ),
        "&amp;p=", fn:escape-uri( $predicate, fn:true() ),
        "&amp;o=", fn:escape-uri( $object, fn:true() ) )
return
    if ( $delete = "true" and $node )
        then
            (
            xdmp:node-delete( $node ),
            local:update-rel-count( $subject, $predicate ),
            xdmp:redirect-response( fn:concat( "concept.xqy?s=", $subject ) )
            )
        else

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>
    
        <title>Doctrine T-Core</title>
    
        <!-- Latest compiled and minified CSS -->
        <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        
        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/jumbotron-narrow.css" rel="stylesheet"/>
    
        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/navbar-fixed-top.css" rel="stylesheet"/>

        <!-- Latest compiled and minified JavaScript -->
        <script src="http://code.jquery.com/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="/bootstrap/js/bootstrap.min.js"></script>
        
    </head>

  <body xmlns="">

        <!-- Fixed navbar -->
        <div class="navbar navbar-fixed-top">
            <div class="container">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".nav-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="default.xqy">LDS Taxonomies</a>
                <div class="nav-collapse collapse">
                { core:menu-main( "Home", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        
        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-danger">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Are you sure you want to delete this triple?</div>
        
                    <!-- List group -->
                    <ul class="list-group">
                        <li class="list-group-item">Subject: { $subject }</li>
                        <li class="list-group-item">Predicate: { $predicate }</li>
                        <li class="list-group-item">Object: { $object }</li>
                    </ul>
                    <div class="panel-footer">
                        <a href="concept-delete.xqy?delete=true{ $response }" class="btn btn-danger">Delete</a>&nbsp;
                        <a href="concept.xqy?s={ $subject }" class="btn btn-default">Cancel</a>
                    </div>
                </div>
            </div>
        </div>
        
    </div> <!-- /container -->

    </body>
</html>
