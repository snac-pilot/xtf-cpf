/* javascript for the search page only */
/*jslint indent:2, nomen: false */
/*global $ window _gaq */
/* http://agyuku.net/2009/05/back-to-top-link-using-jquery/ */
$(function () {        
  $(window).scroll(function () {  
    var f = $(this).scrollTop();
    if ($(this).scrollTop() > 2500) {         
      $('.return-top').fadeIn();
    } else {
      $('.return-top').fadeOut();
    }
  });
  $('.return-top').click(function () {
    $('body,html').animate({
      scrollTop: 0
    },
    800);
    _gaq.push(['snak._trackEvent', 'OnPage', 'BackToTop', window.title ]);
    return false;
  });
  // other GA event tracker
  $("li.more").click(function () {
    _gaq.push(['snak._trackEvent', 'OnPage', 'More Browse ' + this.parentNode.getAttribute("class"), window.title ]);
  });
  $("div.more").click(function () {
    _gaq.push(['snak._trackEvent', 'OnPage', 'More Results', window.title ]);
  });



  var grid;
  var loader = new Slick.Data.RemoteModel();

  var storyTitleFormatter = function (row, cell, value, columnDef, dataContext) {
    s ="<b><a href='" + dataContext["path"].replace('default:', '/xtf/view?docId=') + "'>" +
              dataContext["identity"] + "</a></b>";
    return s;
  };

  var browseFormatter = function (row, cell, value, columnDef, dataContext) {
    s = '';
    if (dataContext['selected']) {
      s = dataContext['value']; 
    } else {
      s = "<b><a href='" + dataContext['selectLink'] + "'>" + 
              dataContext['value'] + "</a></b>";
    }
    return s;
  };

  var index1 = function (row, cell, value, columnDef, dataContext) {
    s = dataContext['index'] + 1;
    return s;
  };

  /* var dateFormatter = function (row, cell, value, columnDef, dataContext) {
    return (value.getMonth()+1) + "/" + value.getDate() + "/" + value.getFullYear();
  }; */
  var columns;

  function get(n){
      var half = location.search.split(n+'=')[1];
      return half? decodeURIComponent(half.split('&')[0]):null;
  }
  var browseJson = get('browse-json');

  if (!browseJson) {
    columns = [
      {id: "num", name: "#", formatter: index1, width: 50},
      {id: "identity", name: "identity", width: 300, formatter: storyTitleFormatter},
      {id: "facet-entityType", name: "type", field: "facet-entityType", width: 100},
      {id: "fromDate", name: "from", field:"fromDate" , width: 100},
      {id: "toDate", name: "to", field:"toDate", width: 100},
      {id: "facet-recordLevel", name: "level", field: "facet-recordLevel", width: 100}
    ];
  } else {
    columns = [
      {id: "value", name: browseJson, field:"value", formatter: browseFormatter, width: 450, sortable: true, resizable: true},
      {id: "totalDocs", name: "totalDoc", field: "totalDocs", width: 100, sortable: true, resizable: true}
    ];
  }

  var options = {
    // rowHeight: 64,
    editable: false,
    enableAddRow: false,
    enableColumnReorder: false,
    forceFitColumns: true,
    enableCellNavigation: false
  };

  var loadingIndicator = null;


  $(function () {
    dataView = new Slick.Data.DataView({ inlineFilters: true });
    grid = new Slick.Grid("#myGrid", loader.data, columns, options);
    var pager = new Slick.Controls.Pager(dataView, grid, $("#pager"));

    grid.onViewportChanged.subscribe(function (e, args) {
      var vp = grid.getViewport();
      loader.ensureData(vp.top, vp.bottom);
    });

    grid.onSort.subscribe(function (e, args) {
console.log("hey");
      loader.setSort(args.sortCol.field, args.sortAsc ? 1 : -1);
      var vp = grid.getViewport();
      loader.ensureData(vp.top, vp.bottom);
    });

    loader.onDataLoading.subscribe(function () {
      if (!loadingIndicator) {
        loadingIndicator = $("<span class='loading-indicator'><label>Buffering...</label></span>").appendTo(document.body);
        var $g = $("#myGrid");

        loadingIndicator
            .css("position", "absolute")
            .css("top", $g.position().top + $g.height() / 2 - loadingIndicator.height() / 2)
            .css("left", $g.position().left + $g.width() / 2 - loadingIndicator.width() / 2);
      }

      loadingIndicator.show();
    });

    loader.onDataLoaded.subscribe(function (e, args) {
      for (var i = args.from; i <= args.to; i++) {
        grid.invalidateRow(i);
      }

      grid.updateRowCount();
      grid.render();

      loadingIndicator.fadeOut();
    });

    $("#txtSearch").keyup(function (e) {
      if (e.which == 13) {
        loader.setSearch($(this).val());
        var vp = grid.getViewport();
        loader.ensureData(vp.top, vp.bottom);
      }
    });

    // loader.setSearch($("#txtSearch").val());
    loader.setSort("totalDocs", 1);
    // grid.setSortColumn("value", false);

    // load the first page
    grid.onViewportChanged.notify();
  })




});
