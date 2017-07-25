$(function() {
  $('.referral-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);
    if($('#contact_name').val() !== ''){
      var user_id = $('#user_id').val();
      var company_id = $('#company_id').val();
      var board_column = $('#add_to_board').val();
      $.ajax('/api/v2/contact', {
        method: 'POST',
        data: new FormData(this),
        headers: {'Authorization': 'Bearer '+jwtToken},
        contentType: false,
        processData: false,
        success: function(result){
          var contact_id = result.data.id;
          if ($('#add_to_card')[0].checked){
            var url = '/api/v2/card/';
            $.ajax( url , {
              method: 'POST',
              headers: {'Authorization': 'Bearer '+jwtToken},
              data: {
                'card[contact_ids]': [contact_id],
                'card[user_id]': user_id,
                'card[company_id]': company_id,
                'card[board_id]': board_column.split('--')[0],
                'card[board_column_id]': board_column.split('--')[1],
                'card[name]': ''
              },
              complete: function(xhr, status){
                window.location = '/contact/' + contact_id;
              }
            });
          }else{
            window.location = '/contact/' + contact_id;
          }
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');
      alert('Name can\'t be blank');
    }
  });
});
