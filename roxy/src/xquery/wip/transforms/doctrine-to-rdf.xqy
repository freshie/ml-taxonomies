declare namespace sem = "http://marklogic.com/semantics";

<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
    {
    for $triples in xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/", "infinity" )//sem:triples
    let $about := fn:normalize-space( $triples/sem:triple[sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]/sem:subject/string() )
    let $prefLabel := fn:normalize-space( $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/string() )
    let $inScheme := $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme"]/sem:object/string()
    return
        <rdf:Description rdf:about="{ $about }" dc:title="{ $prefLabel }">
        {
        if ( $about = $inScheme )
            then
                <skos:ConceptScheme rdf:about="{ $about }">
                    <skos:prefLabel xml:lang="en">{ $prefLabel }</skos:prefLabel>
                </skos:ConceptScheme>
            else
                <skos:Concept rdf:about="{ $about }">
                    <skos:inScheme rdf:resource="{ $inScheme }"/>
                    <skos:prefLabel xml:lang="en">{ $prefLabel }</skos:prefLabel>
                    {
                    for $t in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#altLabel"]
                    return <skos:altLabel rdf:resource="{ $t/sem:object/string() }"/>
                    }
                    {
                    for $t in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#broader"]
                    return <skos:broader rdf:resource="{ $t/sem:object/string() }"/>
                    }
                    {
                    for $t in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#narrower"]
                    return <skos:narrower rdf:resource="{ $t/sem:object/string() }"/>
                    }
                    {
                    for $t in $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#related"]
                    return <skos:related rdf:resource="{ $t/sem:object/string() }"/>
                    }
                </skos:Concept>
        }
        </rdf:Description>
    }
</rdf:RDF>
