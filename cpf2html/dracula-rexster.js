//Show UCLA CS class dependencies (not complete)
$(document).ready(function() {
    var rexsterAPI = "/rex/";
    var width = $(document).width();
    var height = $(document).height();
    var g = new Graph();
    g.edgeFactory.template.style.directed = true;

    indicesUrl = rexsterAPI + 'snac/indices/name-idx?key=identity&value=';
    // identity = "Sierra Club."
    // identity = "Eisenhower, Dwight D. (Dwight David), 1890-1969."

    // look up node id
    var nodeId;

    // IE 8 http://www.graphdracula.net/showcase/#comment-357
    if (!Array.prototype.forEach) {
      Array.prototype.forEach = function(fun /*, thisp*/) {
        var len = this.length;
        if (typeof fun != "function") {
          throw new TypeError();
        }
 
        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
          if (i in this) {
            fun.call(thisp, this[i], i, this);
          }
        }
      };
    }

    
    $.ajax({
      url: indicesUrl + encodeURIComponent(identity), 
      async: false,
      dataType: "json",
      success: function (data) {
        if (data.results[0]) {
          nodeId = data.results[0]._id;
        }
      }
    });

    var edges = [];
    if (nodeId) {
      $.ajax({
        url: rexsterAPI + "snac/vertices/" + nodeId + '/bothE?rexster.offset.start=0&rexster.offset.end=100',
        async: false,
        dataType: "json",
        success: function (data) {
          arr = data.results // loop through rexster results array
          for(var i=0,len=arr.length; value=arr[i], i<len; i++) {
            // g.addEdge(value.from_name, value.to_name, { arcrole: value._label })
            edges.push( [ value.from_name, value.to_name, value._label ] );
          }
        }
      });
      if (edges.length > 0) { 
        for(var i=0,len=edges.length; value=edges[i], i<len; i++) {
          // var offset = (identity == edges[i][0]) ? "         " : "";
          g.addEdge( edges[i][0], edges[i][1], { label: edges[i][2]});
        }
      } else {
        g.addEdge( "no results", identity, { label: "so sorry" })
      }
    } else {
      // g.addNode(identity);
      g.addEdge( identity, "index error", { label: "so sorry" })
    }
      
    // var layouter = new Graph.Layout.Ordered(g, topological_sort(g));

    /* layout the graph using the Spring layout implementation */
    var layouter = new Graph.Layout.Spring(g);
    layouter.layout();
    var renderer = new Graph.Renderer.Raphael('canvas', g, width, height);
    renderer.draw();
    $('#canvas img').hide();
});
