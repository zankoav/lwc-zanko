j$ = jQuery.noConflict();
var parsleyForm;

j$(document).ready(function() {
	parsleyForm = j$('[id$="formId"]').parsley();
	parsleyForm.on('field:validated', function() {
		toggleSearchButton();
	});
	toggleSearchButton();
});

function selectCompanyId(companyId) {
	j$('[id$="selectedCompanyId"]').val(companyId);
}

function toggleSearchButton() {
	if ( ! parsleyForm.isValid() ) {
		j$('.search-button').addClass('disabled');
	} else {
		j$('.search-button').removeClass('disabled');
	}
}

function toggleContinueButton() {
	
}

// function toggleContinueButton() {
// 	if ( ! parsleyForm.isValid() ) {
// 		j$('.continue-button').addClass('disabled');
// 	} else {
// 		j$('.continue-button').removeClass('disabled');
// 	}
// }

// function validateFieldsOnSubmit() {
// 	if ( ! parsleyForm.isValid() ) {
// 		parsleyForm.validate();
// 		console.log('validateFieldsOnSubmit false');
// 		return false;		
// 	}	
// 	console.log('validateFieldsOnSubmit true');
// 	processStep();
// 	return true;
// }