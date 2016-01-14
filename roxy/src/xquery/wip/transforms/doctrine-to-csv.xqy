import module namespace core = "org.lds.gte.core-functions" at "/sem/lib/core-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

for $triples in xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/", "infinity" )//sem:triples
let $prefLabel := fn:normalize-space( $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/string() )
let $inScheme := $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme"]/sem:object/string()
let $scheme := semantics:get-label( $inScheme )
let $entityType := fn:tokenize( $triples/sem:triple[sem:predicate = "http://www.lds.org/core#entityType"][1]/sem:object/string(), "/" )[fn:last()]
let $weight := $triples/sem:triple[sem:predicate = "http://www.lds.org/core#weight"]/sem:object/string()
let $rels :=
    for $t in $triples/sem:triple
    let $label := semantics:get-label( $t/sem:object/fn:string() )
    where
        $t/sem:predicate = "http://www.w3.org/2004/02/skos/core#broader" or
        $t/sem:predicate = "http://www.w3.org/2004/02/skos/core#narrower" or
        $t/sem:predicate = "http://www.w3.org/2004/02/skos/core#related"
    return $label
return
    fn:concat(
        '"', $prefLabel, '","',
        fn:string-join( $rels, "; " ),
        '","',
        $weight, '","',
        $entityType, '","',
        $scheme, '"'
    )
