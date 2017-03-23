export var BoardColumnPipeline = {
  start: function(){
    $( '#board_columns' ).sortable({
      cursor: 'move',
      start: function (event, ui) {
        ui.item.addClass('tilt');
      },
      stop: function (event, ui) {
        ui.item.removeClass('tilt');
      }
    });
  }
};