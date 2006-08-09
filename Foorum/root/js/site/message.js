function new_message() {
    var url = '/ajax/new_message';
    var pars = '';

    var myAjax = new Ajax.Request( url, {
	    method: 'get',
	    parameters: pars,
	    onSuccess: show_message
	} );
    //var myAjax = new Ajax.Updater('new_msg', url, {method: 'get', parameters: pars});
}

function show_message(request) {
    response  = request.responseText;
    if (response != '') {
        $('new_message').innerHTML = response;
    } else {
        window.setTimeout("new_message();", 60000);
    }
}

function addEvent( obj, type, fn ) {
  if ( obj.attachEvent ) {
    obj['e'+type+fn] = fn;
    obj[type+fn] = function(){obj['e'+type+fn]( window.event );}
    obj.attachEvent( 'on'+type, obj[type+fn] );
  } else
    obj.addEventListener( type, fn, false );
}

addEvent( window, 'load', new_message );
//window.onload = windowloadit;