declare namespace sem = "http://marklogic.com/semantics";

('"Preferred Label","Alt Labels","URI","Relationships","Entity Type","Gender"',
    for $triples in xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/gs/", "infinity" )//sem:triples
    let $label := $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/text()
    let $rels :=
        fn:string-join(
            for $rel in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#related"]/sem:object/text()
            let $rel-label := xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/gs/", "infinity" )//sem:triple[sem:subject = $rel and sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/text()
            return $rel-label
        , "; " )
    let $alt-labels :=
        fn:string-join(
            for $alt in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#altLabel"]/sem:object/text()
            let $alt-label := xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/gs/", "infinity" )//sem:triple[sem:subject = $alt and sem:predicate = "http://www.w3.org/2004/02/skos/core#altLabel"]/sem:object/text()
            return $alt-label
        , "; " )
    let $uri := $triples/sem:triple[sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]/sem:subject/text()
    let $entity-type := $triples/sem:triple[sem:predicate = "http://www.lds.org/core#entityType"][1]/sem:object/text()
    let $gender := $triples/sem:triple[sem:predicate = "http://www.lds.org/core#gender"]/sem:object/text()
    order by $label
    return
        fn:concat(
            '"',
            $label, '","',
            $alt-labels, '","',
            $uri, '","',
            $rels, '","',
            $entity-type, '","',
            $gender, '"'
        )
)