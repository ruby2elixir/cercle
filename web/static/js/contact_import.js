$(function() {
  /*global someFunction jsonData:true*/
  /*global someFunction uploadType:true*/

  var tempFile='';
  var fileName='';
  var xhr;

  var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
  $('#fileupload').fileupload({
    dataType: 'json',
     headers: {
         'Authorization': 'Bearer '+jwtToken,
         'x-csrf-token': window.csrfToken
     },
     add: function (e, data) {
      fileName = data.files[0].name;
      var fileSize = (data.files[0].size/1000).toFixed(1);
      $('#list-uploaded-file').find('table tbody tr td')[0].innerHTML = fileName;
      $('#list-uploaded-file').find('table tbody tr td')[1].innerHTML = fileSize + 'kB';
      $('#list-uploaded-file').find('table tbody tr td')[2].innerHTML = data.files[0].type;
      $('#list-uploaded-file').find('table tbody tr td')[3].innerHTML = data.files[0].lastModifiedDate;
      var fileType = data.files[0].name.split('.').pop(), allowdtypes = 'csv,xls,xlsx';
      if (allowdtypes.indexOf(fileType) < 0) {
        $('.upload-dashed-box').css('border', '2px dashed red');
        if(!$('.errors').length){
          $('.upload-info-box').prepend('<p class="errors">The uploaded file is in the wrong format..</p>');
          if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden');
        }
        return false;
      }
      else{
        if($('.errors').length){
          $('.errors').remove();
          $('.upload-dashed-box').css('border', '2px dashed #c2c8cd');
        }
        if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden');
        $('#move-to-step2').removeClass('disabled');
        $('#move-to-step2').on('click', function (ev) {
          ev.preventDefault();
          $(this).addClass('disabled');
          $('#uploaded-file-name').html('<span>Uploading </span><span class="filename">'+ fileName+'</span>');
          xhr = data.submit();
        });
      }
    },
    success: function(result){
      if (result.error){
        return false;
      }
      else if(result.error_message && result.error_message.length){
        $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">'+result.error_message+'</p>');
      }
      else{
        if (!$('#left-section-table tr').length) prepareFileTable('left-section-table', result.headers,result.first_row, result.top_five_rows);
        if (!$('#contact-field-table tr').length) prepareDbTable('contact-field-table', result.contact_fields);
        if (!$('#organization-field-table tr').length) prepareDbTable('organization-field-table', result.organization_fields);
        if (result) tempFile = result.temp_file;
      }
    },
    progress: function (e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('.progress .progress-bar').css('width',progress + '%');
    },
    done: function (e, data) {

      if (data.result.error && data.result.error.length){
        $('.upload-dashed-box').css('border', '2px dashed red');
        $('.upload-info-box').prepend('<p class="errors"> The errors in import are:-'+data.result.error+'</p>');
        if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden');
        $('#progress .progress-bar').toggleClass('hidden');
        $('#uploaded-file-name').html('');
        return false;
      }
      else if(data.result.error_message && data.result.error_message.length) {
        window.location = '/import';
      }
      else{
        $('#progress .progress-bar').toggleClass('hidden');
        $('#sec-1,#sec-2').toggleClass('hidden');
        $('#action-btns-step1,#action-btns-step2').toggleClass('hidden');
        $('#step1').addClass('completed').append('<i class="fa fa-check-circle" style="float:right; margin-top:3px;" aria-hidden="true"></i>');
        $('#step2').removeClass('steps-li-inactive').addClass('steps-li-active active');
      }
    }
  });

  $('#myTabs a[href="#contact"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

  $('#myTabs a[href="#organization"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

  $('.cancel-import').click(function (e) {
    xhr.abort();
  });

  $('#back-to-step1').click(function (e) {
    $('#progress .progress-bar').toggleClass('hidden');
    $('#sec-1,#sec-2').toggleClass('hidden');
    $('#move-to-step2').removeClass('disabled');
    $('#action-btns-step1,#action-btns-step2').toggleClass('hidden');
    $('#step2').removeClass('steps-li-active active').addClass('steps-li-inactive');
    $('#step1').removeClass('completed');
    $('#step1').children(':last-child').remove();
    $('#uploaded-file-name span').first().text('Uploaded ');
  });

  $('#back-to-step2').click(function (e) {
    $('#sec-2,#sec-3').toggleClass('hidden');
    $('#action-btns-step2,#action-btns-step3').toggleClass('hidden');
    $('#step3').removeClass('steps-li-active active').addClass('steps-li-inactive');
    $('#step2').removeClass('completed');
    $('#step2').children(':last-child').remove();
    $('#move-to-step3').text('Next').removeClass('disabled');
  });

  $('#move-to-step3').on('click', function (e) {
    e.preventDefault();
    if ((jsonData['contact']['full_name'] || jsonData['contact']['first_name'] && jsonData['contact']['last_name']) && jsonData['organization']['name']){
      $(this).text('Processing..').addClass('disabled');
      $.ajax({
        url: '/view_uploaded_data',
        type: 'POST',
        dataType: 'json',
        headers: {
            'Authorization': 'Bearer '+jwtToken,
            'x-csrf-token': window.csrfToken
        },
        async: true,
        data: {
          'mapping': jsonData,
          'temp_file': tempFile
        },
        error: function(error) {
          $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">Some error occured, Please try again.</p>');
          $('#move-to-step3').text('Next').removeClass('disabled');
          fadeFlash();
        },
        success: function(data) {
          $('#sec-2').toggleClass('hidden');
          $('#action-btns-step2,#action-btns-step3').toggleClass('hidden');
          $('#step2').addClass('completed').append('<i class="fa fa-check-circle" style="float:right; margin-top: 3px;" aria-hidden="true"></i>');
          $('#sec-3').toggleClass('hidden');
          $('#step3').removeClass('steps-li-inactive').addClass('steps-li-active active');
          $('#move-to-step3').text('Next').removeClass('disabled');
          var contactHeaders = data.contact_headers;
          var organizationHeaders = data.organization_headers;
          var contactValues = data.contact_values;
          var organizationValues = data.organization_values;
          tempFile = data.temp_file;
          preparePreviewDataTable('preview-data-table',contactHeaders, organizationHeaders, contactValues, organizationValues);
        }
      });
    }
    else{
      $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">Organization and Contact mapping is incomplete</p>');
      fadeFlash();
    }
  });

  $('#move-to-final').click(function(e){
    e.preventDefault();
    $(this).text('Importing..').addClass('disabled');
    $('#final-progress .progress-bar').toggleClass('hidden');
    if(uploadType){
      // contact-import
      $.ajax({
        url: '/create_nested_data',
        method: 'POST',
        headers: {
            'Authorization': 'Bearer '+jwtToken,
            'x-csrf-token': window.csrfToken
        },
        data: {
          'mapping': jsonData,
          'temp_file': tempFile
        },
        success: function(result){
          $('#final-progress .progress-bar').toggleClass('hidden');
          $('.content-wrapper .container').prepend('<p class="alert alert-success" role="alert" style="border-radius:0px;">'+result.message+'</p>');
          $('#move-to-final').text('Finished').addClass('disabled');
          window.location = '/contact';
        },
        error: function(error) {
          $('#final-progress .progress-bar').toggleClass('hidden');
          $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">Some error occured, Please try again.</p>');
          $('#move-to-final').text('Next').removeClass('disabled');
          fadeFlash();
        }
      });
    }
  });

  $('body').on('click','.revert',function(){
    if($(this).parent().hasClass('contact-fields')){
      console.log(jsonData['contact'][$(this).parent().text()]);
      delete jsonData['contact'][$(this).parent().text()];
    }
    else{
      delete jsonData['organization'][$(this).parent().text()];
    }
    $(this).parent().addClass('info drop-fields').removeClass('active contact-fields');
    $(this).parent().html('Drag and drop field here');

  });
});

function prepareFileTable(tableName,headers,firstRow,topFiveRows) {
  console.log(topFiveRows);
  var tbl = document.getElementById(tableName);
  for (var i = 0; i < headers.length; i++){
    var tooltipValues = [];
    var row = tbl.insertRow(tbl.rows.length);
    for(var r = 0; r < topFiveRows.length; r++) {
      tooltipValues.push(topFiveRows[r][i]);
    }
    for (var j = 0; j < 2; j++) {
      if(j===0){
        var x = row.insertCell(j);
        x.setAttribute('data-original-title',tooltipValues.toString().replace(/,/g, '\n'));
        x.setAttribute('data-container','body');
        x.setAttribute('data-toggle','tooltip');
        x.setAttribute('data-placement','top');
        x.innerHTML = '<div class="csv-col"><b>'+headers[i]+'</b></div><div class="csv-data">'+firstRow[i]+'</div>';
        x.className = 'active csv-fields';
      }
      else{
        var x = row.insertCell(j);
        x.innerHTML = 'Drag and drop field here';
        x.className = 'info drop-fields';
        x.id = 'map'+i;
        x.setAttribute('ondrop','drop(event)');
        x.setAttribute('ondragover','allowDrop(event)');
        x.setAttribute('ondragstart','drag(event)');
      }
    }
  }
}

function prepareDbTable(tableName,fields) {
  if (tableName === 'contact-field-table') {
    var iconType = 'fa fa-user';
    var className = 'contact-fields';
    var id =  'contact-drag';
  }
  else{
    var iconType = 'fa fa-building';
    var className = 'organization-fields';
    var id = 'organization-drag';
  }
  var tbl = document.getElementById(tableName);
  for (var i = 0; i < fields.length; i++){
    var row = tbl.insertRow(tbl.rows.length);
    var x = row.insertCell(0);
    x.innerHTML = '<i class="'+iconType +'" aria-hidden="true"></i><span class="db-field">'+ fields[i]+ '</span>';
    x.className = 'active '+ className;
    x.id = id+i;
    x.draggable = true;
    x.setAttribute('ondrop','drop(event)');
    x.setAttribute('ondragover','allowDrop(event)');
    x.setAttribute('ondragstart','drag(event)');
  }
}

function preparePreviewDataTable(tableName,contactHeaders, organizationHeaders,contactValues,organizationValues) {
  var tbl = document.getElementById(tableName);
  var caption = tbl.getElementsByTagName('caption')[0];
  caption.innerHTML = '<i class="fa fa-user" aria-hidden="true"></i><span>Contact</span>';
  var thead = tbl.getElementsByTagName('thead')[0];
  if(thead) $('#preview-head').empty();
  var row = thead.insertRow(0);
  row.className = 'tb-head';
  var finalHeaders = contactHeaders.concat(organizationHeaders);
  var finalValues = contactValues.concat(organizationValues);
  for (var j = 0; j < finalHeaders.length; j++){
    var headerCell = document.createElement('TH');
    headerCell.innerHTML = finalHeaders[j];
    row.appendChild(headerCell);
  }
  var tbody = tbl.getElementsByTagName('tbody')[0];
  $('#preview-body').empty();
  var row = tbody.insertRow(tbody.rows.length);
  for (var j = 0; j < finalValues.length; j++){
    var x = row.insertCell(j);
    x.innerHTML = finalValues[j];
  }
}

function fadeFlash() {
  $('.alert').delay(5000).fadeOut();
  $(this).remove();
}
