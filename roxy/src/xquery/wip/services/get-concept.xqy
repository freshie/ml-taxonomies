xquery version "1.0-ml";

declare option xdmp:output "method = html";

let $concepts := xdmp:get-request-field( "concepts", "" )
let $clear := xdmp:get-request-field( "clear", "" )
let $concepts-json :=
    if ( $clear = "Clear" )
        then "[]"
        else
            fn:concat(
                "[",
                fn:string-join(
                    for $concept in fn:tokenize( $concepts, ";" )
                    return fn:concat( '{id: "', $concept, '", name: "', $concept, '"}' )
                , "," ),
                "]"
            )
let $concepts :=
    if ( $clear = "Clear" )
        then ()
        else $concepts
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>
    
        <title>LDS Taxonomies Web Service</title>
        
        <!-- Latest compiled and minified CSS -->
        <link href="/sem/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    
        <!-- GlyphIcons -->
        <link href="/sem/css/bootstrap-glyphicons.css" rel="stylesheet"/>
    
        <!-- Latest compiled and minified JavaScript -->
        <script src="http://code.jquery.com/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="/sem/bootstrap/js/bootstrap.min.js"></script>
        
        <!-- <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script> -->
        <script type="text/javascript" src="jquery.tokeninput.js"></script>
        <link rel="stylesheet" type="text/css" href="token-input.css" />
        <link rel="stylesheet" type="text/css" href="token-input-facebook.css" />
        <link rel="stylesheet" type="text/css" href="services.css" />

        <script type="text/javascript">
        $(document).ready(function () {{
            $("#concepts").tokenInput("find-concept.xqy",
                {{
                    hintText: "Search for a concept...",
                    theme: "facebook",
                    minChars: 3,
                    tokenDelimiter: ";",
                    preventDuplicates: "true",
                    prePopulate: { $concepts-json }
                }});
        }});
        </script>

    </head>
    <body xmlns="" class="top-padding">
    
        <div class="container">
            <div class="row">
                <div class="col-lg-12 well">
    
                    <form name="concepts" action="get-concept.xqy" method="post">
                        <p>
                            <input type="text" id="concepts" name="concepts" class="form-control" value=""/>
                        </p>
                        <p>
                            <input type="submit" class="btn btn-primary" value="Display" name="display"></input>&nbsp;
                            <input type="submit" class="btn btn-default" value="Clear" name="clear"></input>
                        </p>
                        <p>
                            <textarea class="form-control" readonly="readonly">{ fn:replace( $concepts, ";", "; " ) }</textarea>
                        </p>
                    </form>

                </div>
                
            </div>
        </div>        
        
    </body>
</html>
