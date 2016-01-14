import module namespace core = "org.lds.gte.core-functions" at "/sem/lib/core-functions.xqy";
import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";
declare namespace r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
declare namespace fh = "http://www.lds.org/fh/orgs";
declare default element namespace "http://schemas.openxmlformats.org/spreadsheetml/2006/main";

declare variable $filename := "http://lds.org/sem/content/ch-occupation-authorities.xlsx";
declare variable $doc := xdmp:zip-get( doc( $filename ), "xl/worksheets/sheet1.xml", <options xmlns="xdmp:zip-get"><format>xml</format></options> );
declare variable $ss := xdmp:zip-get( doc( $filename ), "xl/sharedStrings.xml", <options xmlns="xdmp:zip-get"><format>xml</format></options> );


declare function local:passthru( $x as node() ) as node()* {
    for $z in $x/node() return local:dispatch( $z )
};

declare function local:dispatch( $node as node() ) as node()* {
    typeswitch ( $node )
        case text() return $node
        case element( sheetData ) return <fh:data>{ local:passthru( $node ) }</fh:data>
        case element( row ) return <fh:row r="{ data( $node/@r ) }">{ local:passthru( $node ) }</fh:row>
        case element( c ) return local:cell( $node )
        default return element { local-name( $node ) } { ( $node/@*, local:passthru( $node) ) }
};

declare function local:cell( $node ) {
    let $ret :=
        if ( $node/@t = "s" )
            then $ss//si[xs:integer( $node/v/text() ) +1]/t/text()
            else data( $node/v )
    return <fh:col cell="{ data( $node/@r ) }">{ $ret }</fh:col>
};


let $data := local:dispatch( $doc//sheetData )

for $row in $data//fh:row
let $A := concat( "A", data( $row/@r ) )
let $B := concat( "B", data( $row/@r ) )
let $C := concat( "C", data( $row/@r ) )
let $D := concat( "D", data( $row/@r ) )
let $E := concat( "E", data( $row/@r ) )
let $F := concat( "F", data( $row/@r ) )
let $G := concat( "G", data( $row/@r ) )
let $prefLabel := fn:normalize-space( $row/fh:col[@cell = $A]/text() )
let $altLabels := $row/fh:col[@cell = $B]/text()
let $related := $row/fh:col[@cell = $C]/text()
let $rel-count := fn:count( fn:tokenize( $related, "\n" ) )
let $editorialNote := $row/fh:col[@cell = $D]/text()
let $historyNote := $row/fh:col[@cell = $E]/text()
let $subject := fn:concat( "http://www.lds.org/history/", semf:format-as-uri( $prefLabel ) )
let $new-triples :=
    <sem:triples>
    {
    semantics:build-triple(
        $subject, 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "http://www.w3.org/2004/02/skos/core#Concept",
        "sem:iri",
        "eng" )
    }
    {
    semantics:build-triple(
        $subject, 
        "http://www.w3.org/2004/02/skos/core#inScheme",
        "http://www.lds.org/concept-scheme/church-history-callings",
        "sem:iri",
        "eng" )
    }
    {
    semantics:build-triple(
        $subject, 
        "http://www.w3.org/2004/02/skos/core#prefLabel",
        $prefLabel,
        "xsd:string",
        "eng" )
    }
    {
    for $altLabel in fn:tokenize( $altLabels, "\n" )
    let $clean-label :=
        if ( fn:contains( $altLabel, "--" ) ) then fn:substring-before( $altLabel, "--" ) else $altLabel
    return
        semantics:build-triple(
            $subject, 
            "http://www.w3.org/2004/02/skos/core#altLabel",
            $clean-label,
            "xsd:string",
            "eng" )
    }
    {
    for $rel in fn:tokenize( $related, "\n" )
    let $rel-iri := fn:concat( "http://www.lds.org/history/", semf:format-as-uri( $rel ) ) 
    return
        semantics:build-triple(
            $subject, 
            "http://www.w3.org/2004/02/skos/core#related",
            $rel-iri,
            "sem:iri",
            "eng" )
    }
    {
    semantics:build-triple(
        $subject, 
        "http://www.w3.org/2004/02/skos/core#editorialNote",
        $editorialNote,
        "xsd:string",
        "eng" )
    }
    {
    semantics:build-triple(
        $subject, 
        "http://www.w3.org/2004/02/skos/core#historyNote",
        $historyNote,
        "xsd:string",
        "eng" )
    }
    {
    semantics:build-triple(
        $subject, 
        "http://www.lds.org/core#relCount",
        $rel-count,
        "xsd:integer",
        "eng" )
    }
    </sem:triples>
let $path := fn:concat( "http://lds.org/sem/core/history/", fn:tokenize( $subject, "/" )[fn:last()], ".xml" )
return xdmp:document-insert( $path, $new-triples )

