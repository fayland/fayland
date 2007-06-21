function addEvent( obj, type, fn ) {
  if ( obj.attachEvent ) {
    obj['e'+type+fn] = fn;
    obj[type+fn] = function(){obj['e'+type+fn]( window.event );}
    obj.attachEvent( 'on'+type, obj[type+fn] );
  } else
    obj.addEventListener( type, fn, false );
}

/*
    Web Site:  http://dynamicdrive.com
*/
function disableForm(theform) {
    if (document.all || document.getElementById) {
        for (i = 0; i < theform.length; i++) {
            var tempobj = theform.elements[i];
            if (tempobj.type.toLowerCase() == "submit" || tempobj.type.toLowerCase() == "reset") {
                tempobj.disabled = true;
            }
        }
    }
    return true;
}