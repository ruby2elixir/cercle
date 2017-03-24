let ContactLive = {
  init(socket, contactId){
    // connect to the socket
    socket.connect();
   
   // Now that you are connected, you can join channels with a topic:
    let channel = socket.channel('contacts:' + contactId, {});
   
    let tasks = $('#tasks');  
    let timelineEvents = $('#timeline_events');   
   
    channel.on('new:activity', payload => {
      tasks.append(payload.html);
      this.activitiesInit();
    });

    channel.on('new:timeline_event', payload => {
      timelineEvents.prepend(payload.html);
    });
   
    channel.join()
     .receive('ok', resp => {  console.log('Join OK', resp);this.activitiesInit(); })
     .receive('error', resp => { console.log('Unable to join', resp); });
  },

  activitiesInit() {
    var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
    
    $('.activity_delete').click(function(){
      var taskId = $(this).data('id');
      var url = '/api/v2/activity/' + taskId;
      $.ajax( url , {
        method: 'DELETE',
        headers: {'Authorization': 'Bearer '+jwtToken},
        complete: function(xhr, status){
          $('#row_task_'+taskId).remove();
          $(this).empty();
          return true;
        }
      });
    });

    $('.activity_title').on('change', function(){
      var newTitle = $(this).val();
      var url = '/api/v2/activity/' + $(this).data('id');
      $.ajax( url , {
        method: 'PUT',
        headers: {'Authorization': 'Bearer '+jwtToken},
        data: { 'activity[title]': newTitle },
        complete: function(xhr, status){
          return true;
        }
      });
    });

    $('.activity_user_id').on('change', function(){
      var userId = $(this).val();
      var url = '/api/v2/activity/' + $(this).data('id');
      $.ajax( url , {
        method: 'PUT',
        headers: {'Authorization': 'Bearer '+jwtToken},
        data: { 'activity[user_id]': userId },
        complete: function(xhr, status){
          return true;
        }
      });
    });

    $('.datepicker').on('change', function(){
      try {
        var taskDateItem = $('#task_date_'+ $(this).data('id'));
        var taskHourItem = $('#task_hour_'+ $(this).data('id'));
  
        var newYear = taskDateItem.val().split('/')[2];
        var newMonth = taskDateItem.val().split('/')[0];
        var newDay = taskDateItem.val().split('/')[1];
  
        var hour = taskHourItem.val().split(':')[0];
        var minute = taskHourItem.val().split(':')[1];
  
        var newDateString =  newYear +'-'+ newMonth+ '-'+ newDay+'T'+hour +':'+ minute +':00Z';
        var newDate = new Date( newDateString);
      
        var newDateToSend = newDate.toISOString();
        
        var url = '/api/v2/activity/' + $(this).data('id');
        $.ajax( url , {
          method: 'PUT',
          headers: {'Authorization': 'Bearer '+jwtToken},
          data: { 'activity[due_date]': newDate.toISOString() },
          complete: function(xhr, status){
            return true;
          }
        });
      }
      catch(err) {
        taskDateItem.val(taskDateItem.data('default'));
        taskHourItem.val(taskHourItem.data('default'));
      }
    });

    //// SAME CODE 
    $('.timepicker').on('change', function(){
      try {
        var taskDateItem = $('#task_date_'+ $(this).data('id'));
        var taskHourItem = $('#task_hour_'+ $(this).data('id'));
  
        var newYear = taskDateItem.val().split('/')[2];
        var newMonth = taskDateItem.val().split('/')[0];
        var newDay = taskDateItem.val().split('/')[1];
  
        var hour = taskHourItem.val().split(':')[0];
        var minute = taskHourItem.val().split(':')[1];
        var newDateString =  newYear +'-'+ newMonth+ '-'+ newDay+' '+hour +':'+ minute;
        var newDate = new Date(newDateString); 
        var newDateToSend = newDate.toISOString();
        
        var url = '/api/v2/activity/' + $(this).data('id');
        $.ajax( url , {
          method: 'PUT',
          headers: {'Authorization': 'Bearer '+jwtToken},
          data: { 'activity[due_date]': newDate.toISOString() },
          complete: function(xhr, status){
            return true;
          }
        });
      }
      catch(err) {
        taskDateItem.val(taskDateItem.data('default'));
        taskHourItem.val(taskHourItem.data('default'));
      }
    });
    
    $('.datepicker').datepicker();
  
    $('.activity_toggle').iCheck({
      checkboxClass: 'icheckbox_square-blue',
      radioClass: 'iradio_square-blue',
      increaseArea: '20%' // optional
    });

    $('.activity_toggle').on('ifToggled', function(event){
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

export default ContactLive;