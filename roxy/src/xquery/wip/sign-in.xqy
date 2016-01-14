import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

let $user := xdmp:get-session-field( "user", "public" )
let $role := "public"

let $error := xdmp:get-request-field( "error", "" )
let $logout := xdmp:get-request-field( "logout", "false" )
let $foo := if ( $logout = "true" ) then xdmp:set-session-field( "user", "public" ) else ()
let $user := if ( $logout = "true" ) then "public" else $user
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>

        <title>Doctrinal Taxonomy Core</title>

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

    <body>

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
                { core:menu-main( "Sign in", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

        <div class="container">
            
            <div class="col-lg-4 col-offset-4">
                <form action="sign-in-validate.xqy" method="post">
                  <fieldset>
                    <legend>Sign in</legend>
                    {
                    if ( $error = "login-expired" )
                        then <div class="alert alert-danger">Login expired. Please login again.</div>
                        else
                    if ( $error )
                        then <div class="alert alert-danger">Login was unsuccessful. Please try again.</div>
                        else () }
                    <div class="form-group">
                      <label for="username">User name</label>
                      <input name="username" type="text" class="form-control" id="username" placeholder="User name"/>
                    </div>
                    <div class="form-group">
                      <label for="password">Password</label>
                      <input name="password" type="password" class="form-control" id="password" placeholder="Password"/>
                    </div>
                    <button type="submit" class="btn btn-default">Submit</button>
                  </fieldset>
                </form>
            </div>
            
        </div> <!-- /container -->

    </body>
</html>
