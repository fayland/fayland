function new_message() {
    var url = '/ajax/new_message';
    var pars = '';

    var myAjax = new Ajax.Request( url, {
	    method: 'get',
	    parameters: pars,
	    onSuccess: show_message
	} );
    //var myAjax = new Ajax.Updater('new_message', url, {method: 'get', parameters: pars});
}

function show_message(request) {
    response  = request.responseText;
    if (response != '') {
        Element.update('new_message', response);
    } else {
        window.setTimeout("new_message();", 60000);
    }
}

// need load utils.js
addEvent( window, 'load', new_message );
