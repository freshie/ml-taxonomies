(: Pronunciation, part of speech, gender :)
declare namespace sem = "http://marklogic.com/semantics";

declare function local:set-member( $member ) {
    if ( $member )
        then fn:concat( "http://lds.org/concept/gs/", $member )
        else ()
};

declare function local:set-entity-type( $str ) {
    if ( $str eq "asset" )
        then "http://www.schema.org/CreativeWork"
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
    if ( $str eq "location" or $str eq "place" )
        then "http://www.schema.org/Place"
        else "http://www.lds.org/Topic"
};


for $concept in xdmp:directory( "http://lds.org/semantic/ootr/topic/" )//fact-set[t/p = "http://lds.org/thing#scope" and t/o = "New Testament People"]
let $base-uri := fn:tokenize( xs:string( $concept/@uri ), "/" )[fn:last()]
let $s := fn:concat( "http://lds.org/concept/gs/", $base-uri )
let $pref-label := $concept/t[p = "http://lds.org/thing#label"]/o/text()
let $alt-label := $concept/t[p = "http://lds.org/thing#sub-title"]/o/text()
let $pos := $concept/t[p = "http://lds.org/term#part-of-speech"]/o/text()
let $pronunciation := $concept/t[p = "http://lds.org/term#pronunciation"]/o/text()
let $gender := $concept/t[p = "http://lds.org/person#gender"]/o/text()

let $rels :=
    for $rel in $concept/t[p = "http://lds.org/term#related-topic"]/o/text()
    return
        if ( xdmp:directory( "http://lds.org/semantic/ootr/topic/" )//fact-set[@uri = $rel and t/p = "http://lds.org/thing#scope" and t/o = "Guide to the Scriptures"] )
            then fn:concat( "http://lds.org/concept/gs/", fn:tokenize( $rel, "/" )[fn:last()] )
            else ()
let $rel-count := fn:count( $rels )
let $triples :=
    <sem:triples rels="{ $rel-count }">
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
            <sem:object>http://www.schema.org/Person</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
            <sem:object>http://lds.org/concept-scheme/people</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
            <sem:object>{ $pref-label }</sem:object>
        </sem:triple>
        { if ( $alt-label )
            then
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#altLabel</sem:predicate>
            <sem:object>{ $alt-label }</sem:object>
        </sem:triple>
            else ()
        }
        { if ( $pronunciation )
            then
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.lds.org/core#pronunciation</sem:predicate>
            <sem:object>{ $pronunciation }</sem:object>
        </sem:triple>
            else ()
        }
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.lds.org/core#partOfSpeech</sem:predicate>
            <sem:object>{ $pos }</sem:object>
        </sem:triple>
        { if ( $gender )
            then
        <sem:triple>
            <sem:subject>{ $s }</sem:subject>
            <sem:predicate>http://www.lds.org/core#gender</sem:predicate>
            <sem:object>{ $gender }</sem:object>
        </sem:triple>
            else ()
        }
        {
        for $rel in $rels
        return
            <sem:triple>
                <sem:subject>{ $s }</sem:subject>
                <sem:predicate>http://www.w3.org/2004/02/skos/core#related</sem:predicate>
                <sem:object>{ $rel }</sem:object>
            </sem:triple>
        }
        {
        for $i in $concept/t[p = "http://lds.org/thing#instance-of"]/o/text()
        return
            <sem:triple>
                <sem:subject>{ $s }</sem:subject>
                <sem:predicate>http://www.lds.org/core#instanceOf</sem:predicate>
                <sem:object>http://www.lds.org{ $i }</sem:object>
            </sem:triple>
        }
    </sem:triples>
let $path := fn:concat( "http://lds.org/sem/core/people/", $base-uri, ".xml" )
return xdmp:document-insert( $path, $triples )
