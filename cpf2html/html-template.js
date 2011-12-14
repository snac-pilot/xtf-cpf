$(function() {
/*
    var link = $( '<div>Alternative forms of name</div>' ).click(function() { 
      $( "div.extra-names" ).dialog('open');
    });
    link.insertBefore("div.extra-names");
*/
    $( '<a href="##" title="open in panel" style="cursor: pointer;">⇢ Alternative forms of name</a>' ).insertBefore("div.extra-names").click(function(e) { 
      $( "div.extra-names" ).dialog('open');
    });

    $( "div.extra-names" ).dialog({ 
        autoOpen: false,
        width: 400,
        position: 'top'
        });
    $( "div.relations > div" ).accordion({
        autoHeight: false
        });
    $( "div.relations > div > div:has(ul)" ).tabs();
});
