xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";


let $subject := xdmp:get-request-field( "s", "" )
let $predicate := xdmp:get-request-field( "p", "" )
let $object := xdmp:get-request-field( "o", "" )
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
                            <button type="submit" class="btn btn-danger">Delete</button>
                            <button type="submit" class="btn btn-default">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
        
    </div> <!-- /container -->

    </body>
</html>

(:
                        <form method="post" action="concept-delete.xqy">
                            <input type="hidden" name="subject" value="{ $subject }"/>
                            <input type="hidden" name="subject" value="{ $predicate }"/>
                            <input type="hidden" name="subject" value="{ $object }"/>
                        </form>
:)