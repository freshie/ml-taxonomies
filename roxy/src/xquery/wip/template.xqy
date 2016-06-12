import module namespace display = "org.lds.gte.core-display-functions" at "/core/display-functions.xqy";

declare option xdmp:output "method = html";

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    {display:head("Home")}

    <body xmlns="">

        {display:nav("Home")} 

        <div class="container">
            [some content here]
        </div> <!-- /container -->

    </body>
</html>