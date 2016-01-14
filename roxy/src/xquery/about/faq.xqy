xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
   {display:head("Frequently Asked Questions")}

    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("About")}

        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading"><h3>Frequently Asked Questions</h3></div>
                        <p></p>
                    
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                <div><em>What is it?</em></div>
                                <div>The Gospel Topics Explorer is a concordance of various LDS-related study helps, including the Bible Dictionary, Topical Guide, Guide to the Scriptures, Teaching by Topic and many others.</div>
                            </li>
                            <li class="list-group-item">
                                <div><em>What is it on?</em></div>
                                <div>The Gospel Topics Explorer is run on <a href="http://marklogic.com" target="_blank">Marklogic</a> with commodity hardware (2 processers and 2 GBs of Ram).</div>
                            </li>
                            <li class="list-group-item">
                                <div><em>What is it developed in?</em></div>
                                <div>The Gospel Topics Explorer is made up of triples using the <a href="http://www.w3.org/2004/02/skos/" target="_blank">skos</a> model. It uses the triple index to query the semantics layer introduced in <a href="http://marklogic.com" target="_blank">Marklogic</a> 7. A full list of features and a brief description of how they work can be viewed on the <a href="{$core:siteRootURL}about/features.xqy">Features</a> Page.</div>
                            </li>
                        </ul>
                </div><!-- Panel -->
            </div>
        </div>
        
    </div> <!-- /container -->
    
    </body>
     {display:bottomIncludes()}
</html>