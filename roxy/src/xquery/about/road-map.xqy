xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head("Road Map")}

    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("About")}

        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading"><h3>Road Map</h3></div>
                        <p></p>
                    
                        <!-- List group -->
                        <ul class="list-group">
                           
                            <li class="list-group-item">
                                <div><strong>Move business logic into the queries</strong></div>
                                <div>There are many pages that have business logic that could be more performant if the logic was moved into the Query.</div>
                                <div><span class="label label-success"> ✓</span> finished splitting out the business logic and unit test for Concept pages</div>
                                <div><span class="label label-success"> ✓</span> started on splitting out the business logic and unit test for Search pages</div>
                            </li>
                            <li class="list-group-item">
                                <div><strong>Unify on visualization library</strong></div>
                                <div> update the network page use D3</div>
                                <div> update the network visualize use D3</div>
                                <div><span class="label label-success"> ✓</span> Pick visualization library (d3)</div>
                                <div><span class="label label-success"> ✓</span> Add to project</div>
                                <div><span class="label label-success"> ✓</span> Use on a page.</div>

                            </li>
                            <li class="list-group-item">
                                <div><strong>Fix logged in functionality</strong></div>
                                <div>All non-logged in functionality has been changed in order to work with the new model. Now the functionality behind the login needs to be covered in order to work with new model.</div>
                            </li>
                            <li class="list-group-item">
                                <div><strong>Make schemes work</strong></div>
                                <div>Make a name graph for scheme and the covert all triples into quads where each triple gets added to its graph</div>
                            </li>
                            
                            <li class="list-group-item">
                                <div><strong>Other needed functionality</strong></div>
                                <div>Make code ready for a community or open source project</div>
                                <div>Transform CPG to include broader relationships</div>
                                <div>Delete concept</div>
                                <div>Add language selector to search page</div>
                                <div>Add language selector to top nav bar</div>
                                <div>Add triples to our content</div>
                            </li>
                            <li class="list-group-item">
                                <div><span class="label label-success"> ✓</span> <strong> Add unit tests</strong></div>
                               <div><span class="label label-success"> ✓</span> <strong> Add related functionality</strong></div>
                            </li>
                           
                        </ul>
                </div><!-- Panel -->
            </div>
        </div>
        
    </div> <!-- /container -->
    
    </body>
     {display:bottomIncludes()}
</html>