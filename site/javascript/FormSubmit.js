var FormSubmitWatcher = Class.create();

FormSubmitWatcher.prototype = {
	
	initialize: function(cForm) {
		this.cForm = $(cForm);
		
		var elements = Form.getElements(cForm);
		for (var i = 0; i < elements.length; i++) {
      		var element = elements[i];
			if (element.type.toLowerCase() == "textarea") {
				this.cText = element;
				this.cText.onkeypress = this.SubmitOnce.bindAsEventListener(this);
			}
		}
	},

	SubmitOnce : function(evt) {
		var x = evt.keyCode;
		var q = evt.ctrlKey;

		if (q && ( x == 13 || x == 10)) {
			this.cForm.submit();
			Form.disable(this.cForm);
		}
	}
}