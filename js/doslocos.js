var update; //global object literal used to build a postString for ajax updates to table fields/data
function asyncUpdate(confirm) {
    if (confirm === 0) update = null;
    if (!update) {$('form').remove(); window.location.reload();}
    update.value = $('#value').val();
    var ps = 'table='+'<?=$view?>'+'&where='+update.where+'&field='+update.field+'&value='+update.value;
    $('form').remove(); update = {};
    $.ajax({
        url: 'https://rsummerl.create.stedwards.edu/index.php', type: 'POST', data: ps,
        success: function(result) {window.location.reload();},
        failure: function(data, status, error) {console.log(data, error.stack); alert(status)},
        complete: function(data, status) {console.log(data, status);}
    });
}

//td as in table cell. this is the listener that creates the update form when clicked on. very cool!
$('td').click(function(pos) {
    if (!update) {
        console.log(update);
        let p = pos.target.parentNode;
    	let id = p.cells[0].innerHTML;
    	let c = pos.target.firstChild;
    	let value = c ? c.data : '';
    	let field = pos.target.id;
        update = {table: '<?=$view?>', field: field, value: value, where: id};
     	pos.target.innerHTML = '<form><input hidden type="text" name="'+update.table+
        '" value="'+update.where+'"><input hidden type="text" name="field" value="'+update.field+
        '"><input id="value" type="text" name="value" value="'+update.value+
        '"><br><button type="button" onclick="asyncUpdate(0)" style="float:left">CANCEL</button>'+
        '<button id="update" onclick="asyncUpdate(1)" type="button">UPDATE</button></form>';
    }
});

//i gave up writing a universal version of this because it involves too many specific conditions.
//the end result is: forms slide in and out when summoned, slide out when another is clicked,
//or when the cancel button is hit, or when escape is hit. it's ugly, but it works like a charm.

var employeeUpdateFormUp = false;
$("#employees").click(function() {
    if (employeeUpdateFormUp) {
        $('#employee').animate({left: "420vw"});
        $('#em').html('Add Employee');
        employeeUpdateFormUp = false;
        return;
    }
    $('#em').html('Cancel');
    $('#ve').html('Add Vendor');
    $('#pr').html('Add Product');
    $('#employee').animate({left: "1vw"});
    $('#vendor').animate({left: "420vw"});
    $('#product').animate({left: "420vw"});
    employeeUpdateFormUp = true;
});
var vendorUpdateFormUp = false;
$("#vendors").click(function() {
    if (vendorUpdateFormUp) {
        $('#vendor').animate({left: "420vw"});
        $('#ve').html('Add Vendor');
        vendorUpdateFormUp = false;
        return;
    }
    $('#em').html('Add Employee');
    $('#ve').html('Cancel');
    $('#pr').html('Add Product');
    $('#vendor').animate({left: "1vw"});
    $('#employee').animate({left: "420vw"});
    $('#product').animate({left: "420vw"});
    vendorUpdateFormUp = true;
});
var productUpdateFormUp = false;
$("#products").click(function() {
    if (productUpdateFormUp) {
        $('#product').animate({left: "420vw"});
        $('#pr').html('Add Product');
        productUpdateFormUp = false;
        return;
    }
    $('#em').html('Add Employee');
    $('#ve').html('Add Vendor');
    $('#pr').html('Cancel');
    $('#product').animate({left: "1vw"});
    $('#employee').animate({left: "420vw"});
    $('#vendor').animate({left: "420vw"});
    productUpdateFormUp = true;
});
function cancel() {
    $('#em').html('Add Employee');
    $('#ve').html('Add Vendor');
    $('#pr').html('Add Product');
    $('#employee').animate({left: "420vw"});
    $('#vendor').animate({left: "420vw"});
    $('#product').animate({left: "420vw"});
}
$(document).keyup(function(e) {
     if (e.key === "Escape") {cancel();}
});