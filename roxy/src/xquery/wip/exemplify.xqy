xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>
    
        <title>Doctrine T-Core</title>
    
        <!-- Latest compiled and minified CSS -->
        <link href="{$core:cdnURL}bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    
        <!-- Latest compiled and minified JavaScript -->
        <script src="{$core:cdnURL}js/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="{$core:cdnURL}bootstrap/js/bootstrap.min.js"></script>
        
        <link rel="stylesheet" href="{$core:cdnURL}css/jquery-ui.css" />
        <!-- <script src="http://code.jquery.com/jquery-1.9.1.js"></script> -->
        <script src="{$core:cdnURL}js/jquery-ui.js"></script>
  
        <script>
        $(function() {{
            $( "#object" ).autocomplete({{
                source: {$core:siteRootURL} || "concept-find.xqy",
                minLength: 3
            }});
        }});
        </script>
    </head>

    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("LDS Taxonomies","Demos",$user)}

        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading"><h3>Exemplifications</h3></div>
                        <p></p>
                    
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">Women who exemplify courage</li>
                            <li class="list-group-item">Men who exemplify courage</li>
                            <li class="list-group-item">People who exemplify courage</li>
                        </ul>
                </div><!-- Panel -->
            </div>
        </div>
        
    </div> <!-- /container -->
    
    </body>
</html>
