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


let $errors := fn:tokenize( xdmp:get-request-field( "errors", "" ), "," )
let $title := xdmp:get-request-field( "title", "" )
let $key := xdmp:get-request-field( "key", "" )
let $description := xdmp:get-request-field( "description", "" )
let $title-error := if ( $errors[1] = "true" or $errors[2] = "true" ) then " has-error" else ""
let $key-error := if ( $errors[3] = "true" ) then " has-error" else ""
let $description-error := if ( $errors[4] = "true" ) then " has-error" else ""
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
                { core:menu-main( "Add", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Create a taxonomy</div>
                    <p></p>

                    <form method="post" action="taxonomy-save.xqy">
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                { if ( $errors[1] = "true" ) then <p class="text-danger">A taxonomy with key "{ $title }" already exists.</p> else () }
                                <div class="input-group{ $title-error }">
                                    <span class="input-group-addon">Title</span>
                                    <input name="title" value="{ $title }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group{ $key-error }">
                                    <span class="input-group-addon">Key</span>
                                    <input name="key" value="{ $key }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group{ $description-error }">
                                    <span class="input-group-addon">Description</span>
                                    <textarea name="description" rows="4" class="form-control">{ $description }</textarea>
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
                    <div class="panel-heading">Existing taxonomies</div>
                    <p>A taxonomy is a distinct grouping of terms. A taxonomy includes at least one concept scheme.</p>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th width="30%">Title</th>
                                <th width="20%">Key</th>
                                <th width="50%">Description</th>
                            </tr>
                        </thead>
                        <tbody>
                        {
                        for $taxonomy in xdmp:directory( "/published/gospel-topical-explorer/", "infinity" )//taxonomy
                        let $title := $taxonomy/title/text()
                        let $key := xs:string( $taxonomy/@key )
                        let $description := $taxonomy/description/text()
                        let $owner := $taxonomy/owner/text()
                        order by $title
                        return
                            <tr>
                                <td>
                                    <div>{ $title }</div>
                                    <div><em>Owned by { $owner }</em></div>
                                </td>
                                <td>{ $key }</td>
                                <td>{ $description }</td>
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
