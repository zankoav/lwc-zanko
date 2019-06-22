j$ = jQuery.noConflict();
var parsleyForm;

j$(document).ready(function() {
	parsleyForm = j$('[id$="formId"]').parsley();
	parsleyForm.on('field:validated', function() {
		toggleContinueButton();
	});
	j$('[id$="phone"]').inputmask({mask:"+4\\9999999999999", "placeholder": "" });
	toggleContinueButton();
});

function toggleContinueButton() {
	if ( ! parsleyForm.isValid() ) {
		j$('.continue-button').addClass('disabled');
	} else {
		j$('.continue-button').removeClass('disabled');
	}
}

function validateFieldsOnSubmit() {
	if ( ! parsleyForm.isValid() ) {
		parsleyForm.validate();
		console.log('validateFieldsOnSubmit false');
		return false;		
	}	
	console.log('validateFieldsOnSubmit true');
	processStep();
	return true;
}