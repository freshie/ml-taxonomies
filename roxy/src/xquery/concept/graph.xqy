xquery version "1.0-ml";

import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

import module namespace concept = "org.lds.gte.concept.functions" at "/concept/modules/functions.xqy";


declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $subject := xdmp:get-request-field( "s", "" );
declare variable $show := xdmp:get-request-field( "show", "all" );

declare function local:get-digraph(
    $concepts as element(concepts)
) as xs:string {
    let $main-label := xs:string($concepts/@mainLabel)
    let $main-rels :=  xs:string($concepts/@mainRels)
    let $subject-id := xs:int($concepts/@subjectId)
    let $edges :=
        fn:string-join((
            '"' || $subject-id || '"[label="' || $main-label || '",radius=' || $main-rels || '];',
            for $concept at $ctr in $concepts/concept
            let $predicate := $concept/sem:predicate/xs:string(.)
            let $object := $concept/sem:object/xs:string(.)
            let $label := $concept/label/xs:string(.)
            let $title := $concept/title/xs:string(.)
            let $group := $concept/group/xs:string(.)
            let $rels := $concept/rels/xs:int(.)

            let $color := local:get-color($group)
            let $radius :=
                if ( $show  eq ("instances","properties") )
                then ",radius=10"
                else if ( $rels gt 0 )
                then ",value=" || $rels + 10 
                else ",radius=10"
            return
               '"' || $ctr || '"[label="' || $label || '"' || $radius || $title || $color || '];'
        ), "" )
    let $nodes :=
        fn:string-join(
            for $concept at $ctr in $concepts/concept
            let $predicate := $concept/sem:predicate/xs:string(.)
            let $label :=  $concept/label/xs:string(.)
            let $group := $concept/group/xs:string(.)
            return
               '"' || $subject-id || '" -- "' || $ctr || '"[text="' || $label || '"]'
        , ";" )
    let $digraph :=
        "digraph {" ||
            "graph [height=500px]" ||
            "node [style=dot, fontSize=14]" ||
            "edge [length=130, color=gray, fontColor=black, fontSize=10]" ||
            $nodes ||
            $edges ||
            "}"
        
    return $digraph
};

declare function local:get-color(
    $group as xs:string 
) as xs:string {
    if ($group eq "instances")
    then ",borderColor=DarkGreen, backgroundColor=LightGreen, highlightColor=SpringGreen"
    else if ($group eq "relationships")
    then ",borderColor=RoyalBlue, backgroundColor=LightBlue, highlightColor=DarkTurquoise"
    else ",borderColor=Indigo, backgroundColor=Thistle, highlightColor=Orchid"
};

let $pref-label := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.w3.org/2004/02/skos/core#prefLabel", $core:taxonomy-path)
let $concepts := concept:getConnectedConceptsBySubjectGroup($subject, $show)
let $digraph := local:get-digraph($concepts)

return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
       {display:head($pref-label)/element()}
        <!-- Libraries required by network.js -->
        <script type="text/javascript" src="http://www.google.com/jsapi"></script>
        {(:<script type="text/javascript" src="{$core:cdnURL}google.jsapi.js"></script>:)}
        <script type="text/javascript" src="{$core:cdnURL}js/network/network.js"></script>
    </head>
    <body xmlns="">

        <!-- Fixed navbar -->
        {display:nav("Explore")}
        <div class="container-narrow">
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel">
                        <!-- Default panel contents -->
                        <div class="panel-heading"><h3>{ $pref-label }</h3></div>
                        {concept:nav("graph",$subject)}
                        <div id="network"></div>
                        <br/>
                        <p>
                            <a href="{$core:siteRootURL}concept/graph.xqy?s={ $subject }&amp;show=all" class="btn btn-primary">Show all</a>&nbsp;
                            <a href="{$core:siteRootURL}concept/graph.xqy?s={ $subject }&amp;show=relationships"><img src="{$core:cdnURL}images/blue.png"/> Relationships</a>&nbsp;
                            <a href="{$core:siteRootURL}concept/graph.xqy?s={ $subject }&amp;show=properties"><img src="{$core:cdnURL}images/purple.png"/> Properties</a>&nbsp;
                            <a href="{$core:siteRootURL}concept/graph.xqy?s={ $subject }&amp;show=instances"><img src="{$core:cdnURL}images/green.png"/> Instances</a>
                        </p>
                    </div><!-- Panel -->
                </div>
            </div>
            
            <!-- <pre>{ fn:replace( $digraph, ";", fn:concat( ";", fn:codepoints-to-string( 10 ) ) ) }</pre> -->
        
        </div> <!-- /container -->



    </body>
     {display:bottomIncludes()}
             <script type="text/javascript">
            // create a network view
            var network = new links.Network(document.getElementById('network'));
    
            // parse data in DOT-notation
            var dot = '{ $digraph }';
            var data = links.Network.util.DOTToNetwork(dot);
    
            // Add event listeners
            links.events.addListener(network, 'select', onselect);
            // google.visualization.events.addListener(network, 'select', onselect);
    
            // draw the data
            network.draw(data.nodes, data.edges, data.options);
    
            // resize the network when window resizes
            window.onresize = function () {{
                network.redraw()
            }};
    
        </script>
</html>

(:
    // Add a click handler to refocus nodes on selection
    function onselect() {{
        var sel = network.getSelection();
        var row = sel[0].row;
        var uri = 'concept-graph.xqy?s=' + data.nodes[row].id;
        window.location.href=uri;
    }};
:)