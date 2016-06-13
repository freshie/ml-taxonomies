import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head("Home")}

    <body xmlns="">

        {display:nav("Home")} 

        <div class="container">

        <!-- Main component for a primary marketing message or call to action -->
            <div class="jumbotron">
                <h1>{$core:applicationConfig/title/text()}</h1>
                <p class="lead">{$core:applicationConfig/description/text()}</p>
                <p><a class="btn btn-lg btn-success" href="{$core:siteRootURL}about/faq.xqy">Frequently Asked Questions</a></p>
            </div>
           
            {
                for $taxonomy in core:getTaxonomys()
                let $key := xs:string($taxonomy/@key)
                order by xs:string($taxonomy/title)
                return
                    <div class="col-lg-4">
                        <h2>{ $taxonomy/title/xs:string(.) }</h2>
                        
                        <p>{ $taxonomy/description/xs:string(.) }</p>
                        <div class="btn-group">
                            {
                             if ($user:privileges eq "editor") then (
                                <a class="btn btn-info" href="{$core:siteRootURL}taxonomy/update.xqy?previousKey={ $key }" style=" margin-right: .5em;">Edit</a>
                             ) else ()
                            }    

                            <a class="btn btn-primary" href="{$core:siteRootURL}taxonomy/set.xqy?key={ $key }" style=" margin-right: .5em;">Search &raquo;</a>
                           
                        </div>
                    </div>
            }
            
        </div> <!-- /container -->

    </body>
    {display:bottomIncludes()}
</html>
