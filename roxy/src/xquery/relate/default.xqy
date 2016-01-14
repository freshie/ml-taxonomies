xquery version "1.0-ml";

import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

import module namespace relate = "org.lds.gte.relate.functions" at "/relate/modules/functions.xqy";


declare namespace sem = "http://marklogic.com/semantics";

declare option xdmp:output "method = html";

declare variable $subject := core:cleanInput(xdmp:get-request-field( "subject", "Smith, Joseph Jr." ));
declare variable $target := core:cleanInput(xdmp:get-request-field( "target", "Jesus Christ" ));

let $transitiveClosure := relate:getTransitiveClosure($subject, $target)
return
  <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
     
      {display:head("Realte")}
       
      <body xmlns="">
        <!-- Fixed navbar -->
         {display:nav("Explore")}

          <div class="container">

              <div class="row">
                  <div class="col-lg-4">
                      <form class="form-inline" method="get" action="{$core:siteRootURL}relate/">
                          <p class="input-group">
                              <div class="scrollable-dropdown-menu">
                                <input name="subject" value="{ $subject }" type="text" class="form-control typeahead"/>
                              </div>
                              <div class="scrollable-dropdown-menu">
                                <input name="target" value="{ $target }" type="text" class="form-control typeahead"/>
                              </div>
                          </p><!-- /input-group -->
                           <span class="input-group-btn">
                                  <button class="btn btn-default" type="submit">Relate</button>
                              </span>
                      </form>
                      <div class="container-fluid alert alert-info">
                      
                           <h4 class="list-group-item-heading">Getting started</h4>
                           <p class="list-group-item-text">In the input boxes above, enter a term in both boxes then click relate</p>
                        </div>
                       <div class="container-fluid alert alert-info">  
                           <h4 class="list-group-item-heading">Examples</h4>
                           <ul>
                            <li><a href="?subject=Atone&amp;target=Smith%2C+Joseph+Jr.">Atone, Smith, Joseph Jr.</a></li>
                            <li><a href="?subject=Wealth&amp;target=Joy">Wealth, Joy</a></li>
                            <li><a href="?subject=Worthy&amp;target=Inspiration">Inspiration, Worthy</a></li>
                            <li><a href="?subject=Atone&amp;target=Jesus+Christ">Atone, Jesus Christ</a></li>
                            <li><a href="?subject=Teach&amp;target=Love">Teach, Love</a></li>
                            <li><a href="?subject=Family&amp;target=Love">Family, Love</a></li>
                            <li><a href="?subject=God&amp;target=Marriage">God, Marriage</a></li>
                           </ul>
                      </div>
                     
                    
                  </div>
                  <div class="col-lg-8">
                      <div id="gte-relate-visualization" class="text-center" />
                      <h2>Paths</h2>
                      {
                       if (fn:empty($transitiveClosure))
                       then 
                        <p>No Path could be found. <i>{$subject}</i> and <i>{$target}</i> are not related</p>
                       else relate:getPaths($transitiveClosure)
                      }
                  </div>

             </div>
              
          </div> <!-- /container -->

    </body>
     {display:bottomIncludes()}
    <script type="text/javascript">
      GTE.relate = {{}};
      GTE.relate.subject = "{fn:lower-case($subject)}";
      GTE.relate.target = "{fn:lower-case($target)}";
      GTE.relate.dataset = {if (fn:empty($transitiveClosure)) then ("undefined")  else relate:getGrpah($transitiveClosure)}
    </script>
    <script type="text/javascript" src="{$core:cdnURL}js/d3/d3.v3.min.js"></script>
    
    <script type="text/javascript" src="{$core:cdnURL}js/relate.js"></script>
   
    
  </html>