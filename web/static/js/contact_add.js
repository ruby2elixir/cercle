$(function() {

  $('.referred-by-no').click(function(){
    $('.referred-by-selection .active').removeClass('active');
    $(this).addClass('active');
    $('.referred-by-form-body').hide();
    $('.referred-by-form-body input[type=text]').val('');
  }).trigger('click');

  $('.referred-by-yes').click(function(){
    $('.referred-by-selection .active').removeClass('active');
    $(this).addClass('active');
    $('.referred-by-form-body').show();
  });
  

  $('#referral-form').submit(function(e){
    e.preventDefault();
    $(this).find('input[type=submit]').attr('disabled', true);


    $.ajax('/api/v2/contact', {
      method: 'POST',
      data: new FormData(this),
      processData: false,
      contentType: false,
      complete: function(xhr, status){
        $(this).find('input[type=submit]').removeAttr('disabled');
        console.log([xhr, status]);

        if(xhr.responseJSON.data && xhr.responseJSON.data.id) {
          var contact_id = xhr.responseJSON.data.id;
          window.location = "/contacts/" + contact_id;
        } else {
          if(xhr.responseJSON.errors) {
            messages = [];
            $.each(xhr.responseJSON.errors, function(index, value) {
              $.each(value, function(i, m){
                messages.push(index + ' ' + m);
              });
            });
            alert(messages.join("\n"));
          } else {
            if(xhr.responseJSON.message) {
              alert(xhr.responseJSON.message);
            } else {
              alert('Error occured');
            }
          }
        }
      }
    });
  });
});




