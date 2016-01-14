import module namespace semf = "org.lds.common.semantic-functions" at "/semantic/lib/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/sem/lib/core-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

for $concept in fn:doc( "http://lds.org/sem/cpg.xml" )//concept
let $base-uri := semf:format-as-uri( $concept/uri-base/text() )
let $s := fn:concat( "http://www.lds.org/concept/cpg/", $base-uri )
let $pref-label := $concept/label/text()
let $alt-label := $concept/label-alt/text()
let $parent-uri :=
    if ( $concept/@parent = "" )
        then "http://www.lds.org/concept/cpg/curriculum-planning-guide"
        else fn:concat( "http://www.lds.org/concept/cpg/", semf:format-as-uri( fn:doc( "http://lds.org/sem/cpg.xml" )//concept[@id = $concept/@parent]/uri-base/text() ) )
let $notes := $concept/notes/text()
let $s-gtts := fn:concat( "http://www.lds.org/concept/gs/", $base-uri )
let $rel := fn:doc()//sem:triple[
    sem:subject = $s-gtts and 
    sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme" and
    sem:object = "http://www.lds.org/concept-scheme/guide-to-the-scriptures"]/sem:subject/text()
let $rel-count := fn:count( $rel ) + 1
let $triples :=
    <sem:triples rels="{ $rel-count }">
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
            <sem:object datatype="sem:iri">http://www.w3.org/2004/02/skos/core#Concept</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
            <sem:object datatype="sem:iri">http://www.lds.org/concept-scheme/curriculum-planning-guide</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
            <sem:object xml:lang="eng" datatype="xsd:string">{ $pref-label }</sem:object>
        </sem:triple>
        {
        if ( $rel )
            then
                <sem:triple>
                    <sem:subject>{ $s }</sem:subject>
                    <sem:predicate>http://www.w3.org/2004/02/skos/core#related</sem:predicate>
                    <sem:object datatype="sem:iri">{ $rel }</sem:object>
                </sem:triple>
            else ()
        }
        {
        if ( $alt-label )
            then
                <sem:triple>
                    <sem:subject>{ $s }</sem:subject>
                    <sem:predicate>http://www.w3.org/2004/02/skos/core#altLabel</sem:predicate>
                    <sem:object xml:lang="eng" datatype="xsd:string">{ $alt-label }</sem:object>
                </sem:triple>
            else ()
        }
        {
        if ( $notes )
            then
                <sem:triple>
                    <sem:subject>{ $s }</sem:subject>
                    <sem:predicate>http://www.w3.org/2004/02/skos/core#note</sem:predicate>
                    <sem:object xml:lang="eng" datatype="xsd:string">{ $notes }</sem:object>
                </sem:triple>
            else ()
        }
        {
        if ( $parent-uri )
            then
                <sem:triple>
                    <sem:subject>{ $s }</sem:subject>
                    <sem:predicate>http://www.w3.org/2004/02/skos/core#narrower</sem:predicate>
                    <sem:object datatype="sem:iri">{ $parent-uri }</sem:object>
                </sem:triple>
            else ()
        }
    </sem:triples>
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
let $path := fn:concat( "http://lds.org/sem/core/cpg/", $base-uri, ".xml" )
(: order by $concept/uri-base :)
return xdmp:document-insert( $path, $new-triples )
