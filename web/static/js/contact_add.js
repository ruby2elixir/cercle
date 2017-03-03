$(function() {

  $('#referral-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);

    if($("#contact_name").val() != ""){
      var user_id = $("#user_id").val();
      var company_id = $("#company_id").val();
      var board_column = $("#add_to_board").val();
      $.ajax('/api/v2/contact', {
        method: 'POST',
        data: new FormData(this),
        contentType: false,
        processData: false,
        success: function(result){
          var contact_id = result.data.id;
          if ($("#add_to_opportunity")[0].checked){
            var url = '/api/v2/opportunity/';
            $.ajax( url , {
              method: 'POST',
              data: { 
                'opportunity[main_contact_id]': contact_id ,
                'opportunity[contact_ids]': [contact_id],
                'opportunity[user_id]': user_id, 
                'opportunity[company_id]': company_id, 
                'opportunity[board_id]': board_column.split("--")[0],
                'opportunity[board_column_id]': board_column.split("--")[1],
                'opportunity[name]': '',  
              },
              complete: function(xhr, status){
                window.location = "/contact/" + contact_id;
              }
            });
          }else{
            window.location = "/contact/" + contact_id;
          }
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');  
      alert("Name can't be blank");
    }
    
  });
});




