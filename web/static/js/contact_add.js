$(function() {
  $('.referral-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);
    if($('#contact_first_name').val() !== ''){
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
          window.location.href = urlPrefix + '/contact';
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');
      alert('Name can\'t be blank');
    }
  });
});
