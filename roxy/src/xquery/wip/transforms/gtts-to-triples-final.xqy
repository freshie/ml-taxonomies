import module namespace core = "org.lds.gte.core-functions" at "/sem/lib/core-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare function local:passthru( $x as node() ) as node()* {
    for $z in $x/node() return local:dispatch( $z )
};

declare function local:dispatch( $node as node() ) as node()* {
    typeswitch ( $node )
        case text() return $node
        case element( fact-set ) return
            <sem:triples>
            {
            local:build-triple(
                local:subject( xs:string( $node/@uri ) ),
                "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
                "http://www.w3.org/2004/02/skos/core#Concept",
                "sem:iri" )
            }
            { local:passthru( $node ) }
            </sem:triples>
        case element( t ) return local:triple( $node )
        default return element { fn:local-name( $node ) } { ( $node/@*, local:passthru( $node ) ) }
};

declare function local:triple( $node ) {
    let $s := $node/s/text()
    let $p := $node/p/text()
    let $o := $node/o/text()
    let $c := $node/c/text()
    let $new-s := local:subject( $s )
    let $new-p := local:predicate( $p )
    let $new-o := local:object( $o )
    let $datatype := semantics:get-data-type( $new-p, fn:true() )
    return
        if ( $p = "http://lds.org/thing#instance-of" and fn:contains( $c, "Guide to the Scriptures" ) )
            then local:handle-instances( $node )
            else
        if ( $p = "http://lds.org/thing#scope" and $o = "Guide to the Scriptures" )
            then local:build-triple( $new-s, $new-p, $new-o, $datatype )
            else
        if ( $p = "http://lds.org/thing#scope" and $o ne "Guide to the Scriptures" )
            then ()
            else
        if ( $p = "http://lds.org/thing#instance-of" and (fn:contains( $o, "/general-conference/" ) or fn:contains( $o, "/broadcasts/" )) )
            then ()
            else
        if ( $new-o )
            then local:build-triple( $new-s, $new-p, $new-o, $datatype )
            else ()
};

declare function local:handle-instances( $node ) {
    let $s := $node/s/text()
    let $p := $node/p/text()
    let $o := $node/o/text()
    let $c := $node/c/text()
    let $d := $node/d/text()
    let $new-s := local:subject( $s )
    let $new-p := local:predicate( $p )
    let $new-o := local:object( $o )
    let $datatype := semantics:get-data-type( $new-p, fn:true() )
    let $new-triple := local:build-triple( $new-s, $new-p, $new-o, $datatype )
    let $definition-triple :=
        if ( $p = "http://lds.org/thing#instance-of" and fn:contains( $c, "Guide to the Scriptures" ) and $d )
            then local:build-triple( $new-s, "http://www.w3.org/2004/02/skos/core#definition", $d, "xsd:string" )
            else ()
    return ($new-triple,$definition-triple)
};

declare function local:subject( $subject ) {
    let $subject := fn:tokenize( $subject, "/" )[fn:last()]
    let $new-subject := fn:concat( "http://www.lds.org/concept/gs/", $subject )
    return $new-subject
};

declare function local:predicate( $predicate ) {
    let $new-predicate := fn:doc( "http://lds.org/sem/predicate-mapping.xml" )//predicate[old = $predicate]/new/text()
    return $new-predicate
};

declare function local:object( $object ) {
    let $in-gs :=
        if ( fn:starts-with( $object, "/" ) )
            then fn:exists( xdmp:directory( "http://lds.org/semantic/ootr/topic/" )//t[
                s = $object and
                p = "http://lds.org/thing#scope" and
                o = "Guide to the Scriptures"] )
            else fn:false()
    let $iri := 
        if ( $in-gs )
            then fn:concat( "http://www.lds.org/concept/gs/", fn:tokenize( $object, "/" )[fn:last()] )
            else ()
    let $entity-type := local:set-entity-type( $object )
    let $new-object :=
        if ( $object = "Guide to the Scriptures" )
            then "http://www.lds.org/concept-scheme/guide-to-the-scriptures"
            else
        if ( $entity-type )
            then $entity-type
            else
        if ( fn:starts-with( $object, "/" ) and $in-gs )
            then $iri
            else
        if ( fn:starts-with( $object, "/" ) and fn:empty( $iri ) )
            then ()
            else $object
    return $new-object
};

declare function local:build-triple( $s, $p, $o, $datatype ) {
    <sem:triple>
        <sem:subject>{ $s }</sem:subject>
        <sem:predicate>{ $p }</sem:predicate>
        {
        if ( $datatype = "xsd:string" )
            then <sem:object xml:lang="eng" datatype="{ $datatype }">{ $o }</sem:object>
            else <sem:object datatype="{ $datatype }">{ $o }</sem:object>
        }
    </sem:triple>
};

declare function local:set-entity-type( $str ) {
    if ( $str eq "asset" )
        then "http://www.lds.org/Asset"
        else
    if ( $str eq "role" )
        then "http://www.lds.org/Role"
        else
    if ( $str eq "organization" )
        then "http://www.schema.org/Organization"
        else
    if ( $str eq "group" )
        then "http://www.lds.org/Group"
        else
    if ( $str eq "person" )
        then "http://www.schema.org/Person"
        else
    if ( $str eq "event" )
        then "http://www.schema.org/Event"
        else
    if ( $str eq "topic" )
        then "http://www.lds.org/Topic"
        else
    if ( $str eq "location" or $str eq "place" )
        then "http://www.lds.org/Place"
        else ()
};


for $fact-set in xdmp:directory( "http://lds.org/semantic/ootr/topic/" )//fact-set[
    t/p = "http://lds.org/thing#scope" and 
    t/o = "Guide to the Scriptures"]
let $triples := local:dispatch( $fact-set )
let $rel-count := fn:count( $triples//sem:triple[fn:index-of( $core:SEM-RELS, sem:predicate/text() ) > 0] )
let $subject := ($triples//sem:subject)[1]/text()
let $new-triples :=
    <sem:triples>
    { $triples//sem:triple }
        <sem:triple>
            <sem:subject>{ $subject }</sem:subject>
            <sem:predicate>http://www.lds.org/core#relCount</sem:predicate>
            <sem:object datatype="xsd:integer">{ $rel-count }</sem:object>
        </sem:triple>
    </sem:triples>
let $label := fn:tokenize( xs:string( $fact-set/@uri ), "/" )[fn:last()]
let $path := fn:concat( "http://lds.org/sem/core/gs/", $label, ".xml" )
return xdmp:document-insert( $path, $new-triples )
