export var Pipeline = {
  start: function(){
    var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
    $( ".column" ).sortable({
      connectWith: ['.column', '.column_status'],
      handle: ".portlet-content",
      cancel: ".portlet-toggle",
      start: function (event, ui) {
        ui.item.addClass('tilt');
        //$("#opportunity_basket").css("visibility", "visible");
      },
      stop: function (event, ui) {
        ui.item.removeClass('tilt');
        //$("#opportunity_basket").css("visibility", "hidden");
      },
      receive: function (event, ui) {
        var id = $(ui.item).data("id");
        var column = ui.item.parent()[0];
        var stage = $(column).data("id");
        if (stage === "lost")
        {
          $(ui.item).remove();
          $.ajax({
            data: {opportunity : {status: 2}},
            type: 'PUT',
            url: '/api/v2/opportunity/'+ id
          });
        } else if (stage === "delete"){
          $(ui.item).remove();
          $.ajax({
            type: 'DELETE',
            headers: {"Authorization": "Bearer "+jwtToken},
            url: '/api/v2/opportunity/'+ id
          });
        } else if (stage === "win"){
          $(ui.item).remove();
          $.ajax({
            data: {opportunity : {status: 1}},
            type: 'PUT',
            headers: {"Authorization": "Bearer "+jwtToken},
            url: '/api/v2/opportunity/'+ id
          });
        }else{
          $.ajax({
            data: {opportunity : {board_column_id: stage}},
            type: 'PUT',
            headers: {"Authorization": "Bearer "+jwtToken},
            url: '/api/v2/opportunity/'+ id
          });
        }        
      }
    });

    $( ".portlet" )
      .addClass( "ui-widget ui-widget-content ui-helper-clearfix ui-corner-all" )
      .find( ".portlet-header" )
        .addClass( "ui-widget-header ui-corner-all" );
  }
};