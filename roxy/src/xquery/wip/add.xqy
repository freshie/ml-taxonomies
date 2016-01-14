xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $core := "http://lds.org/sem/core/";
declare variable $error := xdmp:get-request-field( "error", "" );
declare variable $subject := xdmp:get-request-field( "subject", "" );
declare variable $scheme := xdmp:get-request-field( "scheme", "" );

let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $schemes := semantics:get-schemes-list()
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
                <a class="navbar-brand" href="default.xqy">LDS Taxonomies</a>
                <div class="nav-collapse collapse">
                { core:menu-main( "Home", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Create subject</div>
                    <p></p>

                    <form method="post" action="concept-save.xqy">
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                { if ( $error = "" ) then () else <p class="text-danger">The subject "{ $subject }" already exists in the selected scheme.</p> }
                                <div class="input-group">
                                    <span class="input-group-addon">Subject</span>
                                    <input name="subject" value="{ $subject }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Scheme</span>
                                    <select name="scheme" class="form-control">
                                    {
                                    for $s in $schemes//scheme
                                    return
                                        if ( xs:string( $s/@value ) = $scheme )
                                            then <option value="{ xs:string( $s/@prefix ) }" selected="selected">{ $s/text() }</option>
                                            else <option value="{ xs:string( $s/@prefix ) }">{ $s/text() }</option>
                                    }
                                    </select>
                                </div>
                            </li>
                        </ul>
                        <button type="submit" class="btn btn-default">Create</button>
                    </form>
                </div><!-- Panel -->
            </div>
        </div>
    </div> <!-- /container -->

    </body>
</html>
