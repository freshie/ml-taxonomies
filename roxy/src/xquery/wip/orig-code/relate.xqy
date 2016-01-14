import module namespace semf = "org.lds.common.semantic-functions" at "/semantic/lib/semantic-functions.xqy";
import module namespace sem = "http://marklogic.com/semantic" at "/semantic/lib/semantic.xqy";

declare namespace gexf = "http://www.gexf.net/1.2draft";
declare namespace viz = "http://www.gexf.net/1.2draft/viz";

declare variable $ootr := "http://lds.org/semantic/ootr/topic/";
declare variable $global-map := map:map();
declare variable $relate := xdmp:get-request-field( "relate", "false" );
declare variable $input := xdmp:get-request-field( "input", "" );
declare variable $topic1 := xdmp:get-request-field( "topic1", "" );
declare variable $topic2 := xdmp:get-request-field( "topic2", "" );
declare variable $id := 0;
declare variable $nodes-examined := 0;

declare option xdmp:output "method = html";

declare function local:get-next-match( $step, $map, $match ) {
    (: Get all triples with a predicate of #related-topic and a subject or object that matches $match (a subject) :)
    let $objects := sem:object-for-subject-predicate( $match, "http://lds.org/term#related-topic" )
    let $subjects := sem:subject-for-object-predicate( $match, "http://lds.org/term#related-topic" )
    (: Examine each of these items to see if there is a match in the original set ot subjects :)
    let $new-match :=
        for $x in ($objects,$subjects)
        return
            if ( map:get( $map, $x ) = $step )
                then $x
                else ()
    (: If there is a match, pop it onto the global-map :)
    let $foo :=
        if ( fn:empty( $new-match ) )
            then ()
            else map:put( $global-map, $new-match, $step )
    return
        (: If there are no more items in the map or nothing to match, terminate. Otherwise, decrement the
           degree to examine and recurse :)
        if ( fn:empty( $map ) or fn:empty( $match ) )
            then ()
            else local:get-next-match( $step + 1, $map, $new-match )
};
declare function local:relate( $source, $target ) {
    let $m := map:map()
    let $m2 := map:map()
    let $gen := 5
    (: This is where the hard stuff is done. Thank you, Michael Blakeley! :)
    let $foo := sem:transitive-closure( $m, $source, $gen, "http://lds.org/term#related-topic", true(), () )
    let $foo := xdmp:set( $nodes-examined, map:count( $m ) )
    (: This tells me the number of degrees from the source term to the target term, based on a value
        returned in the map. Initially, source = 5 and the furthest degree = 0. :)
    let $found-at-step := xs:integer( map:get( $m, $target ) )
    (: If a match was found before all degrees were exhausted, trim off the unnecessary nodes :)
    let $foo :=
        if ( $found-at-step < $gen )
            then
                for $key in map:keys( $m )
                where map:get( $m, $key ) > $found-at-step
                return map:put( $m2, $key, map:get( $m, $key ) )
            else ()
    (: Store the matching node in the $global-map variable, which is where the final nodes are stored :)
    let $foo := map:put( $global-map, $target, $found-at-step )
    (: Recurse through the trimmed map until all matches have been popped on to the global-map :)
    let $foo := local:get-next-match( $found-at-step + 1, $m2, $target )
    let $foo := map:put( $global-map, $source, $gen )
    return local:build-topic-map()
};
declare function local:build-topic-map() {
    <topics>
    {
    for $s in map:keys( $global-map )
    let $label := sem:object-for-subject-predicate( $s, "http://lds.org/thing#label" )
    let $label := if ( fn:not( $label ) ) then $s else $label
    return
        <topic uri="{ $s }" label="{ $label }">
        {
        for $r in sem:object-for-subject-predicate( $s, "http://lds.org/term#related-topic" )
        return
            if ( map:get( $global-map, $r ) )
                then <topic uri="{ $r }"/>
                else ()
        }
        </topic>
    }
    </topics>
};
declare function local:xml-to-json( $topic-map ) {
    let $json :=
        fn:string-join( 
            for $topic in $topic-map/topic
            let $s := xs:string( $topic/@uri )
            let $label := xs:string( $topic/@label )
            let $color := if ( $s = $topic1 or $s = $topic2 ) then "#66FF66" else "#00CCCC"
            let $shape := "circle"
            let $dim := if ( $s = $topic1 or $s = $topic2  ) then 14 else 10
            let $child-terms :=
                fn:concat(
                    '{"adjacencies": [',
                    fn:string-join( 
                        for $t in $topic/topic
                        return
                            fn:concat( '{"nodeTo":"', xs:string( $t/@uri ), '","nodeFrom":"', $s, '","data": {"$color": "#414141"}}' ), "," ),
                            '],"data": {"$color": "', $color, '","$type": "', $shape, '","$dim": ', $dim,'},',
                            '"id": "', $s, '",',
                            '"name": "', $label, '"}'
                )
            return $child-terms
        , "," )
    return fn:concat( "[", $json, "]" )
};
declare function local:select( $name, $options, $selected ) {
    <select name="{ $name }">
    {
    for $t in $options/t
    where xs:integer( $t/@rels ) > 0
    order by xs:integer( $t/@rels ) descending
    return
        if ( $selected = xs:string( $t/s ) )
            then <option value="{ xs:string( $t/s ) }" selected="selected">{ fn:concat( xs:string( $t/o ), " (", xs:string( $t/@rels ), ")" ) }</option>
            else <option value="{ xs:string( $t/s ) }">{ fn:concat( xs:string( $t/o ), " (", xs:string( $t/@rels ), ")" ) }</option>
    }
    </select>
};


let $words := fn:tokenize( $input, "," )
let $grams1 := semf:build-grams( $words[1] )
let $query1 := semf:build-query( $grams1 )
let $results1 := <results>{ cts:search( //t[p = "http://lds.org/thing#label"], $query1 ) }</results>
let $options1 :=
    <options>
    {
    for $t in $results1//t
    let $rels := fn:count( xdmp:directory( $ootr, "infinity" )//t[s = $t/s and p = "http://lds.org/term#related-topic"] )
    return <t rels="{ $rels }">{ $t/node() }</t>
    }
    </options>
let $grams2 := semf:build-grams( $words[2] )
let $query2 := semf:build-query( $grams2 )
let $results2 := <results>{ cts:search( //t[p = "http://lds.org/thing#label"], $query2 ) }</results>
let $options2 :=
    <options>
    {
    for $t in $results2//t
    let $rels := fn:count( xdmp:directory( $ootr, "infinity" )//t[s = $t/s and p = "http://lds.org/term#related-topic"] )
    return <t rels="{ $rels }">{ $t/node() }</t>
    }
    </options>
let $topic-map := if ( $topic1 = "" or $topic2 = "" ) then () else local:relate( $topic1, $topic2 )
let $json := if ( $topic-map ) then local:xml-to-json( $topic-map ) else ()
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8"/>
    <title>The Gospel Topics Explorer</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content=""/>
    <meta name="author" content=""/>
    <link href="css/ootr.css" rel="stylesheet"/>
    <link href="bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <style>
      body {{
        padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
      }}
    </style>
    <link href="bootstrap/css/bootstrap-responsive.css" rel="stylesheet"/>
    <script language="javascript" type="text/javascript" src="js/jit-yc.js"></script>
    <script type="text/javascript">
        var labelType, useGradients, nativeTextSupport, animate;
        
        (function() {{
          var ua = navigator.userAgent,
              iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
              typeOfCanvas = typeof HTMLCanvasElement,
              nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
              textSupport = nativeCanvasSupport &amp;&amp; (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
              
          //I'm setting this based on the fact that ExCanvas provides text support for IE
          //and that as of today iPhone/iPad current text support is lame
          labelType = (!nativeCanvasSupport || (textSupport &amp;&amp; !iStuff))? 'Native' : 'HTML';
          nativeTextSupport = labelType == 'Native';
          useGradients = nativeCanvasSupport;
          animate = !(iStuff || !nativeCanvasSupport);
        }})();
        
        var Log = {{
          elem: false,
          write: function(text){{
            if (!this.elem) 
              this.elem = document.getElementById('log');
            this.elem.innerHTML = text;
            this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
          }}
        }};
        
        function init(){{
          // init data
          var json = { $json };
          // end
          // init ForceDirected
          var fd = new $jit.ForceDirected({{
            //id of the visualization container
            injectInto: 'infovis3',
            //Enable zooming and panning
            //by scrolling and DnD
            Navigation: {{
              enable: true,
              //Enable panning events only if we're dragging the empty
              //canvas (and not a node).
              panning: 'avoid nodes',
              zooming: 100 //zoom speed. higher is more sensible
            }},
            // Change node and edge styles such as
            // color and width.
            // These properties are also set per node
            // with dollar prefixed data-properties in the
            // JSON structure.
            Node: {{
              overridable: true,
              alpha: 1
            }},
            Edge: {{
              overridable: true,
              color: '#23A4FF',
              type: 'line',
              lineWidth: 0.4
            }},
            //Native canvas text styling
            Label: {{
              type: labelType, //Native or HTML
              size: 12,
              color: '#000',
              style: 'bold'
            }},
            //Add Tips
            Tips: {{
              enable: true,
              onShow: function(tip, node) {{
                //count connections
                var count = 0;
                node.eachAdjacency(function() {{ count++; }});
                //display node info in tooltip
                tip.innerHTML = '<div class="tip-title">' + node.name + '</div>'
                  + '<div class="tip-text"><b>connections:</b> ' + count + '</div>';
              }}
            }},
            // Add node events
            Events: {{
              enable: true,
              type: 'Native',
              //Change cursor style when hovering a node
              onMouseEnter: function() {{
                fd.canvas.getElement().style.cursor = 'move';
              }},
              onMouseLeave: function() {{
                fd.canvas.getElement().style.cursor = '';
              }},
              //Update node positions when dragged
              onDragMove: function(node, eventInfo, e) {{
                  var pos = eventInfo.getPos();
                  node.pos.setc(pos.x, pos.y);
                  fd.plot();
              }},
              //Implement the same handler for touchscreens
              onTouchMove: function(node, eventInfo, e) {{
                $jit.util.event.stop(e); //stop default touchmove event
                this.onDragMove(node, eventInfo, e);
              }},
              //Add a click handler to refocus nodes on selection
              onClick: function(node) {{
                if(!node) return;
                window.location.href='view.xqy?s=' + node.id;
              }}
            }},
            //Number of iterations for the FD algorithm
            iterations: 200,
            //Edge length
            levelDistance: 130,
            // Add text to the labels. This method is only triggered
            // on label creation and only for DOM labels (not native canvas ones).
            onCreateLabel: function(domElement, node){{
              domElement.innerHTML = node.name;
              var style = domElement.style;
              style.fontSize = "0.8em";
              style.color = "#000";
            }},
            // Change node styles when DOM labels are placed
            // or moved.
            onPlaceLabel: function(domElement, node){{
              var style = domElement.style;
              var left = parseInt(style.left);
              var top = parseInt(style.top);
              var w = domElement.offsetWidth;
              style.left = (left - w / 2) + 'px';
              style.top = (top + 10) + 'px';
              style.display = '';
            }}
          }});
          // load JSON data.
          fd.loadJSON(json);
          // compute positions incrementally and animate.
          fd.computeIncremental({{
            iter: 40,
            property: 'end',
            onStep: function(perc){{
              Log.write(perc + '% loaded...');
            }},
            onComplete: function(){{
              Log.write('');
              fd.animate({{
                modes: ['linear'],
                transition: $jit.Trans.Elastic.easeOut,
                duration: 2500
              }});
            }}
          }});
          // end
        }}
        </script>
  </head>

  <body onload="init();" xmlns="">
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="#">The Gospel Topics Explorer</a>
          <div class="nav-collapse">
            <ul class="nav">{ semf:main-menu() }</ul>
            <ul class="nav pull-right">
                <li><a href="sign-in.xqy">Sign in</a></li>
            </ul>
            </div><!--/.nav-collapse -->
        </div>
      </div>
    </div><!-- container -->

    <div class="container">
        <div class="row-fluid">
            <div class="span3">
                <form class="form-search" method="get" action="relate.xqy">
                    <input type="hidden" name="relate" value="false"/>
                    <div class="input-prepend well">
                        <button type="submit" class="btn">Search</button>
                        <input type="text" class="span8 search-query" name="input" value="{ $input }" placeholder="Enter two topics"/>
                    </div>
                </form>
                <hr/>
                {
                if ( fn:empty( $input ) or $input = "" )
                    then ()
                    else
                        (<form method="get" action="relate.xqy">
                            <input type="hidden" name="input" value="{ $input }"/>
                            <input type="hidden" name="relate" value="true"/>
                            <div>{ local:select( "topic1", $options1, $topic1 ) }</div>
                            <div>{ local:select( "topic2", $options2, $topic2 ) }</div>
                            <button type="submit" class="btn">Relate topics</button>
                        </form>,
                        <hr/>)
                }
                { if ( $json ) then <div class="alert">{ $nodes-examined } nodes examined</div> else () }
                <div class="alert alert-success">
                    <button type="button" class="close" data-dismiss="alert">Ã—</button>
                    <div><strong>Getting started:</strong> In the Search box above, enter two terms or phrases separated by a comma, then click Search. Select other topics from one or both dropdowns to refine your search.</div>
                    <hr/>
                    <div><strong>Examples</strong></div>
                    <div><a href="relate.xqy?input=atonement,joseph+smith&amp;relate=true&amp;topic1=/topic/jesus-christ-atonement-through&amp;topic2=/topic/prophet-joseph-smith">atonement, joseph smith</a></div>
                    <div><a href="relate.xqy?input=wealth,misery&amp;relate=true&amp;topic1=/topic/wealth&amp;topic2=/topic/misery">wealth, misery</a></div>
                    <div><a href="relate.xqy?input=inspiration,worthiness&amp;relate=true&amp;topic1=/topic/inspiration&amp;topic2=/topic/worthiness">inspiration, worthiness</a></div>
                    <div><a href="relate.xqy?input=sacrament,atonement&amp;relate=true&amp;topic1=/topic/sacrament&amp;topic2=/topic/jesus-christ-atonement-through">sacrament, atonement</a></div>
                    <div><a href="relate.xqy?input=worthiness,mission&amp;relate=true&amp;topic1=/topic/worthiness&amp;topic2=/topic/missions">worthiness, mission</a></div>
                    <div><a href="relate.xqy?input=cleanliness,godliness&amp;relate=true&amp;topic1=/topic/cleanliness&amp;topic2=/topic/godliness">cleanliness, godliness</a></div>
                    <div><a href="relate.xqy?input=tea,coffee&amp;relate=true&amp;topic1=/topic/tea&amp;topic2=/topic/coffee">tea, coffee</a></div>
                </div>
            </div>
            <div class="span9">
                <ul class="thumbnails">
                    <li>
                        <div class="thumbnail">
                            <div id="log"></div>
                            <div id="infovis3"></div>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div> <!-- /container -->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="js/jquery/jquery.js"></script>
    <script src="bootstrap/js/bootstrap.js"></script>
  </body>
</html>