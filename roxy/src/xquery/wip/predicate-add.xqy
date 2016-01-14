xquery version "1.0-ml";

import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $core := "http://lds.org/sem/core/";


let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $errors := fn:tokenize( xdmp:get-request-field( "errors", "" ), "," )
let $label := xdmp:get-request-field( "label", "" )
let $iri := xdmp:get-request-field( "iri", "" )
let $prefix := xdmp:get-request-field( "prefix", "" )
let $selected-datatype := xdmp:get-request-field( "datatype", "" )
let $note := xdmp:get-request-field( "note", "" )
let $link := xdmp:get-request-field( "link", "" )
let $prefix-list := semantics:get-prefixes-list()
let $predicate-list := semantics:get-predicates-list()
let $datatype-list := fn:doc( "http://lds.org/sem/model/datatypes.xml" )
let $err-label-missing := if ( $errors[1] = "1" ) then " has-error" else ""
let $err-iri-problem := if ( $errors[2] = "1" or $errors[3] = "1" ) then " has-error" else ""
return

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content=""/>
        <meta name="author" content=""/>

        <title>LDS Taxonomies</title>

        <!-- Latest compiled and minified CSS -->
        <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        
        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/jumbotron-narrow.css" rel="stylesheet"/>
    
        <!-- GlyphIcons -->
        <link href="/bootstrap/css/bootstrap-glyphicons.css" rel="stylesheet"/>
    
        <!-- Latest compiled and minified JavaScript -->
        <script src="http://code.jquery.com/jquery.js"></script>
    
        <!-- Include all compiled plugins (below), or include individual files as needed -->
        <script src="/bootstrap/js/bootstrap.min.js"></script>

        <!-- Custom styles for this template -->
        <link href="/bootstrap/css/navbar-fixed-top.css" rel="stylesheet"/>
        
    </head>

  <body xmlns="">

        <!-- Fixed navbar -->
        <div class="navbar navbar-fixed-top">
            <div class="container">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".nav-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="default.xqy">LDS Taxonomies</a>
                <div class="nav-collapse collapse">
                { core:menu-main( "Explore", $user ) }
                </div><!--/.nav-collapse -->
            </div>
        </div>

    <div class="container-narrow">
        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Create a predicate</div>
                    <p></p>

                    <form method="post" action="predicate-save.xqy">
                        <!-- List group -->
                        <ul class="list-group">
                            <li class="list-group-item">
                                <div class="input-group{ $err-label-missing }">
                                    <span class="input-group-addon">Label</span>
                                    <input name="label" value="{ $label }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                { if ( $errors[2] = "1" ) then <p class="text-danger">The IRI "{ $iri }" already exists.</p> else () }
                                <div class="input-group{ $err-iri-problem }">
                                    <span class="input-group-addon">IRI</span>
                                    <input name="iri" value="{ $iri }" type="text" class="form-control"/>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Prefix</span>
                                    <select name="prefix" class="form-control">
                                    {
                                    for $prefix in $prefix-list/prefix
                                    return
                                        if ( $prefix/text() = $prefix )
                                            then <option value="{ $prefix/text() }" selected="selected">{ $prefix/text() }</option>
                                            else <option value="{ $prefix/text() }">{ $prefix/text() }</option>
                                    }
                                    </select>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Datatype</span>
                                    <select name="datatype" class="form-control">
                                    {
                                    for $dt in $datatype-list//datatype
                                    return
                                        if ( $dt = $selected-datatype )
                                            then <option value="{ $dt/text() }" selected="selected">{ xs:string( $dt/@short ) }</option>
                                            else <option value="{ $dt/text() }">{ xs:string( $dt/@short ) }</option>
                                    }
                                    </select>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Notes</span>
                                    <textarea name="note" rows="4" class="form-control">{ $note }</textarea>
                                </div>
                            </li>
                            <li class="list-group-item">
                                <div class="input-group">
                                    <span class="input-group-addon">Link</span>
                                    <input name="link" value="{ $link }" type="text" class="form-control"/>
                                </div>
                            </li>
                        </ul>
                        <button type="submit" class="btn btn-default">Create</button>
                    </form>
                </div><!-- Panel -->
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <div class="panel">
                    <!-- Default panel contents -->
                    <div class="panel-heading">Existing predicates</div>
                    <p>Predicates are properties that link subjects and objects.</p>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Prefix</th>
                                <th>IRI and datatype</th>
                            </tr>
                        </thead>
                        <tbody>
                        {
                        for $predicate in $predicate-list/predicate
                        order by $predicate/@schema, $predicate/text()
                        return
                            <tr>
                                <td>{ $predicate/text() }</td>
                                <td>{ xs:string( $predicate/@schema ) }</td>
                                <td>
                                    <div>{ xs:string( $predicate/@value ) }</div>
                                    <small class="text-muted">{ xs:string( $predicate/@datatype ) }</small>
                                </td>
                            </tr>
                        }
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
    </div> <!-- /container -->

    </body>
</html>
