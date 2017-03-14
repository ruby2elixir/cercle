$(function() {
    var s3_url=""
    var file_name=""
    var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
	$('#fileupload').fileupload({
        
        dataType: 'json',
        headers: {'Authorization': 'Bearer '+jwtToken},
        add: function (e, data) {
    
            var file_name = data.files[0].name;
            var file_size = (data.files[0].size/1000).toFixed(1);
            $('#list-uploaded-file').find('table tbody tr td')[0].innerHTML = file_name;
            $('#list-uploaded-file').find('table tbody tr td')[1].innerHTML = file_size + "kB";
            $('#list-uploaded-file').find('table tbody tr td')[2].innerHTML = data.files[0].type;
            $('#list-uploaded-file').find('table tbody tr td')[3].innerHTML = data.files[0].lastModifiedDate;
            var fileType = data.files[0].name.split('.').pop(), allowdtypes = 'csv,xls,xlsx';
            if (allowdtypes.indexOf(fileType) < 0) {
                $('.upload-dashed-box').css('border', '2px dashed red');
                if(!$('.errors').length){
                    $('.upload-info-box').prepend('<p class="errors">The uploaded file is in the wrong format..</p>');
                    if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden')
                }
                return false;
            }
            else{
                if($('.errors').length){
                    $('.errors').remove();
                    $('.upload-dashed-box').css('border', '2px dashed #c2c8cd');
                }
                if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden')
                $("#move-to-step2").removeClass('disabled');
                $("#move-to-step2").on('click', function (ev) {
                    ev.preventDefault();
                    $(this).addClass('disabled');
                    $('#uploaded-file-name').html('<span>Uploading </span><span class="filename">'+ file_name+'</span>');
                    var xhr = data.submit();
                });
            }
        },
        success: function(result){
            
            if (result.error){
                return false;
            }
            else{
                if (!$('#left-section-table tr').length) prepare_file_table("left-section-table", result.headers,result.first_row); 
                if (!$('#contact-field-table tr').length) prepare_db_table("contact-field-table", result.contact_fields);
                if (!$('#organization-field-table tr').length) prepare_db_table("organization-field-table", result.organization_fields);
                if (result) s3_url = result.s3_url;
            }
        },
        progress: function (e, data) {
            
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('.progress .progress-bar').css(
                'width',
                progress + '%'
            );
        },
        done: function (e, data) {
           
            if (data.result.error && data.result.error.length){
                $('.upload-dashed-box').css('border', '2px dashed red');
                $('.upload-info-box').prepend('<p class="errors"> The errors in import are:-'+data.result.error+'</p>');
                if ($('#list-uploaded-file').hasClass('hidden')) $('#list-uploaded-file').toggleClass('hidden');
                $('#progress .progress-bar').toggleClass('hidden');
                $('#uploaded-file-name').html("");
                return false;
            }
            else{
                $('#progress .progress-bar').toggleClass('hidden');
                $('#sec-1,#sec-2').toggleClass('hidden');
                $('#action-btns-step1,#action-btns-step2').toggleClass('hidden');
                $('#step1').addClass('completed').append('<i class="fa fa-check-circle" style="float:right" aria-hidden="true"></i>');
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

    $('#move-to-step3').on("click", function (e) {
        e.preventDefault();
        $(this).text('Processing..').addClass('disabled');
        $.ajax({
            url: '/api/v2/view_uploaded_data',
            type: 'POST',
            dataType: 'json',
            headers: {'Authorization': 'Bearer '+jwtToken},
            async: true,
            data: {
                mapping: jsonData,
                s3_url: s3_url
            },
            error: function(error) {
                $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">Some error occured, Please try again.</p>');
                $('#move-to-step3').text('Next').removeClass('disabled');
                fade_flash();

            },
            success: function(data) {                
                $('#sec-2').toggleClass('hidden');
                $('#action-btns-step2,#action-btns-step3').toggleClass('hidden');
                $('#step2').addClass('completed').append('<i class="fa fa-check-circle" style="float:right" aria-hidden="true"></i>');
                $('#sec-3').toggleClass('hidden');
                $('#step3').removeClass('steps-li-inactive').addClass('steps-li-active active');
                $('#move-to-step3').text('Next').removeClass('disabled');
                var contact_headers = data.contact_headers;
                var organization_headers = data.organization_headers;
                var contact_values = data.contact_values;
                var organization_values = data.organization_values;
                file_name = data.file_name
                prepare_preview_data_table("preview-data-table",contact_headers, organization_headers, contact_values, organization_values);
            }
        });
    });

    $('#move-to-final').click(function(e){
        e.preventDefault();
        $(this).text('Importing..').addClass('disabled');
        var user_id = $("#user_id").val();
        var company_id = $("#company_id").val();
        $('#final-progress .progress-bar').toggleClass('hidden');
        if(upload_type){
            // contact-import
            $.ajax({
                url: '/api/v2/contact_create',
                method: 'POST',
                headers: {'Authorization': 'Bearer '+jwtToken},
                data: {
                    mapping: jsonData,
                    file_name: file_name,
                    company_id: company_id,
                    user_id: user_id
                },
                success: function(result){
                    $('#final-progress .progress-bar').toggleClass('hidden');
                    $('.content-wrapper .container').prepend('<p class="alert alert-success" role="alert" style="border-radius:0px;">Records Imported Succesfully</p>');
                    $('#move-to-final').text('Finished').addClass('disabled');
                    window.location = "/contact";
                },
                error: function(error) {
                    $('.content-wrapper .container').prepend('<p class="alert alert-danger" role="alert" style="border-radius:0px;">Some error occured, Please try again.</p>');
                    $('#move-to-final').text('Next').removeClass('disabled');
                    fade_flash();
                }
            }); 
        }
    });
})

function prepare_file_table(table_name,headers,first_row) {
    var tbl = document.getElementById(table_name);
    for (var i = 0; i < headers.length; i++){ 
        var row = tbl.insertRow(tbl.rows.length);
        for (var j = 0; j < 2; j++) {
            if(j==0){
                var x = row.insertCell(j);
                x.innerHTML = '<div class="csv-col"><b>'+headers[i]+'</b></div><div class="csv-data">'+first_row[i]+'</div>';
                x.className = 'active csv-fields';
            }
            else{
                var x = row.insertCell(j);
                x.innerHTML = 'Drag and drop field here';
                x.className = 'info drop-fields';
                x.id = 'map'+i;
                x.draggable = true;
                x.setAttribute("ondrop","return drop(event)");
                x.setAttribute("ondragover","return allowDrop(event)");
                x.setAttribute("ondragstart","return drag(event)");
            }

        }
    }
}

function prepare_db_table(table_name,fields) {

    if (table_name == "contact-field-table") {
        var icon_type = "fa fa-user";
        var class_name = 'contact-fields';
        var id =  'contact-drag';
    }
    else{
       var icon_type = "fa fa-building";
       var class_name = 'organization-fields';
       var id = 'organization-drag';
    }
    var tbl = document.getElementById(table_name);
    for (var i = 0; i < fields.length; i++){ 
        var row = tbl.insertRow(tbl.rows.length);       
           
        var x = row.insertCell(0);
        x.innerHTML = '<i class="'+icon_type +'" aria-hidden="true"></i><span class="db-field">'+ fields[i]+ '</span>';
        x.className = 'active '+ class_name;
        x.id = id+i;
        x.draggable = true;
        x.setAttribute("ondrop","return drop(event)");
        x.setAttribute("ondragover","return allowDrop(event)");
        x.setAttribute("ondragstart","return drag(event)");
    }
}

function prepare_preview_data_table(table_name,contact_headers, organization_headers,contact_values,organization_values) {

    var tbl = document.getElementById(table_name);
    var caption = tbl.getElementsByTagName('caption')[0];
    caption.innerHTML = '<i class="fa fa-user" aria-hidden="true"></i><span>Contact</span>';
    var thead = tbl.getElementsByTagName('thead')[0];
    if(thead) $('#preview-head').empty();
    var row = thead.insertRow(0);
    row.className = 'tb-head';
    var final_headers = contact_headers.concat(organization_headers);
    var final_values = contact_values.concat(organization_values);
    for (var j = 0; j < final_headers.length; j++){ 
        var headerCell = document.createElement("TH");
        headerCell.innerHTML = final_headers[j];
        row.appendChild(headerCell);
    }
    var tbody = tbl.getElementsByTagName('tbody')[0];
    $('#preview-body').empty();
    var row = tbody.insertRow(tbody.rows.length);
    for (var j = 0; j < final_values.length; j++){ 
        var x = row.insertCell(j);
        x.innerHTML = final_values[j];
    }
}

function fade_flash() {
   $('.alert').delay(1000).fadeIn('slow', function() {
      $(this).delay(3000).fadeOut();
   });
}