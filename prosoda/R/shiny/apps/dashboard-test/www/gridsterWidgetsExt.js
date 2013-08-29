$(function(){ //document ready

 // Initialize any divs with class gridster
  $(".gridster ul").each(function() {
    $el = $(this);

    var marginx = Number(this.getAttribute('data-marginx')) || 10;
    var marginy = Number(this.getAttribute('data-marginy')) || 10;
    var width   = Number(this.getAttribute('data-width'))   || 140;
    var height  = Number(this.getAttribute('data-height'))  || 140;

    $(this).gridster({
      widget_margins: [marginx, marginy],
      widget_base_dimensions: [width, height],
      serialize_params: 
        function($w, wgd) { 
          return {  col: wgd.col, row: wgd.row, 
                    size_x: wgd.size_x, size_y: wgd.size_y, 
                    id: $w.children(".shiny-html-output").attr("id") } }
    });
  });

// kann man eventuell zusammenfassen:


$(".gridsterAction").on("click", function(evt) {
  evt.preventDefault();
  var el = $(evt.target);
  var gaction = el.attr("gridster-action");
  var toel = $(".gridsterButton");
  switch( gaction ) {
    case "saveconfig":
      toel.attr("gridster-action",el.attr("gridster-action"));
      toel.parent().removeClass("open");
      toel.trigger("change");
      break;
    case "deletemode":
      $(".icon-remove-sign").removeClass("hidden");
      el.attr("gridster-action","canceldelete");
      el.html("Delete OFF");
      toel.attr("style","box-shadow: 1px 1px 10px #F00;");
      toel.parent().removeClass("open");
      break;
    case "canceldelete":
      $(".icon-remove-sign").addClass("hidden");
      el.attr("gridster-action","deletemode");
      el.html("Delete ON");
      toel.removeAttr("style");
      toel.parent().removeClass("open");
      break;
  }
});

//$(document).on("click", "i.gridsterAction", function(evt) {

  // evt.target is the button that was clicked
//  var el = $(evt.target);

  // Raise an event to signal that the value changed
  // TODO: But only if not deactivated "gridster-action"=none
//  el.trigger("change");
//});


var gridsterButtonBinding = new Shiny.InputBinding();
$.extend(gridsterButtonBinding, {
  find: function(scope) {
    return $(scope).find(".gridsterButton");
  },
  getValue: function(el) {
    var gaction = $(el).attr("gridster-action");
    switch( gaction ) {
    case "saveconfig":
      var gridster = $(".gridster ul").gridster().data('gridster');
      var widgetsconfig = gridster.serialize(); //TODO
      return JSON.stringify(widgetsconfig);
      break;
    case "deletemode":
      
      //TODO: display delete handle on each gridsteritem and bind this to an 
      // action="deleteitem". Also get hte gridster button, color it red by setting the
      // button's class=gidsterAction ans "gridster-action"="canceldelete""
      break;
    case "deleteitem":
      //TODO: if deltemode is active, then delete that item and cancel deletemode for other items
      // also netralize the gridster button (remove class "gridsterAction" and 
      // remove attribute "gridster-action")
      break;
    case "canceldelete":
      // TODO: cancel deletemode for all items and neutralize gridster button
      //return parseInt($(el).text());
      break;
    }
  },
  setValue: function(el, value) {
    $(el).text(value); // TODO
  },
  subscribe: function(el, callback) {
    $(el).on("change.gridsterButtonBinding", function(e) {
      callback();
    });
  },
  unsubscribe: function(el) {
    $(el).off(".gridsterButtonBinding");
  }
});

Shiny.inputBindings.register(gridsterButtonBinding);


});