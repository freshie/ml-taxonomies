let $filename := xdmp:get-request-field-filename( "upload" )
(:
let $disposition := fn:concat( "attachment; filename=""", $filename, """" )
let $x := xdmp:add-response-header( "Content-Disposition", $disposition )
let $x:= xdmp:set-response-content-type( xdmp:get-request-field-content-type( "upload" ) )
:)
let $path := fn:concat( "http://lds.org/sem/images/", $filename )
let $binary := xdmp:get-request-field( "upload" )
return xdmp:document-insert( $path, $binary );


declare namespace xh = "http://www.w3.org/1999/xhtml";
let $filename := xdmp:get-request-field-filename( "upload" )
let $path := fn:concat( "http://lds.org/sem/images/", $filename )
let $meta := xdmp:document-filter( fn:doc( $path ) )
return
    <metadata>
    {
    for $m in $meta//xh:meta
    return <item name="{ xs:string( $m/@name ) }">{ xs:string( $m/@content ) }</item>
    }
    </metadata>