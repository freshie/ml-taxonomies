xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";
declare variable $core := "http://lds.org/sem/core/";

let $foo := ""
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
    
  </head>

  <body xmlns="">

    <div class="container-narrow">
        <div class="header">
            <ul class="nav nav-pills pull-right">
            { core:main-menu( "Enrich" ) }        
            </ul>
            <h3 class="text-muted">Core Taxonomies</h3>
        </div>
        <div class="row-fluid">
            <div class="col-lg-12">
                <form method="post" action="upload.xqy?uid={ xdmp:random() }" enctype="multipart/form-data">
                  <fieldset>
                    <legend>Enrich</legend>
                    <div class="form-group">
                      <label for="exampleInputFile">File input</label>
                      <input name="upload" type="file" id="exampleInputFile"/>
                      <p class="help-block">Select a file to upload.</p>
                    </div>
                    <button type="submit" class="btn btn-default">Submit</button>
                  </fieldset>
                </form>
            </div>
        </div>
    </div> <!-- /container -->

  </body>
</html>
