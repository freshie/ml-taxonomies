module namespace semf = "org.lds.common.semantic-functions";

declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace th = "http://marklogic.com/xdmp/thesaurus";

declare variable $gmap := map:map();
declare variable $semf:STOP-WORDS-ENG-LDS :=
    ("brother","church","counselor","elder","general","latter","day","presidency","president","saint","sister");
declare variable $semf:STOP-WORDS-ENG :=
    (
    "a","about","above","again","all","also","although","always","am","among","an","and","another","any","are","around","as","at","away",
    "b","be","because","been","between","both","but","by",
    "c","can","com","could",
    "d","do","does","doesnt","did","done","dont",
    "e","each","else","etc","every",
    "f","few","for","from",
    "g","gmail",
    "h","had","has","have","he","hello","her","hi","him","his","hotmail","how","however","http",
    "i","if","in","into","is","isnt","it","its",
    "j","just",
    "k",
    "l","lds","let","like",
    "m","many","me","my","mine","more","most","must",
    "n","net","no","none","not","now",
    "o","of","on","only","or","org","other","our","over",
    "p","part",
    "q",
    "r","re",
    "s","said","say","set","she","should","so","some","still","such",
    "t","than","thank","that","the","them","then","there","their","therefore","themselves","these","they","theyve","thing","things","this","those","through","to","too","toward","try",
    "u","us",
    "v","ve","very",
    "w","was","we","were","what","when","where","which","while","who","with","would","why","will",
    "y","yahoo","you","your","yours",
    "0","1","2","3","4","5","6","7","8","9"
    );
declare variable $semf:STOP-WORDS-JPN :=
    (
    "に","の","は","を","が","へ","か","な","で","も","と",
    "0","1","2","3","4","5","6","7","8","9"
    );
declare variable $semf:FAMILY-RELS :=
    (
    "http://lds.org/person#brother-of",
    "http://lds.org/person#descendant-of",
    "http://lds.org/person#father-of",
    "http://lds.org/person#sibling-of",
    "http://lds.org/person#son-of",
    "http://lds.org/person#spouse-of",
    "http://lds.org/person#husband-of",
    "http://lds.org/person#wife-of"
    );

declare function semf:wrap-phrases( $text ) {
    let $quoted-text := xdmp:quote( $text )
    let $quoted-text := fn:replace( $quoted-text, "\]\s\[", " " )
    let $quoted-text := fn:replace( $quoted-text, "(\[)", "<key>" )
    let $quoted-text := fn:replace( $quoted-text, "(\])", "</key>" )
    return xdmp:unquote( $quoted-text )
};

declare function semf:wrap-phrases( $text, $prefix, $suffix ) {
    let $quoted-text := xdmp:quote( $text )
    let $quoted-text := fn:replace( $quoted-text, "\]\s\[", " " )
    let $quoted-text := fn:replace( $quoted-text, "(\[)", $prefix )
    let $quoted-text := fn:replace( $quoted-text, "(\])", $suffix )
    return xdmp:unquote( $quoted-text )
};

declare function semf:text-to-vertices( $text ) {
    let $map := map:map()
    let $tokens := fn:tokenize( $text, " " )
    let $token-count := fn:count( $tokens )
    let $starting-pr := 1 div $token-count
    let $vertices :=
        <vertices>
        {
        for $word at $ptr in $tokens
        return <vertex x="{ $word }" y="{ $tokens[$ptr + 1] }"/>
        }
        </vertices>
    let $foo :=
        for $v in fn:distinct-values( $vertices/vertex/@x )
        let $in := fn:string-join( fn:distinct-values( $vertices/vertex[@y eq $v and @x ne $v]/xs:string( @x  ) ), "," )
        let $out := fn:string-join( fn:distinct-values( $vertices/vertex[@x eq $v and @y ne $v]/xs:string( @y ) ), "," )
        let $values := fn:concat( $in, ":", $out, ":", xs:string( $starting-pr ) )
        return if ( $v = "" ) then () else map:put( $map, $v, $values )
    return $map
};

declare function semf:remove-pos( $text, $pos-to-remove as item()* ) {
    fn:string-join(
        for $word in fn:tokenize( $text, " " )
        let $stem := cts:stem( $word )[1]
        let $pos := fn:doc( "/gospel-topical-explorer/thesaurus/thesaurus.xml" )//th:entry[th:term eq $stem]/th:part-of-speech/text()
        return if ( fn:sum( fn:index-of( $pos-to-remove, $pos ) ) = 0 ) then $word else ()
    , " " )
};

declare function semf:normalize-words( $str, $remove-stop-words, $pos, $lang ) {
    let $normalized :=
        fn:string-join( 
            for $token in cts:tokenize( $str, $lang ) (: Limit to n words? :)
            return
                typeswitch ( $token )
                    case $token as cts:punctuation return semf:handle-punct( $token )
                    case $token as cts:word return
                        if ( $token castable as xs:integer )
                            then ()
                            else fn:lower-case( $token )
                    case $token as cts:space return " "
                    default return ()
        , " " )
    let $normalized := 
        if ( $remove-stop-words )
            then semf:remove-stop-words( $normalized, $lang )
            else $normalized
    let $normalized :=
        if ( fn:count( $pos ) > 0 )
            then semf:remove-pos( $normalized, $pos )
            else $normalized
    return fn:normalize-space( $normalized )
};

declare function semf:handle-punct( $char ) {
    if ( $char = "—" or $char = "-" )
        then " "
        else ()
};

declare function semf:text-rank( $map, $iteration as xs:integer ) {
    let $max-terms := 20
    let $convergence-threshold := 0.0001
    let $damping-factor := 0.85
    let $new-map := map:map()
    let $vertex-count := map:count( $map )
    let $foo :=
        for $vertex in map:keys( $map )
        let $tokens := fn:tokenize( map:get( $map, $vertex ), ":" )
        let $previous-score := xs:double( $tokens[3] ) 
        let $score := 
            ((1 - $damping-factor) div $vertex-count) + ($damping-factor * (
            fn:sum( 
                for $in-link in fn:tokenize( $tokens[1], "," )
                let $in-tokens := fn:tokenize( map:get( $map, $in-link ), ":" )
                let $in-pr := xs:double( $in-tokens[3] )
                let $in-link-out-count := fn:count( fn:tokenize( $in-tokens[2], "," ) )
                return xs:double( $in-pr div $in-link-out-count )
            )))
        let $er := fn:abs( $score - $previous-score )
        return map:put( $new-map, $vertex, fn:concat( $tokens[1], ":", $tokens[2], ":", $score, ":", $er ) )
    let $convergence :=
        fn:min(
            for $x in map:keys( $new-map )
            let $er := xs:double( fn:tokenize( map:get( $new-map, $x ), ":" )[4] )
            return if ( $er eq 0 ) then () else $er
        )
    let $foo := map:put( $gmap, xs:string( $iteration ), $new-map )
    return
        if ( $convergence lt $convergence-threshold or ($iteration eq 1) )
            then (: $gmap :) $new-map
            else semf:text-rank( $new-map, $iteration - 1 )
};

declare function semf:get-subject-from-string( $topic as xs:string ) {
    xs:string( xdmp:directory( "/gospel-topical-explorer/semantic/ootr/", "infinity" )//t[o = $topic and p = "http://lds.org/thing#label"]/s )[1]
};

declare function semf:get-http-page( $url ) {
    let $page :=
        if ( $url = "" )
            then ()
            else xdmp:tidy( xdmp:http-get( $url )[2] )//xh:body
    return <page>{$page//(xh:h1|xh:p) }</page>
};

declare function semf:main-menu() {
    for $item in fn:doc( "/gospel-topical-explorer/semantic/ootr/menu.xml" )//item
    return <li class="active"><a href="{ xs:string( $item/url ) }">{ xs:string( $item/label ) }</a></li>
};

declare function semf:remove-stop-words( $str as xs:string, $lang ) as xs:string {
    let $stop-words :=
        if ( fn:upper-case( $lang ) eq "JPN" )
            then $semf:STOP-WORDS-JPN
            else $semf:STOP-WORDS-ENG
    return 
        fn:string-join(
            for $word in fn:tokenize( $str, " " )
            return
                if ( fn:index-of( $stop-words, fn:lower-case( $word ) ) > 0 )
                    then ()
                    else $word
        , " " )
};

declare function semf:format-as-uri( $s as xs:string ) as xs:string {
    let $s := fn:replace( $s, "&amp;", "-" )
    let $s := xdmp:diacritic-less( $s )
    let $s := fn:lower-case( $s )
    let $s := fn:replace( $s, "[^0-9a-z\- ]", "" )
    let $s := fn:normalize-space( $s )
    let $s := fn:replace( $s, " ", "-" )
    let $s := fn:replace( $s, "--", "-" )    
    return $s
};

declare function semf:build-triple( $s as xs:string, $p as xs:string, $o as xs:string, $type as xs:string ) as node()* {
    if ( $s = "" or $p = "" or $o = "" )
        then ()
        else
    if ( $type = "" )
        then
            <t>
                <s>{ $s }</s>
                <p>{ $p }</p>
                <o type="str">{ $o }</o>
            </t>
        else
            <t>
                <s>{ $s }</s>
                <p>{ $p }</p>
                <o type="{ $type }">{ $o }</o>
            </t>
};

declare function semf:build-triple( $s as xs:string, $p as xs:string, $o as xs:string, $c as xs:string, $type as xs:string ) as node()* {
    if ( fn:empty( $c ) )
        then semf:build-triple( $s, $p, $o, $type )
        else
            if ( $type = "" )
                then
                    <t>
                        <s>{ $s }</s>
                        <p>{ $p }</p>
                        <o type="str">{ $o }</o>
                        <c>{ $c }</c>
                    </t>
                else
                    <t>
                        <s>{ $s }</s>
                        <p>{ $p }</p>
                        <o type="{ $type }">{ $o }</o>
                        <c>{ $c }</c>
                    </t>
};

declare function semf:build-triple( $s as xs:string, $p as xs:string, $o as xs:string, $c as xs:string, $d, $type as xs:string ) as node()* {
    if ( fn:empty( $d ) )
        then semf:build-triple( $s, $p, $o, $c, $type )
        else
            if ( $type = "" )
                then
                    <t>
                        <s>{ $s }</s>
                        <p>{ $p }</p>
                        <o type="str">{ $o }</o>
                        <c>{ $c }</c>
                        <d>{ $d }</d>
                    </t>
                else
                    <t>
                        <s>{ $s }</s>
                        <p>{ $p }</p>
                        <o type="{ $type }">{ $o }</o>
                        <c>{ $c }</c>
                        <d>{ $d }</d>
                    </t>
};

declare function semf:passthru( $x as node(), $s as xs:string ) as node()* {
    for $z in $x/node() return semf:dispatch( $z, $s )
};

declare function semf:dispatch( $node as node(), $s as xs:string ) as node()* {
    typeswitch ( $node )
        case text() return $node
        case element( person ) return <fact-set uri="{ $s }">{ semf:passthru( $node, $s ) }</fact-set>
        case element( topic ) return <fact-set uri="{ $s }">{ semf:passthru( $node, $s ) }</fact-set>
        case element( aka ) return semf:build-triple( $s, "http://lds.org/person#aka", $node/text(), "" )
        case element( audience ) return semf:build-triple( $s, "http://lds.org/thing#audience", $node/text(), "" )
        case element( calling ) return semf:build-triple( $s, "http://lds.org/calling", $node/text(), "" )
        case element( core-message ) return semf:build-triple( $s, "http://lds.org/topic#core-message", $node/text(), "" )
        case element( description ) return semf:build-triple( $s, "http://lds.org/thing#description", $node/text(), "" )
        case element( entity-type ) return semf:build-triple( $s, "http://lds.org/thing#entity-type", $node/text(), "str" )
        case element( gender ) return semf:build-triple( $s, "http://lds.org/person#gender", $node/text(), "" )
        case element( gen-rel ) return semf:build-triple( $s, fn:concat( "http://lds.org/person#", xs:string( $node/@type ) ), $node/text(), "s-ref" )
        case element( group ) return semf:build-triple( $s, "http://lds.org/organization/group", $node/text(), "" )
        case element( instance ) return semf:build-triple( $s, "http://lds.org/thing#instance-of", xs:string( $node/@uri  ), xs:string( $node/@context ), $node/node(), "uri" )
        case element( instances ) return semf:passthru( $node, $s )
        case element( latitude ) return semf:build-triple( $s, "http://lds.org/place#latitude", $node/text(), "" )
        case element( longitude ) return semf:build-triple( $s, "http://lds.org/place#longitude", $node/text(), "" )
        case element( pos ) return semf:build-triple( $s, "http://lds.org/term#part-of-speech", $node/text(), "" )
        case element( rel ) return semf:build-triple( $s, fn:concat( "http://lds.org/term#", xs:string( $node/@type ) ), xs:string( $node/@uri  ), "s-ref" )
        case element( rels ) return semf:passthru( $node, $s )
        case element( role ) return semf:build-triple( $s, "http://lds.org/role", $node/text(), "" )
        case element( scope ) return semf:build-triple( $s, "http://lds.org/thing#scope", $node/text(), "" )
        case element( sub-region-of ) return semf:build-triple( $s, "http://lds.org/place#sub-region-of", $node/text(), "" )
        case element( sub-title ) return semf:build-triple( $s, "http://lds.org/thing#sub-title", $node/text(), "" )
        case element( title ) return semf:build-triple( $s, "http://lds.org/thing#label", $node/text(), "" )
        case element( variant ) return semf:build-triple( $s, "http://lds.org/term#variant", $node/text(), "" )
        case element( variants ) return semf:passthru( $node, $s )
        default return element { fn:local-name( $node ) } { ( $node/@*, semf:passthru( $node, $s ) ) }
};

declare function semf:cleanup-title( $s as xs:string ) as xs:string {
    let $s := fn:replace( $s, "¹", " 1" )
    let $s := fn:replace( $s, "²", " 2" )
    let $s := fn:replace( $s, "³", " 3" )
    let $s := fn:replace( $s, "⁴", " 4" )
    return $s
};

declare function semf:get-gen-rels( $data, $rel as xs:string ) {
    let $rel-type := semf:format-as-uri( $rel )
    let $rel-name := 
        if ( fn:contains( $data, $rel ) )
            then fn:replace( semf:cleanup-title( fn:tokenize( fn:normalize-space( fn:substring-after( $data, $rel ) ), " " )[1] ), "[^ a-zA-Z0-9-]", "$1" )
            else ()
    let $rel-name-uri := fn:concat( "/topic/", semf:format-as-uri( $rel-name ) )
    return
        if ( fn:contains( $data, $rel ) )
            then <gen-rel type="{ $rel-type }">{ $rel-name-uri }</gen-rel>
            else ()
};

declare function semf:build-grams( $words ) {
    let $words := semf:remove-stop-words( $words, "eng" )
    let $words := fn:replace( $words, "[^a-zA-Z0-9 ]", "$1" )
    let $tokens := fn:tokenize( $words, " " )
    let $count := fn:count( $tokens )
    for $x in (1 to $count)
    return
      for $y in (1 to $count)
      return
        if ( fn:empty( $tokens[$x to $y] ) )
          then ()
          else fn:string-join( $tokens[$x to $y], " " )
};

declare function semf:build-grams( $words, $throttle ) {
    let $words := semf:remove-stop-words( $words, "eng" )
    let $words := fn:replace( $words, "[^a-zA-Z0-9 ]", "$1" )
    let $tokens := fn:tokenize( $words, " " )
    let $count := fn:count( $tokens )
    for $x in (1 to $count)
    return
      for $y in (1 to $count)
      return
        if ( fn:empty( $tokens[$x to $y] ) )
          then ()
          else fn:string-join( $tokens[$x to $y], " " )
};

declare function semf:build-query( $grams ) {
    let $query :=
        cts:and-query((
            cts:or-query((
                for $gram in $grams
                return cts:word-query( $gram )
            )),
            cts:directory-query( "/gospel-topical-explorer/semantic/ootr/", "infinity" )
        ))
    return $query
};

declare function semf:build-query( $grams, $predicate ) {
    let $query :=
        cts:and-query((
            cts:or-query((
                for $gram in $grams
                return cts:word-query( $gram )
            )),
            cts:element-value-query( xs:QName( "p" ), $predicate ),
            cts:directory-query( "/gospel-topical-explorer/semantic/ootr/", "infinity" )
        ))
    return $query
};

declare function semf:get-label( $s ) {
    if ( $s = "" )
        then ""
        else xs:string( xdmp:directory( "/gospel-topical-explorer/semantic/ootr/", "infinity" )//t[s = $s and p = "http://lds.org/thing#label"]/o )[1]
};

declare function semf:get-title( $title as xs:string, $source-uri as xs:string ) {
    let $uri-title := fn:tokenize( $source-uri, "/" )[fn:last()]
    let $tokens := fn:tokenize( $title, " or " )
    let $new-title :=
        if ( fn:count( $tokens ) > 1 )
            then $tokens[1] 
            else $title
    let $aka-titles :=
        <aka-titles>
        {
        for $title in $tokens[2 to fn:count( $tokens )]
        return
            <aka>{ $title }</aka>
        }
        </aka-titles>
    let $sub-title :=
        if ( fn:contains( $title, " (" ) )
            then <sub-title>{ fn:substring-before( fn:substring-after( $title, " (" ), ")" ) }</sub-title>
            else ()
    let $new-title :=
        if ( fn:contains( $new-title, " (" ) )
            then fn:substring-before( $new-title, " (" )
            else
        if ( fn:contains( $new-title, " or " ) )
            then fn:tokenize( $new-title, " or " )[1]
            else $new-title
    let $new-uri := 
        if ( fn:count( $tokens ) > 1 )
            then fn:concat( "/topic/", semf:format-as-uri( $new-title ) )
            else fn:concat( "/topic/", $uri-title )
    let $same-as := fn:doc( "/gospel-topical-explorer/semantic/model/same-as2.xml" )//t[o = $new-uri]
    let $new-uri2 :=
        if ( $same-as )
            then xs:string( $same-as/s )
            else $new-uri
    return
        <title uri="{ $new-uri2 }">
            <title>{ $new-title }</title>
            <orig-title>{ $title }</orig-title>
            <uri-title>{ $uri-title }</uri-title>
            { if ( fn:count( $aka-titles//aka ) = 0 ) then () else $aka-titles }
            { $sub-title }
        </title>
};

declare function semf:get-verses( $verses ) {
    let $tokens := fn:tokenize( $verses, "," )
    let $a :=
        for $x in $tokens
        return
            if( fn:matches( $x, "-" ) )
            then ( semf:get-verse-range( $x ) )
            else ( xs:int( $x ) )
    return $a
};

declare function semf:get-verse-range( $range ) {
    let $start := fn:substring-before( $range, "-" ) cast as xs:int
    let $end := fn:substring-after( $range, "-" ) cast as xs:int
    return ($start to $end)
};

declare function semf:pad( $str as xs:string, $chr as xs:string, $len as xs:integer ) as xs:string {
    let $pad-len := $len - fn:string-length( $str )
    let $padded-str := fn:concat( fn:string-join( for $x in 1 to $pad-len return $chr, "" ), $str )
    return $padded-str
};
