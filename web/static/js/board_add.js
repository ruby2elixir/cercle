$(function() {
  $('#board-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);
    if($('#contact_name').val() !== ''){
      $.ajax('/api/v2/board', {
        method: 'POST',
        headers: {'Authorization': 'Bearer '+jwtToken},
        data: new FormData(this),
        contentType: false,
        processData: false,
        success: function(result){
          var contactId = result.data.id;
          window.location = '/board/' + contactId;
        }
      });
    }else{
      $(this).find('input[type=submit]').removeAttr('disabled');
      alert('Name can\'t be blank');
    }
  });
});
