import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

let $error := xdmp:get-request-field( "error", "" )
let $logout := xdmp:get-request-field( "logout", "" )
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head("Home")}
    
    <body xmlns="">

        {display:nav("sign-in")} 

        <div class="container">

            <div class="col-lg-4 col-offset-4">
                <form action="{$core:siteRootURL}user/sign-in-validate.xqy" method="post">
                  <fieldset>
                    <legend>Sign in</legend>
                    {
                        if ( $error = "login-expired" ) then (
                            <div class="alert alert-danger">Login expired. Please login again.</div>
                        ) else if ( $error ) then (
                            <div class="alert alert-danger">Login was unsuccessful. Please try again.</div>
                        ) else ()
                    }
                    {
                        if ( $logout = "true" ) then (
                            <div class="alert alert-success">You have successfully logged out.</div>
                        ) else ()
                    }
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
    {display:bottomIncludes()}
</html>
