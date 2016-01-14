xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $user := xdmp:get-session-field( "user", "public" );
declare variable $role := core:get-user-roles( $user );
declare variable $taxonomy := xdmp:get-session-field( "taxonomy", "graph" );
declare variable $taxonomy-title := xdmp:get-session-field( "taxonomy-title", "LDS Knowledge Graph" );
declare variable $taxonomy-path := xdmp:get-session-field( "taxonomy-path", "http://lds.org/sem/taxonomies/" );
declare variable $base := "http://lds.org/sem/";


let $error := xdmp:get-request-field( "error", "" )
let $scheme := xdmp:get-request-field( "scheme", "" )
let $prefix := xdmp:get-request-field( "prefix", "" )
let $note := xdmp:get-request-field( "note", "" )
let $scheme-error := if ( $error = "3" or $error = "1" ) then " has-error" else ""
let $prefix-error := if ( $error = "3" or $error = "2" ) then " has-error" else ""
let $scheme-subjects := xdmp:directory( $taxonomy-path, "infinity" )//sem:triple[
    sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
    sem:object = "http://www.w3.org/2004/02/skos/core#ConceptScheme"]/sem:subject/text()
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>

        <title>LDS Taxonomies</title>

        <!-- Latest compiled and minified CSS -->
        <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        
        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/jumbotron-narrow.css" rel="stylesheet"/>
    
        <!-- GlyphIcons -->
        <link href="/bootstrap/css/bootstrap-glyphicons.css" rel="stylesheet"/>
    
        <!-- Latest compiled and minified JavaScript -->
        <script src="http://code.jquery.com/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="/bootstrap/js/bootstrap.min.js"></script>

        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/navbar-fixed-top.css" rel="stylesheet"/>
        
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
                <a class="navbar-brand" href="default.xqy">{ $taxonomy-title }</a>
                <div class="nav-collapse collapse">
                { core:menu-main( "Admin", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Create concept scheme</div>
                    <p></p>

                    <form method="post" action="scheme-save.xqy">
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                { if ( $error = "" ) then () else <p class="text-danger">The concept scheme "{ $scheme }" already exists.</p> }
                                <div class="input-group{ $scheme-error }">
                                    <span class="input-group-addon">Scheme</span>
                                    <input name="scheme" value="{ $scheme }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group{ $prefix-error }">
                                    <span class="input-group-addon">Prefix</span>
                                    <input name="prefix" value="{ $prefix }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Notes</span>
                                    <textarea name="note" rows="4" class="form-control">{ $note }</textarea>
                                </div>
                            </li>
                        </ul>
                        <button type="submit" class="btn btn-default">Create</button>
                    </form>
                </div><!-- Panel -->
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Existing concept schemes</div>
                    <p>Concept schemes allow grouping of distinct categories of concepts.</p>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Prefix</th>
                                <th>IRI</th>
                            </tr>
                        </thead>
                        <tbody>
                        {
                        for $subject in $scheme-subjects
                        let $label := semantics:get-label( $subject )
                        let $prefix := xdmp:directory( $taxonomy-path, "infinity" )//sem:triple[
                            sem:subject = $subject and
                            sem:predicate = "http://www.lds.org/core#prefix"]/sem:object/text()
                        order by $label
                        return
                            <tr>
                                <td>{ $label }</td>
                                <td>{ $prefix }</td>
                                <td>{ $subject }</td>
                            </tr>
                        }
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
    </div> <!-- /container -->

    </body>
</html>
