$(function() {
  $('.referral-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);
    if($('#contact_name').val() !== ''){
      var userId = $('#user_id').val();
      var companyId = $('#company_id').val();
      var boardColumn = $('#add_to_board').val();
      var urlPrefix = '/company/' + companyId;
      var url = '/api/v2' + urlPrefix + '/contact';
      $.ajax(url, {
        method: 'POST',
        data: new FormData(this),
        headers: {'Authorization': 'Bearer '+jwtToken},
        contentType: false,
        processData: false,
        success: function(result){
          var contactId = result.data.id;
          if ($('#add_to_card')[0].checked){
            var cardUrl = '/api/v2' + urlPrefix + '/card/';
            $.ajax(cardUrl , {
              method: 'POST',
              headers: {'Authorization': 'Bearer '+jwtToken},
              data: {
                'card[contact_ids]': [contactId],
                'card[user_id]': userId,
                'card[company_id]': companyId,
                'card[board_id]': boardColumn.split('--')[0],
                'card[board_column_id]': boardColumn.split('--')[1],
                'card[name]': ''
              },
              complete: function(xhr, status){
                window.location = urlPrefix + '/contact/' + contactId;
              }
            });
          }else{
            window.location = urlPrefix + '/contact/' + contactId;
          }
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');
      alert('Name can\'t be blank');
    }
  });
});
