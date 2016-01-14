import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

let $matches :=
    for $concept at $ctr in xdmp:directory( "http://lds.org/sem/core/", "infinity" )//sem:triple[
        sem:predicate eq "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
        sem:object eq "http://www.w3.org/2004/02/skos/core#Concept"]
    let $key := fn:tokenize( $concept/sem:subject/text(), "/" )[fn:last()]
    let $match := fn:doc( "http://lds.org/sem/subjects/raw.xml" )//subject[@key eq $key]
    return
        if ( $match )
            then $concept/sem:subject/text()
            else ()
return fn:count( $matches )