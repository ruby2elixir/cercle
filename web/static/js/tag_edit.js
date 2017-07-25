$(function() {

  $('#tag-edit-table a.edit-link').click(function(e){
    console.log($(this).parent().parent().find('textarea'));
    $(this).parent().parent().find('.textarea-inline-editable').focus();
  });

  $('#tag-edit-table a.delete-link').click(function(e){
    e.preventDefault();
    var result = confirm('Want to delete?');
    if (result) {
      var element = $(this);
      var url = '/api/v2/tag/' + $(this).data('id');
      $.ajax(url, {
        method: 'DELETE',
        headers: { 'Authorization': 'Bearer ' + jwtToken },
        complete: function complete(xhr, status) {
          element.parent().parent().remove();
        }
      });
    }
  });
});
