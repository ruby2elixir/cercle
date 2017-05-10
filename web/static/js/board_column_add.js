import { Pipeline } from './opportunity_pipeline';

$(function() {
  var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
  $(document).on('submit','#new_board_column_form',function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);
    if($('#board_column_name').val() !== ''){
      $.ajax('/api/v2/board_column', {
        method: 'POST',
        headers: {'Authorization': 'Bearer '+jwtToken},
        data: new FormData(this),
        contentType: false,
        processData: false,
        success: function(result){
          var boardColumnId = result.data.id;
          var boardColumnName = result.data.name;
          var newBoardColumn = '<div class="column_master" style="width: 250px;display:inline-block;vertical-align:top;margin-left:30px;background-color:#e0e0e0;border-radius:5px;white-space:normal;"><div class="column_title" style="position:relative;"><form class="form-inline editableform"><textarea class="textarea-inline-editable" data-type="PUT" data-param-name="board_column[name]" data-inline-editurl="/api/v2/board_column/'+boardColumnId+'"' + ' style="font-weight:800;font-size:16px;border:0px solid grey;resize: none;background-color:#d0d0d0;border-radius:3px;overflow: hidden;word-wrap: break-word;height: 54px;width: 202px;padding:3px;">'+ boardColumnName +'</textarea></form><div id="actions" style="position: absolute;right: 4px;top: 4px;width:18px;height:18px;color:grey;font-size:12px;"><span class="fa fa-ellipsis-h" role="button" data-id="' + boardColumnId + '"' + ' type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"></span><ul class="dropdown-menu" aria-labelledby="dLabel"><li><a class="delete-column-link">Delete This Column..</a></li></ul></div></div><br/><div class="column" data-id="'+ boardColumnId +'"></div>';
          Pipeline.stop();
          $('.column_master').last().before(newBoardColumn);
          $('#new_board_column_form').find('input[type=submit]').attr('disabled', false);
          $('#new_board_column_form')[0].reset();
          Pipeline.start();
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');  
      alert('Name can\'t be blank');
    }
  });

  $(document).on('click', '#actions a.delete-column-link', function(){
    if($(this).parents('div.column_title').siblings('div.column').children().length > 0){
      alert('Column has cards so can\'t be deleted');
    }
    else{
      var element = $(this);
      var url = '/api/v2/board_column/' + $(this).parent().parent().prev().data('id');
      $.ajax(url, {
        method: 'DELETE',
        headers: { 'Authorization': 'Bearer ' + jwtToken },
        complete: function complete(xhr, status) {
          element.parents('div.column_master').remove();
        }
      });
    }
  });
});
