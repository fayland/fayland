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