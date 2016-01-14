xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $core := "http://lds.org/sem/core/";
declare variable $error := xdmp:get-request-field( "error", "" );
declare variable $subject := xdmp:get-request-field( "s", "" );
declare variable $predicate := xdmp:get-request-field( "p", "" );
declare variable $object := xdmp:get-request-field( "o", "" );


let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $datatype := semantics:get-data-type( $predicate, fn:true() )
let $has-error := if ( $error ) then " has-error" else ""
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
                { core:menu-main( "Explore", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Edit triple</div>
                    <p></p>

                    <form method="post" action="concept-edit-save.xqy">
                        <input name="subject-hidden" type="hidden" value="{ $subject }"/>
                        <input name="predicate-hidden" type="hidden" value="{ $predicate }"/>
                        <input name="object-hidden" type="hidden" value="{ $object }"/>
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Subject</span>
                                    <input name="subject" value="{ $subject }" type="text" class="form-control" disabled="disabled"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Predicate</span>
                                    <input name="predicate" value="{ $predicate }" type="text" class="form-control" disabled="disabled"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                { if ( $error = "" ) then () else <p class="text-danger">An object cannot be blank.</p> }
                                <div class="input-group{ $has-error }">
                                    <span class="input-group-addon">Object</span>
                                    {
                                    if ( $datatype = "xsd:string" )
                                        then
                                            <textarea name="object" class="form-control" rows="10">{ $object }</textarea>
                                        else 
                                            <input id="object" name="object" value="{ $object }" type="text" class="form-control ui-widget"/>
                                    }
                                </div>
                            </li>
                        </ul>
                        <button type="submit" class="btn btn-primary">Save</button>&nbsp;
                        <a href="concept.xqy?s={ $subject }" type="submit" class="btn btn-default">Cancel</a>
                    </form>
                </div><!-- Panel -->
            </div>
        </div>
    </div> <!-- /container -->

    </body>
</html>
