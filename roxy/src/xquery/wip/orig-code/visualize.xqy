xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $core := "http://lds.org/sem/core/";
declare variable $ontology := xdmp:get-request-field( "ontology", "cpg-out" );
declare variable $ontologies :=
    <options>
        <option value="cpg-out">Curriculum Planning Guide</option>
        <option value="core-out">Combined (no clustering)</option>
        <option value="core-out2">Combined</option>
    </options>;

declare option xdmp:output "method = html";

declare function local:select( $name, $options, $selected ) {
    <select name="{ $name }" class="form-control ui-widget">
    {
    for $option in $options/option
    return
        if ( $selected = $option/@value )
            then <option value="{ xs:string( $option/@value ) }" selected="selected">{ $option/text() }</option>
            else <option value="{ xs:string( $option/@value ) }">{ $option/text() }</option>
    }
    </select>
};


let $onto-file := fn:concat( "data/", $ontology, ".gexf" )
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>
    
        <title>Doctrine T-Core</title>
    
        <!-- Latest compiled and minified CSS -->
        <link href="/sem/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        
        <!-- Custom styles for this template -->
        <link href="/sem/bootstrap/css/jumbotron-narrow.css" rel="stylesheet"/>
    
        <!-- GlyphIcons -->
        <link href="/sem/bootstrap/css/bootstrap-glyphicons.css" rel="stylesheet"/>
    
        <!-- Latest compiled and minified JavaScript -->
        <script src="http://code.jquery.com/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="/sem/bootstrap/js/bootstrap.min.js"></script>
    
        <!-- Sigma Javascript -->
        <link href="css/sigma.css" rel="stylesheet"/>
        <script src="js/sigma/prettify.js"></script>
        <script src="js/sigma/sigma.js"></script>
        <script src="js/sigma/sigma.parseGexf.js"></script>
        <script src="js/sigma/sigma-{ $ontology }.js"></script>

    </head>

    <body onload="init('{ $onto-file }');" xmlns="">

        <div class="container-narrow">
            <div class="header">
                <ul class="nav nav-pills pull-right">
                { core:main-menu( "Visualize" ) }        
                </ul>
                <h3 class="text-muted">Core Taxonomies</h3>
            </div>
        
            <div class="row">
                <div class="col-lg-12 sigma-parent" id="sigma-example-parent">
                    <div class="sigma-expand" id="sigma-example"></div>
                </div>                    
            </div>
            
            <div class="row">
                <div class="col-lg-12">
                    <p>
                        <form method="get" action="visualize.xqy" class="form-inline">
                            <p class="input-group">
                                <span class="input-group-addon input-sm">Visualization</span>
                                { local:select( "ontology", $ontologies, $ontology ) }
                            </p>
                            <button type="submit" class="btn btn-primary">Display</button>
                        </form>
                    </p>
                </div>
            </div>

        </div> <!-- /container -->

    </body>
</html>
