function AutoSave(it) {

	var _value = it.value;	
	if (!_value) {
		var _LastContent = GetCookie('AutoSaveContent');
		
		if (!_LastContent) return;
		
		if (confirm("Load Last AutoSave Content?")) {
			it.value = _LastContent;
			return true;
		} else {
			DeleteCookie('AutoSaveContent');
		}
	} else {
		
		var expDays = 30;
		var exp = new Date();
		exp.setTime( exp.getTime() + (expDays * 86400000) ); // 24*60*60*1000 = 86400000
		var expires='; expires=' + exp.toGMTString();

		// SetCookie
		document.cookie = "AutoSaveContent=" + escape (_value) + expires;
	}
}

function getCookieVal (offset) {
	var endstr=document.cookie.indexOf (";",offset);
	if (endstr==-1) endstr=document.cookie.length;
	return unescape(document.cookie.substring(offset, endstr));
} 
function GetCookie (name){
	var arg=name+"=";
	var alen=arg.length;
	var clen=document.cookie.length;
	var i = 0;
	while (i<clen){
		var j=i+alen;
		if (document.cookie.substring(i,j)==arg) return getCookieVal (j);
		i = document.cookie.indexOf(" ",i)+1;
		if (i==0) break;
	}
	return null;
}
function DeleteCookie (name) {
	var exp=new Date();
	exp.setTime (exp.getTime()-1);
	var cval=GetCookie (name);
	document.cookie=name+"="+cval+";expires="+exp.toGMTString();
}
	