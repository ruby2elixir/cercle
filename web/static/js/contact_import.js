$(function() {

	$('#fileupload').fileupload({
        
        dataType: 'json',
        add: function (e, data) {
            console.log(data.files[0]);
            var file_name = data.files[0].name;
            $('#list-uploaded-file').toggleClass('hidden');
            $('#list-uploaded-file').find('table tbody tr td')[0].innerHTML = file_name;
            $('#list-uploaded-file').find('table tbody tr td')[1].innerHTML = data.files[0].size;
            $('#list-uploaded-file').find('table tbody tr td')[2].innerHTML = data.files[0].type;
            $('#list-uploaded-file').find('table tbody tr td')[3].innerHTML = data.files[0].lastModifiedDate;
            $(".proceed-btn").on('click', function (ev) {
                ev.preventDefault();
                data.context = $('#uploaded-file-name').html('Uploading <span class="filename">'+ file_name+'</span>').prependTo($('#progress'));
                var xhr = data.submit();
            });
        },
        success: function(result){
           
            prepare_file_table("left-section-table", result.headers,result.first_row);
            prepare_db_table("contact-field-table", result.contact_fields);
            prepare_db_table("company-field-table", result.company_fields);
        },
        progressall: function (e, data) {
            
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#progress .bar').css(
                'width',
                progress + '%'
            );
        },
        done: function (e, data) {
            
            $('#progress .bar').toggleClass('hidden');
            $('#sec-1').toggleClass('hidden');
            $('#action-btns-step1').toggleClass('hidden');
            $('#sec-2').toggleClass('hidden');
            $('#action-btns-step2').toggleClass('hidden');
            // $('.table tbody').append('<tr class="child"><td>blahblah</td></tr>');
            // $('<p/>').text(file.name).appendTo(document.body);
            // $('<img/>').attr("src",file.thumbnailUrl).appendTo(document.body);
            // $('<p/>').text(file.size).appendTo(document.body);
            $('.steps-li-active').addClass('completed').append('<i class="fa fa-check-circle" style="float:right" aria-hidden="true"></i>');
            $('.completed').next().removeClass('steps-li-inactive').addClass('steps-li-active active');
        }        
    });

    $('#myTabs a[href="#contact"]').click(function (e) {
      e.preventDefault();
      $(this).tab('show');
    });

    $('#myTabs a[href="#company"]').click(function (e) {
      e.preventDefault();
      $(this).tab('show');
    });

    $('.cancel-import').click(function (e) {
        xhr.abort();        
    });

    $('#back-to-step1').click(function (e) {
        $('#progress .bar').toggleClass('hidden');
        $('#sec-1').toggleClass('hidden');
        $('#action-btns-step1').toggleClass('hidden');
        $('#sec-2').toggleClass('hidden');
        $('#action-btns-step2').toggleClass('hidden');
        $('.completed').next().removeClass('active steps-li-active').addClass('steps-li-inactive');
        $('.completed').removeClass('completed active steps-li-inactive').addClass('active steps-li-active');
        // $('.steps-li-active').append('<i class="fa fa-check-circle" style="float:right" aria-hidden="true"></i>');        
    });
})

function prepare_file_table(table_name,headers,first_row) {
    var tbl = document.getElementById(table_name);
    for (var i = 0; i < headers.length; i++){ 
        var row = tbl.insertRow(tbl.rows.length);      // append table row
        
        // insert table cells to the new row
        for (var j = 0; j < 2; j++) {
            if(j==0){
                var x = row.insertCell(j);
                x.innerHTML = '<div class=""><b>'+headers[i]+'</b></div><div class="csv-data">'+first_row[i]+'</div>';
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
       var class_name = 'company-fields';
       var id = 'company-drag';
    }
    var tbl = document.getElementById(table_name);
    for (var i = 0; i < fields.length; i++){ 
        var row = tbl.insertRow(tbl.rows.length);       
           
        var x = row.insertCell(0);
        x.innerHTML = '<i class="'+icon_type +'" aria-hidden="true"></i> '+ fields[i];
        x.className = 'active '+ class_name;
        x.id = id+i;
        x.draggable = true;
        x.setAttribute("ondrop","return drop(event)");
        x.setAttribute("ondragover","return allowDrop(event)");
        x.setAttribute("ondragstart","return drag(event)");
    }
}