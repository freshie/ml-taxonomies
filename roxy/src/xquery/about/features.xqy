xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head("Features")}

    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("About")}

        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading"><h3>Features</h3></div>
                        <p></p>
                    
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}search/">Searching Triples</a></em></div>
                                <div>Uses <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code> and a <code><a href="http://docs.marklogic.com/cts:word-query" target="_blank">cts:word-query</a></code> to search the triple index</div>
                                <div>Coverts the triples to xml by putting the results from <code><a href="http://docs.marklogic.com/cts:triples" target="_blank" >cts:triples</a></code> into an xml element and uses <code><a href="http://docs.marklogic.com/cts:highlight" target="_blank" >cts:highlight</a></code> on that element to highlight the results with the search term</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}concept/outbound.xqy?s=http://www.lds.org/concept/gs/peace">Forward Chaining</a></em></div>
                                <div>Does forward chaining with <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code> to get all the outbound triples from the subject sent in the url parameter</div>
                                <div>Each concepts then pulls back other triples, using <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code>, that describe its self</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}concept/inbound.xqy?s=http://www.lds.org/concept/gs/peace">Backwards Chaining</a></em></div>
                                <div>Does backwards chaining with <code><a href="http://docs.marklogic.com/cts:triples" target="_blank" >cts:triples</a></code> to get all the inbound triples from the subject sent in the url parameter</div>
                                <div>Each concepts then pulls back other triples, using <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code>, that describe its self</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}concept/graph.xqy?s=http://www.lds.org/concept/gs/peace">Network Graph</a></em></div>
                                <div>Shows the connecting triples of the subject sent in the url parameter in a network graph using <code><a href="http://almende.github.io/chap-links-library/network.html" target="_blank">network.js</a></code></div>
                                <div>It uses <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code> to query the connecting triples and what type of connections it is</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}concept/?letter=a">List of Concepts</a></em></div>
                                <div>Uses <code><a href="http://docs.marklogic.com/sem:sparql" target="_blank">sem:sparql</a></code> to gets all the Triples that are concepts and display them after uses a <code>Filter</code> step to only get concepts with that letter sent from the url parameter</div>
                                <div>Each concepts then pulls back other triples, using <code><a href="http://docs.marklogic.com/cts:triples" target="_blank">cts:triples</a></code>, that describe its self</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}concept/?letter=a">Visual Graph of The Ontology</a></em></div>
                                <div>Uses <code><a href="http://gexf.net/" target="_blank" >gexf</a></code> to display the concepts and their connections</div>
                                <div>Each concept is given a weight based on the amount of other concepts its connected to</div>
                                <div>The Weight is displayed in the size and the color of the point on the graph</div>
                                <div>Because the Ontology isn't changing very often the <code><a href="http://gexf.net/" target="_blank" >gexf</a></code> files are built with a transform that is manually kicked off</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}search/images.xqy?keywords=love&amp;degree=0">Searching XML content that has Triples</a></em></div>
                                <div>Searches a small data set of that has marked up triples in each document.</div>
                                <div>Is an example of the power of having your triples and your content together</div>
                            </li>
                            <li class="list-group-item">
                                <div><em><a href="{$core:siteRootURL}relate/">Concept Relating</a></em></div>
                                <div>Uses an enhanced <code><a href="http://docs.marklogic.com/sem:transitive-closure" target="_blank">cts:transitive-closure</a></code> that keeps the path of the clouser.</div>
                                <div>This is used on the both concept and then the looks the concepts as the key in the map to show the paths.</div>
                                <div>An example of that code can be found here: <code><a href="http://github.com/freshie/ml-semantics/blob/master/transitive-closure-with-paths.xqy" target="_blank">http://github.com/freshie/ml-semantics/blob/master/transitive-closure-with-paths.xqy</a></code></div>
                                <div>The Map is then used in a few places. such as to display all the paths and then another to make the needed data for the visualization</div>
                                <div>Uses the <code><a href="http://d3js.org/" target="_blank">Data-Driven Documents</a></code> javascript library for the visualization</div>
                            </li>
                        </ul>
                </div><!-- Panel -->
            </div>
        </div>
        
    </div> <!-- /container -->
    
    </body>
     {display:bottomIncludes()}
</html>