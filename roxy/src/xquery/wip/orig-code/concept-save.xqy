import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";

let $subject := xdmp:get-request-field( "subject", "" )
let $scheme := xdmp:get-request-field( "scheme", "" )

let $subject-iri := semf:format-as-uri( $subject )
let $scheme-iri :=
    if ( $scheme = "cpg" )
        then "curriculum-planning-guide"
        else
    if ( $scheme = "gs" )
        then "guide-to-the-scriptures"
        else "independent"
let $path :=
    if ( $scheme = "cpg" )
        then fn:concat( "http://lds.org/sem/core/cpg/", $subject-iri, ".xml" )
        else
    if ( $scheme = "gs" )
        then fn:concat( "http://lds.org/sem/core/gs/", $subject-iri, ".xml" )
        else fn:concat( "http://lds.org/sem/core/ind/", $subject-iri, ".xml" )
let $subject-iri-full := fn:concat( "http://lds.org/concept/", $scheme, "/", $subject-iri )
let $scheme-iri-full := fn:concat( "http://lds.org/concept-scheme/", $scheme-iri )
let $triples :=
    <sem:triples>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
            <sem:object>http://www.w3.org/2004/02/skos/core#Concept</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
            <sem:object>{ $scheme-iri-full }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
            <sem:object>{ $subject }</sem:object>
        </sem:triple>
    </sem:triples>
let $exists := xdmp:directory( $core, "infinity" )//sem:triple[
    sem:subject = $subject-iri-full and
    sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme" and
    sem:object = $scheme-iri-full]
let $response := fn:concat( "&amp;", "subject=", $subject, "&amp;", "scheme=", $scheme )
return
    if ( $exists )
        then xdmp:redirect-response( fn:concat( "concept-add.xqy?error=dup", $response ) )
        else (xdmp:document-insert( $path, $triples ),xdmp:redirect-response( fn:concat( "concept.xqy?s=", $subject-iri-full ) ))
