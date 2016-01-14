import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

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

    <!-- Latest compiled and minified JavaScript -->
    <script src="http://code.jquery.com/jquery.js"></script>

    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/sem/bootstrap/js/bootstrap.min.js"></script>

    </head>

    <body xmlns="">

    <div class="container-narrow">
      <div class="header">
        <ul class="nav nav-pills pull-right">
        { core:main-menu( "Home" ) }        
        </ul>
        <h3 class="text-muted">Core Taxonomies</h3>
      </div>

      <div class="jumbotron">
        <h1>Doctrine T-Core</h1>
        <p class="lead">The Doctrine Taxonomy Core (T-Core) combines the comprehensive and detailed Gospel-based 'Guide to the Scriptures' concept list with the relevant and hierarchically constructed 'Curriculum Planning Guide.'  Together, they provide a focused, semantically related taxonomy capable of enriching any content for search and retrieval systems.</p>
        <p><a class="btn btn-large btn-success" href="explore.xqy">Get started</a></p>
      </div>

      <div class="row marketing">
        <div class="col-lg-6">
          <h4>Search</h4>
          <p>Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum.</p>

          <h4>Explore</h4>
          <p>Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cras mattis consectetur purus sit amet fermentum.</p>

          <h4>Connect</h4>
          <p>Maecenas sed diam eget risus varius blandit sit amet non magna.</p>
        </div>

        <div class="col-lg-6">
          <h4>Enrich</h4>
          <p>Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum.</p>

          <h4>Expand</h4>
          <p>Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cras mattis consectetur purus sit amet fermentum.</p>

          <h4>Study</h4>
          <p>Maecenas sed diam eget risus varius blandit sit amet non magna.</p>
        </div>
      </div>

      <div class="footer">
        <p>&copy; Company 2013</p>
      </div>

    </div> <!-- /container -->

  </body>
</html>
