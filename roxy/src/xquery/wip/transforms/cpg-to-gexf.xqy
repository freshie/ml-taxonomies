declare namespace sem = "http://marklogic.com/semantics";

declare variable $edge-id := 0;

let $nodes :=
    <nodes>
    {
    for $s in xdmp:directory( "http://lds.org/sem/core/cpg/", "infinity" )//sem:triple[sem:object = "http://www.w3.org/2004/02/skos/core#Concept"]/sem:subject/text()
    let $label := fn:doc()//sem:triple[sem:subject = $s and sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/text()
    let $scheme := fn:doc()//sem:triple[sem:subject = $s and sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme"]/sem:object/text()
    let $scheme :=
        if ( $scheme = "http://lds.org/concept-scheme/guide-to-the-scriptures" )
            then "GTTS"
            else "CPG"
    return
        if ( $label ne "" )
            then
                <node id="{ $s }" label="{ $label }">
                    <attvalues>
                        <attvalue for="0" value="{ $scheme }"/>
                    </attvalues>
                </node>
            else ()
    }
    </nodes>
let $edges :=
    <edges>
    {
    for $node in $nodes//node
    let $source := xs:string( $node/@id )
    return
        for $rc in xdmp:directory( "http://lds.org/sem/core/", "infinity" )//sem:triple[
            sem:subject = $source and 
            sem:predicate = "http://www.w3.org/2004/02/skos/core#narrower"]
        let $edge-id := (xdmp:set( $edge-id, $edge-id + 1), $edge-id)
        let $target := xs:string( $rc/sem:object )
        return <edge id="{ $edge-id }" source="{ $source }" target="{ $target }" />
    }
    </edges>
let $file :=
    <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
        <graph mode="static" defaultedgetype="directed">
            <attributes class="node">
                <attribute id="0" title="Scheme" type="string"/>
            </attributes>
            { $nodes }
            { $edges }
        </graph>
    </gexf>
return xdmp:document-insert( "http://lds.org/sem/gexf/cpg.gexf", $file )
