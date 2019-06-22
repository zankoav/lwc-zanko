j$ = jQuery.noConflict();
var parsleyForm;

j$(document).ready(function() {
	parsleyForm = j$('[id$="formId"]').parsley();
	parsleyForm.on('field:validated', function() {
		toggleContinueButton();
	});
	toggleContinueButton();
});

function toggleContinueButton() {
	if ( ! parsleyForm.isValid() ) {
		j$('.continue-button').addClass('disabled');
	} else {
		j$('.continue-button').removeClass('disabled');
	}
}
