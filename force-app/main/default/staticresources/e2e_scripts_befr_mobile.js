$j = jQuery.noConflict();

var regs = {
    phone: /^([0-9+]{11,13})+$/,
    numbers: /^[0-9]+$/,
    taxid: /^([0-9]{9,10})+$/,
    letters: /^[a-zA-ZÀ-ž\x7f-\xff\s'-]+$/,
    lettersAndNumbers: /^[0-9a-zA-ZÀ-ž\x7f-\xff\s'&.,-]+$/,
    embossingLetters: /^[a-zA-Z\s]+$/, // letters for embossing on card (important for GFN)
    embossingLettersAndNumbers: /^[0-9a-zA-Z\s]+$/, // letters and numbers for embossing on card (important for GFN)
    //email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/ //old version//
    email: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
    /*carNumberFormat_BEFR: /^[0-9A-Za-z]{1,3}\-?\s?[A-Za-z]{0,3}\-?\s?[0-9]{1,4}[H]{0,1}/, //old version*/
    carNumberFormat_BEFR: /^([0-9a-zA-Z-.]{1,9})+$/,
    swiftFormat: /^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$/,
    ibanFormat_BEFR: /^[Bb]{1}[Ee]{1}[0-9]{14}?$/,
    vatIdFormat_BEFR: /^[Bb]{1}[Ee]{1}[0-9]{9,10}?$/,
    dateOfBirth: /^\s*(3[01]|[12][0-9]|0?[1-9])\.(1[012]|0?[1-9])\.((?:19|20)\d{2})\s*$/g
};
var chatActivityTimeout;
var chatOfflineUpdateTimeout;
var chatOfflineOLDText;
var chatDeviceHeight;

var minPumpValue = 75;
var maxPumpValue = 50000;
var autoChatLastStep;
var isPrivateEntity;

var dataSource = 'eurolocator.fleetcorcards.be';
var favStationInfo = '';
var errors = {
    0 : 'ZERO_SEARCH_RESULTS'
}

var invalidMessageEvents = {
    0 : 'hide',
    1 : 'show'
}

var disableScroll = false;
var scrollPos = 0;

$j(document).ready(function () {
    // Lazy load
    lazyLoadScripts();

    onPageLoad();
    onPageRender();

    var content = $j('.step-content');
    isPrivateEntity = false;

    /* INIT ACTIVE VIEWPORT */
    viewportInit();

    /* STEP CONTACT DETAILS */
    setEvents_contactDetails();

    /* STEP COMPANY DETAILS */
    setEvents_companyDetails();

    // CHECK VAT ID
    setEvents_vatNumber();

    /* STEP CREDIT LINE */
    setEvents_creditLimit();

    /* STEP CARDS ORDER */
    setEvents_cardsOrder();

    /* STEP SPECIAL OFFERS */
    setEvents_specialOffers();

    /* STEP ADDITIONAL VAT-RECOVERY */
    setEvents_additional();

    /* STEP PAYMENT - DIRECT DEBIT */
    setEvents_directDebit();

    /* STEP PAYMENT - DIRECT DEBIT DEPOSIT */
    setEvents_directDebitDeposit();

    /* STEP PAYMENT - BANK TRANSFER DEPOSIT */
    setEvents_bankTransferDeposit();

    /* STEP PAYMENT - BANK TRANSFER NO DEPOSIT */
    setEvents_bankTransferNoDeposit();

    // Chat
    setChatOptions();

    /* setup scroll in modal windows */
    setupScrollInModal();
});

function scrollDisableControl(state){
    if(state == 'disable'){
        document.body.style.overflow = "hidden";
        disableScroll = true;
        scrollPos = $j(window).scrollTop();
    } else if (state == 'enable') {
        document.body.style.overflow = "auto";
        disableScroll = false;
    }
}

function setupScrollInModal(){
    var elementBody = $j('.modalWindows');
    elementBody.bind('DOMSubtreeModified', function(){
        var modal_info = document.getElementsByClassName('modal-info');
        if(modal_info.length > 0){
           document.body.style.overflow = "hidden";
           disableScroll = true;
           scrollPos = $j(window).scrollTop();
        } else {
           document.body.style.overflow = "auto";
           disableScroll = false;
        }
    });

    $j(window).bind('scroll', function(event){
         if (disableScroll) $j(window).scrollTop(scrollPos);
         var scrollTop = window.scrollY;
         document.getElementById('chatOfflineBlock').style.top = scrollTop + 'px';
         document.getElementById('chatOnlineBlock').style.top = scrollTop + 'px';
    });

    $j(window).bind('touchmove', function(){
         $j(window).trigger('scroll');
    });

    $j(window).resize(function() {

    });
}

// init active viewport
function goToActiveViewport(activeStep, activeSubStep) {
    var viewportName;
    if (activeStep == 0 && activeSubstep == 'Get started') {
        viewportName = 'get-started-viewport';
    } else if (activeStep == 1 && (activeSubStep == 'Enter VAT Number' || activeSubStep == 'Set total consumption')) {
        viewportName = 'your-company-viewport';
    } else if (activeStep == 2 && activeSubStep == 'Additional services') {
        viewportName = 'additional-viewport';
    } else if (activeStep == 5 && activeSubStep == 'Congratulations') {
        viewportName = 'configuration-viewport';
    } else {
        viewportName = 'order-details-viewport';
    }
    toViewport(viewportName);
}


function setEvents_contactDetails() {
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var contactDetailsStepBlock = $j('.step-content').find('.contact-details');
    var agreement = contactDetailsStepBlock.find('input[type="checkbox"]');
    var contactDetails_requiredInputs = contactDetailsStepBlock.find('.form-control.required');

    // Validate if fields are not empty
    $j(contactDetailsStepBlock).find('input:text').each(function(){
        checkInputNotEmpty( $j(this) );
        if ( $j(this).attr('id').indexOf('phone') >= 0) {
            // $j(this).inputmask({mask:"+3\\2999999999999", "placeholder": "" });
            $j(this).attr('type','tel');
        }
        if ( $j(this).val() != '' && $j(this).val() != undefined ) {
            if ( $j(this).attr('id').indexOf('firstName') >= 0 ||
                 $j(this).attr('id').indexOf('lastName') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.letters));
            } else
            if ( $j(this).attr('id').indexOf('phone') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.phone));
            } else
            if ( $j(this).attr('id').indexOf('email') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.email));
            }
        }
    });

    // Enable/Disable Continue Button based on existing errors in input fields
    checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
    if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);

    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>

    // Add validation on "input" event for required fields.
    // First and Last names should contain english + german letters.
    // Phone should start from +49, 13-15 numbers.
    // Email should be in valid format.
    contactDetails_requiredInputs.each(function(){
        if ( $j(this).attr('id').indexOf('firstName') >= 0) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.letters));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('lastName') >= 0 ) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.letters));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('phone') >= 0) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.phone));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('email') >= 0) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.email));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else 
        if ( $j(this).attr('id').indexOf('numberofcardscontactdetails') >= 0) {
            $j(this).on('input', function (e){
                if ($j(this).val() > 50) {
                    $j(this).val(50);
                } else
                if ($j(this).val() < 0) {
                    $j(this).val(1);
                }
            });
            $j(this).on('blur', function (e) {
                if ($j(this).val() == undefined || $j(this).val() == null || $j(this).val() == 0) {
                    $j(this).val('1');
                }
            });
        }
    });


    // If Agreement checkbox seleted and all fields are valid вЂ“ enable Continue button
    // Event on "click" checkbox
    agreement.on('click', function() {
        checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
        if ( ! agreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
    });
    // <<< END ELEMENTS EVENTS <<<
}


function setEvents_companyDetails() {
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var creditScoringStepBlock = $j('.step-content').find('.credit-scoring');
    var creditScoring_requiredInputsCompanyAndTax = creditScoringStepBlock.find('.form-control.required.companyAndTax');
    var creditScoring_requiredInputTax = creditScoringStepBlock.find('.form-control.required.taxIdInput');
    var creditScoring_requiredInputTotalConsumption = creditScoringStepBlock.find('.form-control.required.pumpInput');
    var chatButtonOnline = document.getElementById('chat-button-online');
    var cfCompanies = creditScoringStepBlock.find('input[type = "radio"]');
    var chatButtonOffline = document.getElementById('chat-button-offline');
    // Run validation if fields are not empty
    $j(creditScoringStepBlock).find('input:text').each(function(){
        checkInputNotEmpty( $j(this) );
        if ( $j(this).val() != '' && $j(this).val() != undefined ) {
            if ( $j(this).attr('id').indexOf('company') >= 0 ||
                 $j(this).attr('id').indexOf('lastName') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.lettersAndNumbers));
            } else
            if ( $j(this).attr('id').indexOf('tax') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.numbers));
            } else
            if ( $j(this).attr('id').indexOf('taxId') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.taxid));
            } else
            if ( $j(this).attr('id').indexOf('pump') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.numbers));
            }
        }
    });

    // If no errors in Company and Tax ID and display Search companies button
    checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.search'));
    // If no errors in Tax Id and display Continue button (on Tax Id step)
    checkRequiredFieldsAndToggleButton(creditScoring_requiredInputTax, creditScoringStepBlock.find('.btn-red.continue-fromtax'));
    // If no errors in Total Consumption field and display Final continue button
    checkRequiredFieldsAndToggleButtonForBtnAsLink(creditScoring_requiredInputTotalConsumption, creditScoringStepBlock.find('.btn-red.continue'));
    creditScoring_requiredInputTotalConsumption.attr('type','number');
    creditScoring_requiredInputTax.attr('type','number');

    // Chat
    if (chatButtonOnline != null) chatButtonOnline.style.visibility = "visible";
    if (chatButtonOffline != null) chatButtonOffline.style.visibility = "visible";
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>

    // Add validation on "input" event for required fields.
    // Company should contain letters and numbers
    creditScoring_requiredInputsCompanyAndTax.each(function(){
        if ( $j(this).attr('id').indexOf('company') >= 0) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.lettersAndNumbers));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.search'));
                if ( isRadioButtonSelected(cfCompanies) ) {
                    checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.continue'));
                }
            });
        } else
        if ( $j(this).attr('id').indexOf('tax') >= 0) {
            $j(this).on('input', function (e){
                isInputValueValid($j(this), new RegExp(regs.numbers));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.search'));
                if ( isRadioButtonSelected(cfCompanies) ) {
                    checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.continue'));
                }
                if ( $j(this).val().length < 9 || $j(this).val().length > 10 ) {
                    creditScoringStepBlock.find('.btn.btn-red.search').addClass('disabled');
                } else {
                    creditScoringStepBlock.find('.btn.btn-red.search').removeClass('disabled');
                }
            });
        }
    });
    // Tax Id should be in valid format
    creditScoring_requiredInputTax.on('input', function(e){
        if ($j(this).val().length > 11) {
            $j(this).val($j(this).val().substr(0, 11));
        }
        validateTaxId($j(this), new RegExp(regs.taxid));
        checkInputNotEmpty($j(this));
        checkRequiredFieldsAndToggleButton($j(this), creditScoringStepBlock.find('.continue-fromtax'));
    });
    // Total consumption should contain numbers only
    var content = $j('.step-content');
    var fuelConsumptionStepBlock = content.find('.fuel-consumption');
    var pumpInput = fuelConsumptionStepBlock.find('.pump').find('input');
    validatePumpInputValue(pumpInput, new RegExp(regs.numbers));
    
    creditScoring_requiredInputTotalConsumption.on('input', function(e){
        if ($j(this).val().length > 5) {
            $j(this).val($j(this).val().substr(0, 5));
        }
        validatePumpInputValue($j(this), new RegExp(regs.numbers));
        checkInputNotEmpty($j(this));
        checkRequiredFieldsAndToggleButtonForBtnAsLink($j(this), creditScoringStepBlock.find('.btn-red.continue'));
    });

    cfCompanies.change(function() {
        if(isRadioButtonSelected(cfCompanies)){
            checkRequiredFieldsAndToggleButton(creditScoring_requiredInputsCompanyAndTax, creditScoringStepBlock.find('.btn-red.continue'));
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}

function setEvents_creditLimit() {
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var creditLineStepBlock = $j('.step-content').find('.credit-line');
    var creditLimit = creditLineStepBlock.find('.credit-limit').find($j('[id$="creditLimitInput"]'));
    var minLimit = parseInt(creditLineStepBlock.find('.min-limit').html());
    var maxLimit = parseInt(creditLineStepBlock.find('.max-limit').html());
    validateCreditLimitValue(creditLimit);
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    // Collapse details block event
    $j('.collapse-block .link').on('click', function(){
        var detailsBlock = $j(this).parent().find('.row');
        var collapseBlock = $j(this).find('.expander');
        if(detailsBlock.is(':hidden')){
            collapseBlock.removeClass('block-expand').addClass('block-collapse');
        } else {
            collapseBlock.removeClass('block-collapse').addClass('block-expand');
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}

function setEvents_slider() {
    var content = $j('.step-content');
    var creditLineStepBlock = content.find('.credit-line');
    var creditLimit = creditLineStepBlock.find('.credit-limit').find($j('[id$="creditLimitInput"]'));

    var minLimitValue = creditLineStepBlock.find('.min-limit').html();
    if (minLimitValue != undefined) {
        minLimitValue = minLimitValue.replace(/\s/g,'');
    }
    var maxLimitValue = creditLineStepBlock.find('.max-limit').html();
    if (maxLimitValue != undefined) {
        maxLimitValue = maxLimitValue.replace(/\s/g,'');
    }    
    var minLimit = parseInt(minLimitValue);
    var maxLimit = parseInt(maxLimitValue);

    createSlider('slider', 'creditLimitInput', 'idInputHidden', creditLimit.text(), minLimit, maxLimit);

    if ($j('#slider').find('.slider-active-line').length == 0) {
        $j('#slider').append('<div class="slider-active-line" style="width:0%"></div>');
    }
    colorSliderActiveLine();

    creditLimit.unbind('DOMSubtreeModified');
    creditLimit.bind('DOMSubtreeModified', function(){
            colorSliderActiveLine();
    });

    var slider = $j('#slider');
    slider.on('click mousemove mouseout mouseleave', function(){
        colorSliderActiveLine();
    }); 
}

function setEvents_vatNumber() {
    var vatNumberBlock = $j('.step-content').find('.enter-vat-id');
    var vatNumberInput = $j('.step-content').find('.enter-vat-id').find('.vatNumberInput');
    var isVatValid = false;
    vatNumberInput.on('input', function(e){
        isInputValueValid(vatNumberInput, new RegExp(regs.vatIdFormat_BEFR));
        checkInputNotEmpty(vatNumberInput);
        checkRequiredFieldsAndToggleButton(vatNumberInput, vatNumberBlock.find('.continue-fromvat'));
    });
    checkRequiredFieldsAndToggleButton(vatNumberInput, vatNumberBlock.find('.continue-fromvat'));
    checkInputNotEmpty(vatNumberInput);
}

function setEvents_cardsOrder(){
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var cardsOrderStepBlock = $j('.step-content').find('.cards-order');
    var cardTechParamsItems = cardsOrderStepBlock.find('.cards-list .card-item');
    var cardTechParams_requiredInputs = cardsOrderStepBlock.find('.card-item').find('.form-control.required');
    var counterInput = cardsOrderStepBlock.find('.cards-count').find('input');

    $j('.invalid-feedback-driver').hide();
    $j('.invalid-car-number-driver').hide();

    $j('.step-content').find('.cards-order').find('input').each(function() {
        checkInputNotEmpty($j(this));
    });

    if (cardTechParamsItems.find('.card-owner').find('input').val() != '' &&
        cardTechParamsItems.find('.card-owner').find('input').val() != undefined) {
        var selectedCardOwnerType = cardTechParamsItems.find('[id$=embossing-dflt]').val();
        if (selectedCardOwnerType != undefined ) {
            if (selectedCardOwnerType.toLowerCase() === 'car-number') {
                validateCarNumber(cardTechParamsItems.find('.card-owner').find('input'), new RegExp(regs.carNumberFormat_BEFR));
            }
            if (selectedCardOwnerType.toLowerCase() === 'driver-name') {
                validateDriverName(cardTechParamsItems.find('.card-owner').find('input'), new RegExp(regs.embossingLetters));
            }
        }
    }

    if (cardTechParamsItems.find('.company-name').find('input').val() != '' &&
        cardTechParamsItems.find('.company-name').find('input').val() != undefined) {
        isInputValueValid(cardTechParamsItems.find('.company-name').find('input'), new RegExp(regs.embossingLettersAndNumbers));
    }

    checkRequiredFieldsAndToggleButtonForBtnAsLink(cardTechParams_requiredInputs, cardsOrderStepBlock.find('.btn-red'));

    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    counterInput.on('input',function(){
        checkInputNotEmpty(counterInput);
        checkCounterValue(counterInput);
    });

    cardTechParamsItems.find('.card-owner').find('input').on('input', function() {
        $j('.invalid-feedback-driver').hide();
        $j('.invalid-car-number-driver').hide();
        // top label class check
        checkInputNotEmpty($j(this));
        var selectedCardOwnerType = cardTechParamsItems.find('[id$=embossing-dflt]').val();
        if (selectedCardOwnerType != undefined ) {
            checkInputNotEmpty($j(this));
            if (selectedCardOwnerType.toLowerCase() === 'car-number') {
                validateCarNumber($j(this), new RegExp(regs.carNumberFormat_BEFR));
            }
            if (selectedCardOwnerType.toLowerCase() === 'driver-name') {
                validateDriverName($j(this), new RegExp(regs.embossingLetters));
            }
        }
        checkRequiredFieldsAndToggleButtonForBtnAsLink(cardTechParams_requiredInputs, cardsOrderStepBlock.find('.btn-red'));
    });

    cardTechParamsItems.find('.company-name').find('input').on('input', function() {
        // top label class check
        checkInputNotEmpty($j(this));
        isInputValueValid($j(this), new RegExp(regs.embossingLettersAndNumbers));
        checkRequiredFieldsAndToggleButtonForBtnAsLink(cardTechParams_requiredInputs, cardsOrderStepBlock.find('.btn-red'));
    });

    // On click embossing
    if (cardTechParamsItems.find('.embossRadioType').on('click', function() {
        var cardOwnerInput = cardTechParamsItems.find('.card-owner').find('input');
        $j('.invalid-feedback-driver').hide();
        $j('.invalid-feedback-car-number').hide();
        cardOwnerInput.val('');
        cardOwnerInput.closest('.form-group input').removeClass('success');
        cardOwnerInput.closest('.form-group input').removeClass('error');
        cardOwnerInput.closest('.form-group').find('.input-label').removeClass('invalid');
        cardOwnerInput.closest('.form-group .f-container').removeClass('error');
        cardOwnerInput.closest('.form-group').find('.additional').hide();
        checkRequiredFieldsAndToggleButtonForBtnAsLink(cardTechParams_requiredInputs, cardsOrderStepBlock.find('.btn-red'));
        // checkInputNotEmpty(cardOwnerInput);
        // var selectedCardOwnerType = cardTechParamsItems.find('[id$=embossing-dflt]').val();
        // if (selectedCardOwnerType.toLowerCase() === 'car-number') {
        //     validateCarNumber(cardOwnerInput, new RegExp(regs.carNumberFormat_BEFR));
        // }
        // if (selectedCardOwnerType.toLowerCase() === 'driver-name') {
        //     validateDriverName(cardOwnerInput, new RegExp(regs.embossingLetters));
        // }
        // isInputValueValid($j(this), new RegExp(regs.embossingLettersAndNumbers));
        // checkRequiredFieldsAndToggleButtonForBtnAsLink(cardTechParams_requiredInputs, cardsOrderStepBlock.find('.btn-red'));
    }));

    // Collapse details block event
    $j('.collapse-block .link').on('click', function(){
        var detailsBlock = $j(this).parent().find('.row');
        var collapseBlock = $j(this).find('.expander');
        if(detailsBlock.is(':hidden')){
            collapseBlock.removeClass('block-expand').addClass('block-collapse');
        } else {
            collapseBlock.removeClass('block-collapse').addClass('block-expand');
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}
$j('.step-content').find('.cards-order').find('.cards-list .card-item').find('.company-name').find('input').val()


function checkCompanyName() {
    var isValid = false;
    var cardsOrderStepBlock = $j('.step-content').find('.cards-order');
    var cardTechParamsItems = cardsOrderStepBlock.find('.cards-list .card-item');
    var companyValue;
    if (cardTechParamsItems.find('.company-name').find('input').val() != '' &&
        cardTechParamsItems.find('.company-name').find('input').val() != undefined) {
        companyValue = cardTechParamsItems.find('.company-name').find('input').val();
    } else if (cardTechParamsItems.find('.company-value').text() != '' &&
                cardTechParamsItems.find('.company-value').text() != undefined) {
        companyValue = cardTechParamsItems.find('.company-value').text();
    }
    if (companyValue != '' && companyValue != undefined) {
        var invalidFeedbackElement = cardTechParamsItems.find('.company-name').find('input').closest('.form-group').find('.invalid-feedback');
        var regex = new RegExp(regs.embossingLettersAndNumbers);
        if((companyValue.trim() != '') && regex.test(companyValue) && companyValue.length <= 25) {
            isValid = true;
            showOrHideInvalidMessage(invalidMessageEvents[0], cardTechParamsItems.find('.company-name').find('input'), invalidFeedbackElement);
        } else {
            isValid = false;
            showOrHideInvalidMessage(invalidMessageEvents[1], cardTechParamsItems.find('.company-name').find('input'), invalidFeedbackElement);
        }
    }
    return isValid;
}


function setEvents_specialOffers(){
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var noDataMessage = $j('.locator-error-message1');
    var wrongAddressMessage = $j('.locator-error-message2');
    var favoriteStationBlock = $j('.special-offers .offer').find('.fav-station').find('.point');
    var specialOfferBlock = $j('.special-offers .offer');
    window.addEventListener('message', function(event) {
        if (~event.origin.indexOf(dataSource)) {
            wrongAddressMessage.hide();
            noDataMessage.hide();
            if(event.data.id) {
                favStationInfo = (event.data.townName).toLowerCase() + ', ' + (event.data.address).toLowerCase();
                $j('<span class="station">' + favStationInfo + '</span>').insertBefore('.special-offers .offer .fav-station .edit');
                return;
            }

            if(event.data.error === errors[0]) {
                wrongAddressMessage.show();
                return;
            }

            if(event.data.numberOfPoints == 0){
                noDataMessage.show();
                return;
            }
        } else {
            // if a source of data is not a site-locator then do nothing
            return;
        }
    });
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    favoriteStationBlock.bind('DOMSubtreeModified', function(){
        if(favStationInfo !== ''){
            specialOfferBlock.find('.btn-red.my-station').attr('disabled', false);
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}


function setEvents_additional() {
    var content = $j('.step-content');
    var additionalStepBlock = content.find('.additional-services');
    var vatRecoveryAgreement = additionalStepBlock.find('.vatRecovery');
    var vatTermsAndConditionsAgreement = additionalStepBlock.find('.vatRecoveryTC');
    if (vatRecoveryAgreement.is(':checked') && ! vatTermsAndConditionsAgreement.is(':checked')) {
        additionalStepBlock.find('.btn-red').attr('disabled', true);
    } else if ( ! vatRecoveryAgreement.is(':checked') && vatTermsAndConditionsAgreement.is(':checked')) {
        additionalStepBlock.find('.btn-red').attr('disabled', true);
    } else {
        additionalStepBlock.find('.btn-red').attr('disabled', false);
    }
    vatRecoveryAgreement.on('click', function() {
        if (vatRecoveryAgreement.is(':checked') && ! vatTermsAndConditionsAgreement.is(':checked') ) {
            additionalStepBlock.find('.btn-red').attr('disabled', true);
        } else if ( ! vatRecoveryAgreement.is(':checked') && vatTermsAndConditionsAgreement.is(':checked')) {
            additionalStepBlock.find('.btn-red').attr('disabled', true);
        } else {
            additionalStepBlock.find('.btn-red').attr('disabled', false);
        }
    });

    vatTermsAndConditionsAgreement.on('click', function() {
        if ( ! vatRecoveryAgreement.is(':checked') && vatTermsAndConditionsAgreement.is(':checked') ) {
            additionalStepBlock.find('.btn-red').attr('disabled', true);
        } else if (vatRecoveryAgreement.is(':checked') && ! vatTermsAndConditionsAgreement.is(':checked')) {
            additionalStepBlock.find('.btn-red').attr('disabled', true);
        } else {
            additionalStepBlock.find('.btn-red').attr('disabled', false);
        }
    });
}


function setEvents_dateOfBirth() {
    var dateOfBirthBlock = $j('.step-content').find('.enter-date-of-birth');
    var dateOfBirthInput = $j('.step-content').find('.enter-date-of-birth').find('.dateOfBirthInput');

    // on load disable button
    checkRequiredFieldsAndToggleButton(dateOfBirthInput, dateOfBirthBlock.find('.continue-date-of-birth'));
    checkInputNotEmpty(dateOfBirthInput);

    // on click check input
    dateOfBirthInput.on('input', function(e) {
        validateDateOfBirth(dateOfBirthInput, new RegExp(regs.dateOfBirth));
        checkInputNotEmpty(dateOfBirthInput);
        checkRequiredFieldsAndToggleButton(dateOfBirthInput, dateOfBirthBlock.find('.continue-date-of-birth'));
    });
    // dateOfBirthInput.inputmask({mask:"99.99.9999", "placeholder": "" });
}


function validateDateOfBirth(element, regex) {
    var isValid = false;
    var dateOfBitrhSize = element.val().length;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback');
    if ((elementValue.trim() != '') && regex.test(elementValue)) {
        if (dateOfBitrhSize == 10) {
            showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
            isValid = true;
        } else {
            showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
            isValid = false;
        }
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}


function setEvents_directDebit(){
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var content = $j('.step-content');
    var paymentDirectDebitBlock = content.find('.payment-direct-debit');
    var paymentDirectDebit_requiredInputs = paymentDirectDebitBlock.find('.form-control.required');
    var allAgreements = paymentDirectDebitBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];
    var acceptSepaButton = $j('[id$=sepa-accept-val]').val();
    paymentDirectDebit_requiredInputs.each(function(){
        checkInputNotEmpty( $j(this) );
        if ( $j(this).val() != '' && $j(this).val() != undefined ) {
            if ( $j(this).attr('id').indexOf('accountHolder') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.letters));
            } else
            if ( $j(this).attr('id').indexOf('IBAN') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.ibanFormat_BEFR));
            } else
            if ( $j(this).attr('id').indexOf('SWIFT') >= 0) {
                isInputValueValid($j(this), new RegExp(regs.swiftFormat));
            }
        }
    });
    // checkRequiredFieldsAndToggleButtonForBtnAsLink(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
    allAgreements.each(function(){
        if ( ! $j(this).hasClass('paper-invoices') ) {
            if ( $j(this).is(':checked') ) {
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        }
    });

    if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true' ) {
        checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
    } else {
        paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
    }
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    paymentDirectDebit_requiredInputs.each(function(){
        if ( $j(this).attr('id').indexOf('accountHolder') >= 0) {
            $j(this).on('input', function(e) {
                isInputValueValid($j(this), new RegExp(regs.letters));
                checkInputNotEmpty($j(this));
                if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true' ) {
                    checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
                } else {
                    paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
                }
            });
        } else
        if ( $j(this).attr('id').indexOf('IBAN') >= 0) {
            $j(this).on('input', function(e) {
                isInputValueValid($j(this), new RegExp(regs.ibanFormat_BEFR));
                checkInputNotEmpty($j(this));
                if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true' ) {
                    checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
                } else {
                    paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
                }
            });
        } else
        if ( $j(this).attr('id').indexOf('SWIFT') >= 0) {
            $j(this).on('input', function(e) {
                isInputValueValid($j(this), new RegExp(regs.swiftFormat));
                checkInputNotEmpty($j(this));
                if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true' ) {
                    checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
                } else {
                    paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
                }
            });
        }
    });

    allAgreements.click(function() {
        confirmedAgreements = [];
        allAgreements.each(function() {
            if ( ! $j(this).hasClass('paper-invoices') ) {
                if ( $j(this).is(':checked') ) {
                    confirmedAgreements.push(true);
                } else {
                    confirmedAgreements.push(false);
                }
            }
        });

        if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true') {
            checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
        } else {
            paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
        }
    });

    $j('#sepa-disagree-block .btn-red').on('click', function() {
        if ( ! confirmedAgreements.includes(false) && acceptSepaButton == 'true') {
            checkRequiredFieldsAndToggleButton(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
        } else {
            paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}

function setEvents_directDebitDeposit() {
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var content = $j('.step-content');
    var directDebitBlock = content.find('.payment-direct-debit-deposit');
    var agreement = directDebitBlock.find('input[type="checkbox"]');
    var paymentMethods = directDebitBlock.find('.category-link');
    directDebitBlock.find('.btn-red.continue').attr('disabled', true);
    validDirectDebitForm(directDebitBlock, paymentMethods);
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    paymentMethods.change(function() {
        validDirectDebitForm(directDebitBlock, paymentMethods);
    });
    agreement.click(function(){
        validDirectDebitForm(directDebitBlock, paymentMethods);
    });
    // <<< END ELEMENTS EVENTS <<<
}



function setEvents_bankTransferDeposit(){
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var content = $j('.step-content');
    var paymentBankTransferBlock = content.find('.payment-bank-transfer');
    var paymentMethods = paymentBankTransferBlock.find('.category-link');
    var allAgreements = paymentBankTransferBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];

    paymentBankTransferBlock.find('.btn-red.continue').attr('disabled', true);
    allAgreements.each(function(){
        if ( ! $j(this).hasClass('paper-invoices') ) {
            if ( $j(this).is(':checked') ) {
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        }
    });

    validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    paymentMethods.change(function() {
        confirmedAgreements = [];
        allAgreements.each(function(){
            if ( ! $j(this).hasClass('paper-invoices') ) {
                if($j(this).is(':checked')){
                    confirmedAgreements.push(true);
                } else {
                    confirmedAgreements.push(false);
                }
            }
        });

        validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);
    });
    allAgreements.click(function(){
        confirmedAgreements = [];
        allAgreements.each(function() {
            if ( ! $j(this).hasClass('paper-invoices') ) {
                if ( $j(this).is(':checked') ) {
                    confirmedAgreements.push(true);
                } else {
                    confirmedAgreements.push(false);
                }
            }
        });

        validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);
    });
    // <<< END ELEMENTS EVENTS <<<
}

function setEvents_bankTransferNoDeposit(){
    // >>> START ONLOAD OR ON BACK TO THIS STEP >>>
    var content = $j('.step-content');
    var bankTransferNoDepositBlock = content.find('.payment-bank-transfer-no-deposit');
    var agreements = bankTransferNoDepositBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];

    agreements.each(function(){
        if ( ! $j(this).hasClass('paper-invoices') ) {
            if ( $j(this).is(':checked') ) {
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        }
    });

    if (confirmedAgreements.includes(false) ) {
        bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', true);
    } else {
        bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', false);
    }
    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>
    agreements.click(function(){
        confirmedAgreements = [];
        agreements.each(function(){
            if ( ! $j(this).hasClass('paper-invoices') ) {
                if($j(this).is(':checked')){
                    confirmedAgreements.push(true);
                } else {
                    confirmedAgreements.push(false);
                }
            }
        });
        if(confirmedAgreements.includes(false)){
            bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', true);
        } else {
            bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', false);
        }
    });
    // <<< END ELEMENTS EVENTS <<<
}

function acceptSepa() {
    $j('[id$=sepa-accept-val]').val('true');
    $j('[id$=sepa-disagree-block]').hide();
    $j('[id$=show-sepa-btn]').hide();
    $j('[id$=sepa-agree-block]').show();
}


function showOrHideInvalidMessage(event, element, invalidFeedbackElement){
    // if hide invalid feedback
    if(event === invalidMessageEvents[0]){
        element.closest('.form-group input').addClass('success');
        element.closest('.form-group input').removeClass('error');
        element.closest('.form-group').find('.input-label').removeClass('invalid');
        element.closest('.form-group .f-container').removeClass('error');
        invalidFeedbackElement.hide();
        element.closest('.form-group').find('.additional').show();
    }

    // if show invalid feedback
    if(event === invalidMessageEvents[1]){
        element.closest('.form-group input').removeClass('success');
        element.closest('.form-group input').addClass('error');
        element.closest('.form-group').find('.input-label').addClass('invalid');
        element.closest('.form-group .f-container').addClass('error');
        invalidFeedbackElement.show();
        element.closest('.form-group').find('.additional').hide();
    }
}

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback');
    if((elementValue.trim() != '') && regex.test(elementValue)){
        showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
        isValid = true;
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}

function checkInputNotEmpty(input){
    if(input.val() != '' && input.val() != undefined){
        input.addClass('not-empty');
    } else {
        input.removeClass('not-empty');
    }
}

function checkRequiredFieldsAndToggleButtonForBtnAsLink(inputs, button){
    var empty = false;
    var hasErrors = false;
    inputs.each(function() {
        if($j(this).val() == '') {
            empty = true;
        }
        if($j(this).hasClass('error')){
            hasErrors = true;
        }
    });
    if (empty || hasErrors) {
        button.addClass('disabled');
    } else {
        button.removeClass('disabled');
    }
}

function checkRequiredFieldsAndToggleButton(inputs, button){
    var empty = false;
    var hasErrors = false;
    inputs.each(function() {
        if($j(this).val() == '') {
            empty = true;
        }
        if($j(this).hasClass('error')){
            hasErrors = true;
        }
    });

    if (empty || hasErrors) {
        button.attr('disabled', true);
    } else {
        button.attr('disabled', false);
    }
}

function isRadioButtonSelected(radioInputs){
    var selected = false;
    radioInputs.each(function() {
        if($j(this).is(':checked')){
            selected = true;
        }
    });
    return selected;
}

function isSwitchChecked(switches){
    var isChecked = false;
    switches.each(function() {
        if($j(this).is(':checked')){
            isChecked = true;
        }
    });
    return isChecked;
}

function validateTaxId(element, regex) {
    var isValid = false;
    var taxIdSize = element.val().length;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback');
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(taxIdSize >= 9 && taxIdSize <= 10){
            showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
            isValid = true;
        } else {
            showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
            isValid = false;
        }
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}

// On click Continue
function validateContactDetails(moveToNextStep){
    var currentStepBlock = $j('.step-content .contact-details');
    var firstNameInput = currentStepBlock.find('.first-name').find('input');
    var lastNameInput = currentStepBlock.find('.last-name').find('input');
    var phoneInput = currentStepBlock.find('.phone').find('input');
    var emailInput = currentStepBlock.find('.email').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(firstNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(lastNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(phoneInput, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailInput, new RegExp(regs.email)));
    isValid = validatedFields.indexOf(false)>=0 ? false : true;

    var isAgreementChecked = currentStepBlock.find('input[type="checkbox"]').is(':checked');
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    if(isValid && !isNextStepDisabled && isAgreementChecked){
       if (moveToNextStep) {
           mGoToCreditScoring();
       }
       return true;
    } else {
       return false;
    }
}

function validateCompanyDetailsForSearch(){
    isCompaniesList = true;
    var currentStepBlock = $j('.step-content .credit-scoring');
    var companyNameInput = currentStepBlock.find('.company').find('input');
    var taxInput = currentStepBlock.find('.tax-id').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyNameInput, new RegExp(regs.lettersAndNumbers)));
    if (taxInput.val() != '' && taxInput.val() != undefined) {
        isInputValueValid(taxInput, new RegExp(regs.letters));
    }
    isValid = validatedFields.includes(false) ? false : true;
    var isNextStepDisabled = currentStepBlock.find('.btn-gray.search').is('[disabled=disabled]');
    if ( isValid && ! isNextStepDisabled ) {
        startSplash();
        mDoSaveCompany();
        return true;
    } else {
        return false;
    }
}

function validateCompanyDetails(moveToNextStep){
    var currentStepBlock = $j('.step-content .credit-scoring');
    var companyNameInput = currentStepBlock.find('.company').find('input');
    var taxInput = currentStepBlock.find('.tax-id').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyNameInput, new RegExp(regs.lettersAndNumbers)));
    if (taxInput.val() != '' && taxInput.val() != undefined) {
        isInputValueValid(taxInput, new RegExp(regs.letters));
    }
    isValid = validatedFields.includes(false) ? false : true;
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    if(isValid && !isNextStepDisabled){
        if(moveToNextStep){
            goToFuelConsumption();
        }
       return true;
    } else {
       return false;
    }
}

function validatePumpInputValue(element, regex) {
    if (element.val() != undefined) {
        // Numbers only
        element.val(element.val().replace(/[^\d]/,''));
    }
    var sufficientVolumeText = $j('.pump').find('.sufficient-volume-text');
    var pumpValue = element.val();
    var elementValue = element.val();

    if (elementValue != undefined && elementValue.trim() != '' && regex.test(elementValue)){
        if (pumpValue < minPumpValue) {
            element.closest('.wrapper').find('.limit-info').hide();
            element.closest('.wrapper').find('.consumption-warning1').show()
            element.closest('.wrapper').find('.consumption-warning2').hide();
            element.closest('.wrapper').find('.btn-red.continue').attr('disabled', true);
            element.closest('.form-group').find('.input-label').addClass('invalid');
        } else
        if (pumpValue > maxPumpValue) {
            element.closest('.wrapper').find('.limit-info').hide();
            element.closest('.wrapper').find('.consumption-warning2').show();
            element.closest('.wrapper').find('.consumption-warning1').hide();
            element.closest('.wrapper').find('.btn-red.continue').attr('disabled', true);
            element.closest('.form-group').find('.input-label').addClass('invalid');
        } else {
            element.closest('.wrapper').find('.limit-info').show();
            element.closest('.wrapper').find('.consumption-warning1').hide();
            element.closest('.wrapper').find('.consumption-warning2').hide();
            element.closest('.wrapper').find('.btn-red.continue').attr('disabled', false);
            element.closest('.form-group').find('.input-label').removeClass('invalid');
        }
    } else {
        element.closest('.wrapper').find('.limit-info').show();
        element.closest('.wrapper').find('.consumption-warning1').hide();
        element.closest('.wrapper').find('.consumption-warning2').hide();
        element.closest('.wrapper').find('.btn-red.continue').attr('disabled', true);
        element.closest('.form-group').find('.input-label').removeClass('invalid');
    }
}

function addTextIfPumpInputEntered(input, addText){
    if (input.val() == undefined) return;
    if(input.val().length > 0) {
        addText.show();
    }
    input.blur(function(){
        if(input.val().length === 0) {
            addText.hide();
        } else {
            addText.show();
        }
    });
    input.keyup(function(){
        if(input.val().length >= 0) {
            addText.show();
        } else {
            addText.hide();
        }
    });
    input.mousedown(function(){
        if(input.val().length >= 0) {
            addText.show();
        } else {
            addText.hide();
        }
    });
}

function validatePumpDetails() {
    var currentStepBlock = $j('.step-content .fuel-consumption');
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        goToOfferCreditLine();
        isValid = true;
    }

    var pumpValue = currentStepBlock.find('.pump').find('input').val();
    if(pumpValue < minPumpValue || pumpValue > maxPumpValue){
        isValid = false;
    }
    return isValid;
}

function validatePumpDetailsTest() {
    var currentStepBlock = $j('.step-content .fuel-consumption');
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        //goToOfferCreditLine();
        isValid = true;
    }

    var pumpValue = currentStepBlock.find('.pump').find('input').val();
    if(pumpValue < minPumpValue || pumpValue > maxPumpValue){
        isValid = false;
    }
    return isValid;
}

function validateCreditLimit(){
    var currentStepBlock = $j('.step-content .credit-line');
    var moveToNextStep = currentStepBlock.find($j('[id$="creditLimitInput"]'));
    var limit = (moveToNextStep.html() === '' ? 0 : parseInt(moveToNextStep.html()));
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var minCreditValue = parseInt($j('.slider-label-first').html());
    var maxCreditValue = parseInt($j('.slider-label-last').html());
    var isValid = false;
    if(!isNextStepDisabled){
        if(limit >= minCreditValue && limit <= maxCreditValue){
            goToCardsOrder();
            isValid = true;
        } else {
            moveToNextStep.closest('.form-group').find('.credit-limit-label').addClass('error-label');
            moveToNextStep.closest('.form-group').find('.invalid-feedback').show();
            moveToNextStep.closest('.wrapper').find('.btn-red').attr('disabled', true);
        }
    }

    var deposit = $j('.deposit-value').text();
    if (deposit != undefined && deposit != '') {
        analytics_PaymentMethodOnSelect('Lastschrift', '1');
    } else {
        analytics_PaymentMethodOnSelect('Lastschrift', '0');
    }
    
    return isValid;
}

function validateCreditLimitValue(inputElement) {
    var limitValue = (inputElement.html() === '' ? 0 : parseInt(inputElement.html()));
    var minCreditValue = parseInt($j('.slider-label-first').html());
    var maxCreditValue = parseInt($j('.slider-label-last').html());
    if (limitValue < minCreditValue || limitValue > maxCreditValue) {
        inputElement.closest('.form-group').find('.credit-limit-label').addClass('error-label');
        inputElement.closest('.form-group').find('.invalid-feedback').show();
        inputElement.closest('.wrapper').find('.btn-red').attr('disabled', true);
    } else {
        inputElement.closest('.form-group').find('.credit-limit-label').removeClass('error-label');
        inputElement.closest('.form-group').find('.invalid-feedback').hide();
        inputElement.closest('.wrapper').find('.btn-red').attr('disabled', false);
    }
}

function checkCardsCounter(){
    var currentStepBlock = $j('.step-content .cards-order');
    var isValid = false;
    var counter = parseInt($j('.cards-count input').val());
    var numberOfCards = $j('.diff-cards-category .cards-list').find('.card-item').size();

    if(numberOfCards > 1 && counter == 1) {
        $j('.b-nav-cards').find('.tab1').removeClass('active');
        $j('.b-nav-cards').find('.tab2').addClass('active');
    }
}

function checkEmbossingParams() {
    var content = $j('.step-content');
    var cardTechParamsBlock = content.find('.cards-tech-parameters');
    var cardEmbossingItems = cardTechParamsBlock.find('.cards-list .card-item');

    var selectedCardOwnerType = cardEmbossingItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
    var cardOwnerInput = cardEmbossingItems.find('.card-owner').find('input');
    if(cardOwnerInput.val() != '' && cardOwnerInput.val() != undefined){
        if(!(selectedCardOwnerType == undefined)){
            if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                validateCarNumber(cardOwnerInput, new RegExp(regs.carNumberFormat_BEFR));
                checkInputNotEmpty(cardOwnerInput);
            }
            if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                validateDriverName(cardOwnerInput, new RegExp(regs.embossingLetters));
                checkInputNotEmpty(cardOwnerInput);
            }
        }
    }
}

function validateEmbossingParams() {
    var currentStepBlock = $j('.step-content .cards-tech-parameters');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;

    var content = $j('.step-content');
    var cardEmbossingBlock = content.find('.cards-tech-parameters');
    var cardEmbossingItems = cardEmbossingBlock.find('.cards-list .card-item');

    var selectedCardOwnerType = cardEmbossingItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
    var cardOwnerInput = cardEmbossingItems.find('input');
    if(cardOwnerInput.val() != '' && cardOwnerInput.val() != undefined){
        if(!(selectedCardOwnerType == undefined)){
            if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                isValid = validateCarNumber(cardOwnerInput, new RegExp(regs.carNumberFormat_BEFR));
            }
            if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                isValid = validateDriverName(cardOwnerInput, new RegExp(regs.embossingLetters));
            }
        }
    }

    if(!isNextStepDisabled && isValid){
        saveTechParamForSingleCard();
    }
    return isValid;
}

function validateCarNumber(element, regex) {
    var isValid = false;
    var numLength = element.val().length;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback-car-number');
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(numLength >= 1 && numLength <= 9) {
            showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
            isValid = true;
        } else {
            showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
            isValid = false;
        }
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}

function validateDriverName(element, regex) {
    var isValid = false;
    var numLength = element.val().length;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback-driver');
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(numLength <= 16){
            showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
            isValid = true;
        } else {
            showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
            isValid = false;
        }
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}

function validatePaymentDirectDebit(){
     var currentStepBlock = $j('.step-content .payment-direct-debit');
     var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
     var isValid = false;
     if(!isNextStepDisabled){
         goToCongratulations();
         isValid = true;
     }
     return isValid;
}

function validateBankTransferNoDeposit(){
    var currentStepBlock = $j('.step-content .bank-transfer-no-deposit');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        goToCongratulations();
        isValid = true;
    }
    return isValid;
}

function validDirectDebitForm(block, paymentMethods){
    var methods = [];
    paymentMethods.each(function(){
        if($j(this).hasClass('active')){
            methods.push(true);
        } else {
            methods.push(false);
        }
    });

    var isAgreementChecked = block.find('input[type="checkbox"]').is(':checked');
    if(methods.includes(true) && isAgreementChecked){
        block.find('.btn-red').attr('disabled', false);
    } else {
        block.find('.btn-red').attr('disabled', true);
    }
}

function validBankTransferForm(block, paymentMethods, confirmedAgreements){
    var tempMethods = [];
    paymentMethods.each(function(){
        if($j(this).hasClass('active')){
            tempMethods.push(true);
        } else {
            tempMethods.push(false);
        }
    });

    if(tempMethods.includes(true)){
        if(confirmedAgreements.includes(false)){
            block.find('.btn-red.continue').attr('disabled', true);
        } else {
            block.find('.btn-red.continue').attr('disabled', false);
        }
    }
}

/*   ----------------------------
 *    Method to create the Slider
 *    ----------------------------
 *    PARAMETERS : "destination" = The Id of the div where the slider needs to be created
 *                 "dispOutput" = The Id of the div where the slider value needs to be displayed
 *                 "idInputHidden" = The Id of the apex inputHidden component
 *                 "startVal" = initial position of slider
 *                 "minVal", "maxVal" = minimum and maximum value of slider
 **/
function createSlider(destination, dispOutput, idInputHidden, startVal, minVal, maxVal){
    if (typeof $j('#' + destination).slider !== 'function') return;
    
    $j('#' + destination).slider({
        range: false,
        min: minVal,
        max: maxVal,
        values: [startVal],
        step: 100,
        slide: function(event, ui){
        //This function executes every time slider is moved and applies the slider values
        //to the input fields as well as the output below the slider
            $j('[id$=' + idInputHidden + ']').val(ui.values[0]);
            $j('[id$=' + dispOutput + ']').text(ui.values[0]);
            colorSliderActiveLine();
        },
        stop: function(event, ui){
            recalculateDeposit();
            colorSliderActiveLine();
        }
    });
    //write the initial value in the display div
    $j('[id$=" + dispOutput + "]').text(startVal);
}

function colorSliderActiveLine() {
    var sliderHandler = $j('#slider').find('.ui-slider-handle')[0];
    var sliderLeftWidth;
    if(sliderHandler != undefined){
        sliderLeftWidth = parseInt($j('#slider').find('.ui-slider-handle')[0].style.left.split('%')[0]);
        $j('#slider').find('.slider-active-line')[0].style.width = sliderLeftWidth + '%';
    }
}

function checkCounterValue(counter) {
    setTimeout(function(){
        if(counter.val() < 0) counter.val(0);
        if(counter.val() > 50) counter.val(50);
    }, 100);
}

function checkPumpValue(input){
    setTimeout(function(){
        if(input.val() > maxPumpValue) input.val(maxPumpValue);
    }, 100);
}

function changeLink(link){
    var destinationLink = $j(link).closest('.config');
    var currentActiveLink = destinationLink.closest('.config-list').find('.config.active');
    currentActiveLink.removeClass('active');
    destinationLink.addClass('active');
    return false;
}

function showInternationalTransactionInfo(isPumpOutsideOn) {
    if(!isPumpOutsideOn){
        $j('.wrapper.blue-block').find('#internationalTrans').hide();
    } else {
        $j('.wrapper.blue-block').find('#internationalTrans').show();
    }
}

function showFuelPartnerTransactionInfo(isPumpAtPartners) {
    if(!isPumpAtPartners){
        $j('.wrapper.blue-block').find('#partnerTrans').hide();
    } else {
        $j('.wrapper.blue-block').find('#partnerTrans').show();
    }
}

function showLocator(){
    var feeReducingBlock = $j('[id$="feesReducing"]');
    feeReducingBlock.find('.save-btn').find('.btn-red').attr('disabled', true);

    var allShellDiscountsBlock = $j('[id$="allShellDiscount"]');
    allShellDiscountsBlock.find('.save-btn').find('.btn-red').attr('disabled', true);
    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', false);
    specialOffersContinueBlock.find('.button-info').hide();
    return false;
}

function cancelLocator(){
    var feeReducingBlock = $j('[id$="feesReducing"]');
    feeReducingBlock.find('.save-btn').find('.btn-red').attr('disabled', false);

    var allShellDiscountsBlock = $j('[id$="allShellDiscount"]');
    allShellDiscountsBlock.find('.save-btn').find('.btn-red').attr('disabled', false);
    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', true);
    specialOffersContinueBlock.find('.button-info').show();
    var closeElement = $j('[id$="modalShowLocator"]');
    closeElement.hide();
    console.log('cancelLocator');
    return false;
}

function pickStation(){
    var specialOfferBlock = $j('[id$="chooseStation"]');
    var isButtonDisabled = specialOfferBlock.find('.btn-red.my-station').is('[disabled=disabled]');
    if(!isButtonDisabled){
        //$j('.b-locator').hide();
        specialOfferBlock.find('.offer-label .arrow-right').addClass('selected');
        specialOfferBlock.find('.offer-label .price-right').addClass('selected');
        specialOfferBlock.find('.save-station-btn').hide();
        var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
        specialOffersContinueBlock.find('.fav-station').hide();
    }

    var chooseStation = $j('[id$="chooseStation"]');
    chooseStation.find('.choose-station-btn').hide();
    //saveStation();
    var closeElement = $j('[id$="modalShowLocator"]');
    closeElement.hide();
    return false;
}

function cancelStationChoice(){
    var specialOfferBlock = $j('[id$="chooseStation"]');
    specialOfferBlock.find('.offer-label .arrow-right').removeClass('selected');
    specialOfferBlock.find('.offer-label .price-right').removeClass('selected');
    specialOfferBlock.find('.fav-station').hide();
    specialOfferBlock.find('.choose-station-btn').show();

    var feeReducingBlock = $j('[id$="feesReducing"]');
    feeReducingBlock.find('.save-btn').find('.btn-red').attr('disabled', false);
    var allShellDiscountsBlock = $j('[id$="allShellDiscount"]');
    allShellDiscountsBlock.find('.save-btn').find('.btn-red').attr('disabled', false);

    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', true);
    specialOffersContinueBlock.find('.button-info').show();
    var favoriteStationBlock = $j('.special-offers .offer').find('.fav-station').find('.point');
    favoriteStationBlock.find('.station').each(function(){
        $j(this).remove();
    });
    return false;
}

function asyncRemoveStation(){

}

function setShellDiscount(){
    var specialOfferBlock = $j('[id$="allShellDiscount"]');
    specialOfferBlock.find('.offer-label .arrow-right').addClass('selected');
    specialOfferBlock.find('.offer-label .price-right').addClass('selected');
    specialOfferBlock.find('.save-btn').hide();
    specialOfferBlock.find('.remove-btn').show();
    $j('.choose-station-btn').find('.btn-red').attr('disabled', true);
    var feeReducingBlock = $j('[id$="feesReducing"]');
    feeReducingBlock.find('.save-btn').find('.btn-red').attr('disabled', true);

    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', false);
    specialOffersContinueBlock.find('.button-info').hide();
    //setAllShellDiscounts();
    return false;
}

function cancelShellDiscount(){
    var specialOfferBlock = $j('[id$="allShellDiscount"]');
    specialOfferBlock.find('.offer-label .arrow-right').removeClass('selected');
    specialOfferBlock.find('.offer-label .price-right').removeClass('selected');
    specialOfferBlock.find('.save-btn').show();
    specialOfferBlock.find('.remove-btn').hide();
    $j('.choose-station-btn').find('.btn-red').attr('disabled', false);
    var feeReducingBlock = $j('[id$="feesReducing"]');
    feeReducingBlock.find('.save-btn').find('.btn-red').attr('disabled', false);

    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', true);
    specialOffersContinueBlock.find('.button-info').show();
    //removeShellDiscount();
    return false;
}

function setFeeReducingDiscount(){
    var specialOfferBlock = $j('[id$="feesReducing"]');
    specialOfferBlock.find('.offer-label .arrow-right').addClass('selected');
    specialOfferBlock.find('.offer-label .price-right').addClass('selected');
    specialOfferBlock.find('.save-btn').hide();
    specialOfferBlock.find('.remove-btn').show();
    $j('.choose-station-btn').find('.btn-red').attr('disabled', true);
    var allShellDiscountsBlock = $j('[id$="allShellDiscount"]');
    allShellDiscountsBlock.find('.save-btn').find('.btn-red').attr('disabled', true);

    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', false);
    specialOffersContinueBlock.find('.button-info').hide();
    //setFeesReduction();
    return false;
}

function cancelFeeReducingDiscount(){
    var specialOfferBlock = $j('[id$="feesReducing"]');
    specialOfferBlock.find('.offer-label .arrow-right').removeClass('selected');
    specialOfferBlock.find('.offer-label .price-right').removeClass('selected');
    specialOfferBlock.find('.save-btn').show();
    specialOfferBlock.find('.remove-btn').hide();
    $j('.choose-station-btn').find('.btn-red').attr('disabled', false);
    var allShellDiscountsBlock = $j('[id$="allShellDiscount"]');
    allShellDiscountsBlock.find('.save-btn').find('.btn-red').attr('disabled', false);

    var specialOffersContinueBlock = $j('[id$="specialOffersContinueBlock"]');
    specialOffersContinueBlock.find('.btn-red.continue').attr('disabled', true);
    specialOffersContinueBlock.find('.button-info').show();
    //removeFeesReduction();
    return false;
}

function enableDisableContinueButton() {
    var disabledButtons = $j('.cards-tech-parameters .cards-list .btn-done:disabled');
    if (disabledButtons.length == 0) {
        $j('.cards-tech-parameters .btn.continue').removeAttr('disabled');
    } else {
        $j('.cards-tech-parameters .btn.continue').attr('disabled', true);
    }
}

function counterLenCompanyName() {
    //var cardTechParamsItems =  $j('.cards-tech-parameters .cards-list .card-item');
    var cardTechParamsItems =  $j('.cards-order .cards-list .card-item');
    var companyName = cardTechParamsItems.find('.company-name').find('input')[0];
    if(!(companyName === undefined)){
        cardTechParamsItems.find('.company-name .len-company-name').text(companyName.value.length + '/' + companyName.maxLength);
    }

    cardTechParamsItems.find('.company-name').on('keyup', function() {
        cardTechParamsItems.find('.company-name .len-company-name').text(companyName.value.length + '/' + companyName.maxLength);
    });
}

function printDocument(frameName) {
    //window.frames[frameName].print();
}

function printPaymentInformation(){
    var divToPrint = document.getElementById('paymentInformation');
    var htmlTemplate = '<html><body onload="window.print()">' + divToPrint.innerHTML + '</body></html>'
    var newWin = window.open('','Payment Information');
    newWin.document.open();
    newWin.document.write(htmlTemplate);
    newWin.document.close();
    setTimeout(function(){
        newWin.close();
    }, 10);
}

/* IMPORTANT!!! This is for event functions on blocks (should recall on complete methods when blocks are rerendering) */
function onPageLoad(){
    /* GENERAL EVENTS */

    // Create range slider
    createSlider('slider', 'creditLimitInput', 'idInputHidden', 100, 100, 600);
    if($j('#slider').find('.slider-active-line').length == 0) {
    $j('#slider').append('<div class="slider-active-line" style="width:0%"></div>');
                    }

    // Switchers event
    var switchBlocks = $j('.b-switch-block');
    switchBlocks.each(function(){
        var switcher = $j(this).find('.onoffswitch .onoffswitch-checkbox');
        if(!switcher.is(':checked')){
            $j(this).css('background', '#f6f6f6');
        }
    });

    $j('.onoffswitch .onoffswitch-checkbox').on('click', function(){
        var switchBlock = $j(this).parents().closest('.b-switch-block');
        if($j(this).is(':checked')){
            switchBlock.css('background', '#cecece');
            switchBlock.find('.onoffswitch-switch').css({ 'margin': '8px', 'background': '#ffffff' });
        } else {
            switchBlock.css('background', '#f6f6f6');
            switchBlock.find('.onoffswitch-switch').css({ 'margin': '8px', 'background': '#cecece' });
        }
    });


    // Collapse details block event
    $j('.collapse-block .link').on('click', function(){
        var detailsBlock = $j(this).parent().find('.row');
        var collapseBlock = $j(this).find('.expander');
        if(detailsBlock.is(':hidden')){
            collapseBlock.removeClass('block-expand').addClass('block-collapse');
        } else {
            collapseBlock.removeClass('block-collapse').addClass('block-expand');
        }
    });
}

function onPageRender() {
    $j('[data-toggle="popover"]').popover({
        html : true,
        sanitize : false,
        animation : false,
        title : '<a href="#" style="color: grey;font-size: 25px;line-height: 20px;" data-dismiss="alert">&times;</a>'
    });
    $j('[data-toggle=popover]').on('shown.bs.popover', function () {
        $j('.popover .arrow').css('left', $j(this).offset().left + 7);
        $j('.popover').css('width', $j(window).width());
        $j('.popover .popover-content').css('width', $j(window).width());        
        $j('.popover').css('left', '0');        
    });
    scrollToTopEvent();
}


function changeFieldsInSepa(accHolder, iban, swift, frameID) {
    var sepaFrame = document.getElementById(frameID);
    var sepaFrameDocument = (sepaFrame.contentWindow || sepaFrame.contentDocument);
    if (sepaFrameDocument.document) {
        sepaFrameDocument = sepaFrameDocument.document;
        var dynamicAccountHolder = sepaFrameDocument.getElementById('frameAccountHolder');
        dynamicAccountHolder.innerHTML = accHolder;
        var dynamicIBAN = sepaFrameDocument.getElementById('frameSepaIBAN');
        dynamicIBAN.innerHTML = iban;
        if (swift != undefined) {
            var dynamicSWIFT = sepaFrameDocument.getElementById('frameSepaSWIFT');
            dynamicSWIFT.innerHTML = swift;
        }
    }
}

function setChatOptions(){

    //First chat init
    setupChatInit();
    //Event to reset active form  for client on form (auto chat call)
    $j(document).on('keydown click', function(){resetInActive()});

    //First reset form inactive
    resetInActive();

    //press "Enter" event on offline chat form
    document.getElementById('liveAgentChatTextArea').onkeydown = function(event){
        if(event.keyCode==13){
            updateOfflineChat();
            return false;
        }
    };

    //add language parameter to online chat form submit
    var country = 'Belgium-FR'
    var elementBody = $j('.modal-open');
    elementBody.bind('DOMSubtreeModified', function(){
        var elementForms = document.getElementsByTagName('form');
        for (var i = 0; i < elementForms.length; i++) {
            if (elementForms[i].target == 'frameChat'){
                if (elementForms[i].action.toString().indexOf('language%3D%23') != -1){
                    elementForms[i].action = elementForms[i].action.replace('language%3D','language%3D'+country);
                }
            }
        }
    });

    if(screen.width < 1199){
        $j('#liveAgentChatLog').height(screen.height*0.5 - 160);
        $j('.chat-box').height(screen.height*0.5 - 25);
    } else {
        //events to offline textarea
        $j('.liveAgentSendButton').hide();
        $j('#liveAgentChatTextArea').focus(function(event){
            if(!$j('.liveAgentSendButton').is(":visible")){
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()-20);
                $j('#liveAgentChatTextArea').height($j('#liveAgentChatTextArea').height()+15);
                $j('.liveAgentSendButton').show();
            }
        });
        $j('#liveAgentChatTextArea').focusout(function(event){
            if($j(event.relatedTarget).hasClass('liveAgentSendButton')){
                 $j('.liveAgentSendButton').show();
            }
            else {
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()+20);
                $j('#liveAgentChatTextArea').height($j('#liveAgentChatTextArea').height()-15);
                $j('.liveAgentSendButton').hide();
            }
        });
    }

    $j(".liveAgentSendButton").mousedown(function() {
        return false;
    });
}

function setupChatInitialization(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode){
    if(activeStep.toString() == '0'){
        document.getElementById("chat-button-online").style.visibility = "hidden";
        document.getElementById("chat-button-offline").style.visibility = "hidden";
    }
    liveagent.disconnect();
    if (opportunityID != ''){
        liveagent.addCustomDetail("OpportunityID", opportunityID, false).saveToTranscript('Opportunity__c');
        liveagent.findOrCreate("Opportunity").map("ID","OpportunityID",true,true,true).saveToTranscript("OpportunityId").showOnCreate();
        liveagent.addCustomDetail("AccountID", accountID, false).saveToTranscript('AccountID');
        liveagent.findOrCreate("Account").map("ID","AccountID",true,true,true).saveToTranscript("AccountId").showOnCreate();
    }
    if (contactID != ''){
        liveagent.addCustomDetail("ContactID", contactID, false).saveToTranscript('ContactID');
        liveagent.findOrCreate("Contact").map("ID","ContactID",true,true,true).saveToTranscript("ContactId").showOnCreate();
    }
    liveagent.setName(chatFirstMessage);
    liveagent.addCustomDetail("Step", activeStep + ' ' + activeSubStep , false).saveToTranscript('E2E_Step__c');
    liveagent.addCustomDetail("Mode of initialization", mode, false).saveToTranscript('Mode_of_initialization__c');
    liveagent.addCustomDetail("Type of chat", 'online', false).saveToTranscript('Type__c');
    liveagent.init(urlChat, deploymentID, organizationID);
     //Start initialization button for visible online/offline chat
    if(buttonID != ''){
        if (!window._laq) { window._laq = []; }
        window._laq.push(function(){
            liveagent.showWhenOnline(buttonID, document.getElementById("chat-button-online"));
            liveagent.showWhenOffline(buttonID, document.getElementById("chat-button-offline"));
        });
    }
}

function startOnlineChat(urlChat, deploymentID, deploymentJsURL, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode){
    if(mode == 'automatical'){
        if(autoChatLastStep != activeSubStep){
            autoChatLastStep = activeSubStep;
            delete liveagent;
            delete liveAgentDeployment;
            jQuery.loadScript(deploymentJsURL, function() {
                executeOnlineChat(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode);
            });
        }
    }
    else {
        delete liveagent;
        delete liveAgentDeployment;
        jQuery.loadScript(deploymentJsURL, function() {
            executeOnlineChat(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode);
        });
    }
}

jQuery.loadScript = function (url, callback) {
    jQuery.ajax({ url: url,  dataType: 'script', success: callback,  async: true });
};

function executeOnlineChat(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode){
    var frameChat = document.getElementById("frameChat");
    if (frameChat != null) frameChat.remove();
    if ((document.getElementById("frameChat") == null) && (document.getElementById('chat-button-online').style.display != 'none')) {
        document.getElementById('chat-button-offline').style.visibility = 'hidden';
        document.getElementById('chat-button-online').style.visibility = 'hidden';
        setupChatInitialization(urlChat, deploymentID, organizationID, '', contactID, opportunityID, accountID, chatFirstMessage, activeStep, activeSubStep, mode);
        var frameChat = document.createElement("iframe");
        frameChat.id = 'frameChat';
        frameChat.name = 'frameChat';
        frameChat.classList.add('frameChat');
        document.getElementById("chatOnlineBlock").appendChild(frameChat);
        setTimeout(function startChatWithWindow() {
                       try {
                          liveagent.startChatWithWindow(buttonID,'frameChat');
                          document.getElementById('chatOnlineBlock').classList.add('popup-on');
                          executeSetOpportunityFlagChat(mode);
                       }
                       catch (err){
                          document.getElementById('chat-button-offline').style.visibility = 'visible';
                          document.getElementById('chat-button-online').style.visibility = 'visible';
                          document.getElementById('chatOnlineBlock').classList.remove('popup-on');
                          var frameChat = document.getElementById("frameChat");
                          frameChat.remove();
                          var frameChatForms = document.getElementsByTagName('form');
                          for(var i=0; i< frameChatForms.length; i++){
                             if(frameChatForms[i].target == 'frameChat'){
                                  frameChatForms[i].remove();
                             }
                          }
                       }
                  }, 800);
    }
}

function resetInActive(){
    clearTimeout(chatActivityTimeout);
    chatActivityTimeout = setTimeout(inActive, 60000);
}

function inActive(){
    var chatOnlineButton =  document.getElementById('chat-button-online');
    if ((chatOnlineButton.style.display != 'none') && (chatOnlineButton.style.visibility != 'hidden')){
        var frameChatOnline = document.getElementById('frameChat');
        if((frameChatOnline == null) && !($j('#chatOfflineBlock').hasClass('popup-on'))){
            setupOnlineAutoChat();
        }
    }
    resetInActive();
}

function setupOfflineChat(){
    document.getElementById('chat-button-offline').style.visibility = 'hidden';
    document.getElementById('chat-button-online').style.visibility = 'hidden';
    var chatLog = document.getElementById("liveAgentChatLog");
    document.getElementById('chatOfflineBlock').classList.add('popup-on');
    chatLog.scrollTop = chatLog.scrollHeight;
    chatOfflineOLDText = '';
    chatOfflineUpdateTimeout = setTimeout(updateDatabaseOfflineChat, 5000);
}

function updateOfflineChat(){
    var chatTextArea = document.getElementById('liveAgentChatTextArea');
    if (chatTextArea.value != ''){
        var chatLog = document.getElementById('liveAgentChatLogText');
        var currentDate = new Date();
        var hours = currentDate.getHours();
        var minutes = currentDate.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        chatLog.innerHTML = chatLog.innerHTML + '<span class="chat-client"> <span class="chat-name"> <strong>You </strong>' +
        '<span class="chat-customDateTime" style="display: inline"> ' + strTime + ' </span> </span> <span class="chat-messageText">'+chatTextArea.value+'</span> <span>';
        chatTextArea.value = '';
    }
    var chatLog = document.getElementById("liveAgentChatLog");
    chatLog.scrollTop = chatLog.scrollHeight;
}

function updateDatabaseOfflineChat(){
    var chatLogDbUpdate = $j('.liveAgentChatLogText').html().split('<span class="chat-operator">').join('<br><span class="chat-operator">').split('<span class="chat-client">').join('<br><span class="chat-client">');
    if (chatLogDbUpdate != chatOfflineOLDText){
        chatOfflineOLDText = chatLogDbUpdate;
        executeSaveOfflineChat(chatLogDbUpdate);
        executeSetOpportunityFlagChat('manual');
    }
    clearTimeout(chatOfflineUpdateTimeout);
    chatOfflineUpdateTimeout = setTimeout(updateDatabaseOfflineChat, 5000);
}


function closeChat(status){
    if (status == 'online'){
        document.getElementById('chatOnlineBlock').classList.remove('popup-on');
        var frameChat = document.getElementById("frameChat");
        frameChat.contentWindow.postMessage('closeChatFLEETCOR', '*');
        var frameChatForms = document.getElementsByTagName('form');
        for(var i=0; i< frameChatForms.length; i++){
            if(frameChatForms[i].target == 'frameChat'){
                frameChatForms[i].remove();
            }
        }
    }
    else if (status == 'offline'){
        document.getElementById('chatOfflineBlock').classList.remove('popup-on');
    }
    document.getElementById('chat-button-offline').style.visibility = 'visible';
    document.getElementById('chat-button-online').style.visibility = 'visible';
    resetInActive();
}


function  startPayment(block){
    var currentStepBlock = $j('.step-content .' + block);
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    var form = document.getElementById("paymentFormToSubmit");
    if(!isNextStepDisabled){
        form.submit();
        isValid = true;
    }
    return isValid;
}

function updatePaymentMethod(input, textId) {
    var radioBtn = document.getElementById(textId);
    if (radioBtn != null){
       radioBtn.value = input.value;
       changeMethod();
    }
}

function scrollToTopEvent() {
    $j('#top, #order').click(function () {
        $j('body, html').animate({
            scrollTop: 0
        }, 800);
        return false;
    });
}

function validateVatNumber(element, regex) {
    var isValid = false;
    var vatNumberSize = element.val().length;
    var elementValue = element.val();
    var invalidFeedbackElement = element.closest('.form-group').find('.invalid-feedback');
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(vatNumberSize == 14){
            showOrHideInvalidMessage(invalidMessageEvents[0], element, invalidFeedbackElement);
            isValid = true;
        } else {
            showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
            isValid = false;
        }
    } else {
        showOrHideInvalidMessage(invalidMessageEvents[1], element, invalidFeedbackElement);
        isValid = false;
    }
    return isValid;
}

function validateIBAN() {
    startSplash();
    jsValidateIBAN();
}

function validatePaymentDirectDebit(){
    var currentStepBlock = $j('.step-content .payment-direct-debit');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    if( ! isNextStepDisabled ) {
        goToCongratulations();
        isValid = true;
    }
    return isValid;
}

function toViewPortCreditScoring() {
    if ( ! isPrivateEntity ) {
        toViewport('order-details-viewport');
    }
}

function toViewport(id){
    document.querySelector('#'+id).scrollIntoView();
}

//Function is used to get splash status bar when server side call is going on
function startSplash() {
    document.getElementById('splashDiv').style.display='table-cell';
    $j('.lightbox').fadeIn(50);
}

//Function will make the splash status to be stopped.
function endSplash() {
    document.getElementById('splashDiv').style.display='none';
    $j('.lightbox').fadeOut(50);
}

function getAllUrlParams(url) {
  var queryString = url ? url.split('?')[1] : window.location.search.slice(1);
  var obj = {};
  if (queryString) {
    queryString = queryString.split('#')[0];
    var arr = queryString.split('&');
    for (var i=0; i<arr.length; i++) {
      var a = arr[i].split('=');

      var paramNum = undefined;
      var paramName = a[0].replace(/\[\d*\]/, function(v) {
        paramNum = v.slice(1,-1);
        return '';
      });

      var paramValue = typeof(a[1])==='undefined' ? true : a[1];

      if (obj[paramName]) {
        if (typeof obj[paramName] === 'string') {
          obj[paramName] = [obj[paramName]];
        }
        if (typeof paramNum === 'undefined') {
          obj[paramName].push(paramValue);
        }
        else {
          obj[paramName][paramNum] = paramValue;
        }
      }
      else {
        obj[paramName] = paramValue;
      }
    }
  }
  return obj;
}

function increaseCreditLimit() {
    var currentLimit = parseInt($j('[id$=idInputHidden]').val());
    if (!isNaN(currentLimit)) {
        setNewCreditLimit(currentLimit + 100);
    }
}

function decreaseCreditLimit() {
var currentLimit = parseInt($j('[id$=idInputHidden]').val());
    if (!isNaN(currentLimit)) {
        setNewCreditLimit(currentLimit - 100);
    }
}

function setNewCreditLimit(limit) {
    $j('[id$=idInputHidden]').val(limit);
    $j('[id$=creditLimitInput]').text(limit);
    $j('#slider').slider("values", [limit]);
    colorSliderActiveLine();
    recalculateDeposit();
}
