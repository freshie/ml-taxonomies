declare function local:clean-up-subject( $subject ) {
    if ( $subject castable as xs:integer )
        then ()
        else
    if ( fn:starts-with( $subject, "_" ) )
        then ()
        else
    if (
            fn:contains( $subject, ".jpg" ) or 
            fn:contains( $subject, ".gif" ) or 
            fn:contains( $subject, ".png" ) or
            fn:contains( $subject, ".eps" ) or
            fn:contains( $subject, ".psd" ) or
            fn:contains( $subject, ".tif" ) or
            fn:contains( $subject, ".dng" ) or
            fn:contains( $subject, "unknown" )
        )
        then ()
        else fn:normalize-space( $subject )
};


let $vrl-subjects :=
    <vrl-subjects>
    {
    for $subject in fn:distinct-values( xdmp:directory( "http://lds.org/sem/content/images/", "infinity" )//subject/fn:lower-case( text() ) )
    let $new-subject := local:clean-up-subject( $subject )
    order by $subject
    return
        if ( $new-subject )
            then <vrl-subject>{ $new-subject }</vrl-subject>
            else ()
    }
    </vrl-subjects>
return
    for $s in $vrl-subjects/vrl-subject
    return fn:concat( '"', $s, '"' )