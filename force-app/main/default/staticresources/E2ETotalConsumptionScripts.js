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
		j$('.btn-continue').addClass('disabled');
	} else {
		j$('.btn-continue').removeClass('disabled');
	}
}