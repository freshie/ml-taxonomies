let $doc := fn:doc( "http://lds.org/sem/cpg.txt" )
return
    <concepts>
    {
    for $line in fn:tokenize( $doc, "\n" )
    let $l := fn:normalize-space( $line )
    let $id := fn:normalize-space( fn:tokenize( $l, " " )[1] )
    let $new-line := fn:string-join( fn:tokenize( $l, " " )[2 to fn:last()], " " )
    let $notes :=
        if ( fn:contains( $new-line, ": " ) )
            then fn:substring-after( $new-line, ": " )
            else ()
    let $label :=
        if ( fn:contains( $new-line, ": " ) )
            then fn:substring-before( $new-line, ": " )
            else $new-line
    let $id-tokens := fn:tokenize( $id, "\." )
    let $parent := fn:string-join( fn:tokenize( $id, "\." )[1 to (fn:count( $id-tokens ) - 2)], "." )
    return
        <concept id="{ $id }" parent="{ $parent }">
            <label>{ $new-line }</label>
            <uri-base>{ $label }</uri-base>
            { if ( $notes ) then <notes>{ $notes }</notes> else () }
        </concept>
    }
    </concepts>