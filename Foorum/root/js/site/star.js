var star_obj_div;
function star(obj_type, obj_id, obj_div) {
    var url = '/ajax/star';
    var pars = 'obj_type=' + obj_type + '&obj_id=' + obj_id;
    star_obj_div = obj_div;

    var myAjax = new Ajax.Request( url, {
	    method: 'get',
	    parameters: pars,
	    onSuccess: star_response,
	    onFailure: function () { alert('ERROR') }
	} );
}

function star_response(request) {
    response  = request.responseText;
    if (response == 1) {
        $(star_obj_div).innerHTML = 'Unstar it';
    } else {
        $(star_obj_div).innerHTML = 'Star it';
    }
}
