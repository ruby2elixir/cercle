export var Activity = {
  start: function(){
    var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
    $('.activity_page_toggle').iCheck({
      checkboxClass: 'icheckbox_square-blue',
      radioClass: 'iradio_square-blue',
      increaseArea: '20%' // optional
    });
  
    $('.activity_page_toggle').on('ifToggled', function(event){
      var url = '/api/v2/activity/' + $(this).data('id');
      var that = $(this);
      $.ajax( url , {
        method: 'PUT',
        headers: {'Authorization': 'Bearer '+jwtToken},
        data: { 'activity[is_done]': $(this).is(':checked') },
        complete: function(xhr, status){
          if(that.is(':checked')){
            $('#row_task_'+that.data('id')).remove();
          }
          return true;
        }
      });
    });
  }
};