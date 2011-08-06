var labelType, useGradients, nativeTextSupport, animate;

// this is a modified version of an example file that came with Nicolas Garcia Belmonte's
// JavaScript InfoVis Toolkit http://thejit.org/downloads/Jit-2.0.0b.zip
// http://thejit.org/static/v20/Jit/Examples/RGraph/example1.js
// http://thejit.org/static/v20/Jit/Examples/RGraph/example1.html

// JSON is created with this rexster-extesion written in gremlin
// http://code.google.com/p/eac-graph-load/source/browse/rexster-extension/src/main/groovy/org/cdlib/snac/kibbles/TheJit.groovy

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport 
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

function log(a) {console.log&&console.log(a);}

function init(){
    // snac: look up node id
    var nodeId;
    $.ajax({
      url: "/rex/snac/indices/name-idx?key=identity&value=" + encodeURIComponent(identity),
      async: false,
      dataType: "json",
      success: function (data) {
        if (data.results[0]) {
          nodeId = data.results[0]._id;
        }
      }
    });
    
    //init RGraph
    var rgraph = new $jit.RGraph({
        //Where to append the visualization
        injectInto: 'infovis',
        //Optional: create a background canvas that plots
        //concentric circles.
        background: {
          CanvasStyles: {
            strokeStyle: '#555'
          }
        },
        //Add navigation capabilities:
        //zooming by scrolling and panning.
        Navigation: {
          enable: true,
          panning: true,
          zooming: 20 
        },
        //Set Node and Edge styles.
        Node: {
            color: '#ddeeff', type: 'none'
        },
        
        Edge: {
          color: '#C17878',
          lineWidth:0.25
        },

        
        onBeforeCompute: function(node){
            var t = new Date();
            // snac: load in the graph for the new center node
            $.ajax({
                url: "/rex/snac/vertices/" + node.id + "/snac/theJit",
                success: function(json){
                    // add the new json graph to the displayed graph
                    rgraph.op.sum(json, {type: 'nothing', id: node.id });
                    // this trims nodes that are far away from where we are now centered
                    // should I do this before summing the new graph in, what if a node is at both
                    // depth 1 and depth 4?
                    node.eachLevel(4,5, function(deep) { 
                        // this setTimeout should give control back to the browser after each node delete
                        // the idea is to try to prevent UI lockups and "unresponsive script" dialogs
                        setTimeout(function() {
                            rgraph.graph.removeNode(deep.id);
                            rgraph.labels.clearLabels();
                        }, 0); 
                    });
                    rgraph.refresh(true);
                    rgraph.compute('end');
 
                }
            });
        },
        
        //Add the name of the node in the correponding label
        //and a click handler to move the graph.
        //This method is called once, on label creation.
        onCreateLabel: function(domElement, node){
            domElement.innerHTML = node.name;
            domElement.onclick = function(){
                rgraph.onClick(node.id, {
                    onComplete: function() {
                    }
                });
            };
            // snac: change the label appearance on mouse over
            domElement.onmouseover = function(){
                domElement.style.color="#000";
                domElement.style.border="1px solid";
                domElement.style.zIndex=5;
                domElement.style.backgroundColor="#fff";
                domElement.style.paddingLeft="0.1em";
                //add some function to highlight all the edges that touch this node
                //log(node.id);
            };
            // snac: change the appearance back on mouse out
            domElement.onmouseout = function(){
                domElement.style.color="#ccc";
                domElement.style.border="0";
                domElement.style.zIndex=0;
                domElement.style.backgroundColor="transparent";
            };
        },
        //Change some label dom properties.
        //This method is called each time a label is plotted.
        onPlaceLabel: function(domElement, node){

            var style = domElement.style;
            style.display = '';
            style.cursor = 'pointer';

            if (node._depth <= 1) {
                style.fontSize = "0.8em";
                style.color = "#ccc";
            
            } else if(node._depth == 2){
                style.fontSize = "0.7em";
                style.color = "#ccc";
            
            } else {
                style.fontSize = "0.6em";
                style.color = "#ccc";
            }

            var left = parseInt(style.left);
            var w = domElement.offsetWidth;
            style.left = (left - w / 2) + 'px';
        }
    });

    // snac; load in the graph for the original center node
    $.ajax({
        url: "/rex/snac/vertices/"+ nodeId +"/snac/theJit",
        success: function(json){
            //load JSON data
            rgraph.loadJSON(json);
            //trigger small animation
            rgraph.graph.eachNode(function(n) {
              var pos = n.getPos();
              pos.setc(-200, -200);
            });
            rgraph.compute('end');
            rgraph.fx.animate({
              modes:['polar'],
              duration: 2000
            });
        }
    });

    //end
    //append information about the root relations in the right column
    // $jit.id('inner-details').innerHTML = rgraph.graph.getNode(rgraph.root).data.relation;
}
