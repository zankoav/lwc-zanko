$j = jQuery.noConflict();

var regs = {
    phone: /^([0-9+]{11,12})+$/,
    numbers: /^[0-9]+$/,
    taxid: /^([0-9]{8}[-]{1}[1-5]{1}[-]{1}[0-9]{2})+$/,
    letters: /^[a-zA-ZÀ-ž\x7f-\xff\s'-]+$/,
    lettersAndNumbers: /^[0-9a-zA-ZÀ-ž\x7f-\xff\s'&.,-]+$/,
    embossingLetters: /^[a-zA-Z\s]+$/, // letters for embossing on card (important for GFN)
    embossingLettersAndNumbers: /^[0-9a-zA-Z\s]+$/, // letters and numbers for embossing on card (important for GFN)
    //email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/ //old version//
    email: /^\w+([.-]\w+)*@\w+([.-]\w+)*(\.\w{2,4})+$/,
    /*carNumberFormat_NL: /^[0-9A-Za-z]{1,3}\-?\s?[A-Za-z]{0,3}\-?\s?[0-9]{1,4}[H]{0,1}/, //old version*/
    // carNumberFormat_NL: /^[bdfghjklmnprstvwxyzBDFGHJKLMNPRSTVWXYZ0-9]{1,2}-[bdfghjklmnprstvwxyzBDFGHJKLMNPRSTVWXYZ0-9]{2,3}-[bdfghjklmnprstvwxyzBDFGHJKLMNPRSTVWXYZ0-9]{1,2}/,
    carNumberFormat_NL: /^[A-Za-z0-9]{1,2}-[A-Za-z0-9]{2,3}-[A-Za-z0-9]{1,2}/,
    swiftFormat: /^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$/,
    ibanFormat_NL: /^[Nn]{1}[Ll]{1}[0-9]{2}[A-Za-z]{4}[0-9]{10}?$/,
    vatIdFormat_NL: /^([Nn]{1}[Ll]{1}[0-9]{9}[Bb]{1}[0-9]{2})+$/,
    dateOfBirth: /^[0-9]{2}[.]{1}[0-9]{2}[.]{1}[0-9]{4}?$/
};
var chatActivityTimeout;
var chatOfflineUpdateTimeout;
var chatOfflineOLDText;
var chatDeviceHeight;

var minPumpValue = 75;
var maxPumpValue = 50000;
var autoChatLastStep;
var isPrivateEntity;

var dataSource = 'eurolocator.fleetcor.hu';
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
    } else if (activeStep == 1 && (activeSubStep == 'Enter Tax ID' || activeSubStep == 'Set total consumption')) {
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
    var phoneContactAgreement = contactDetailsStepBlock.find('.form-check-input.phoneContact');
    var infoByEmailAgreement = contactDetailsStepBlock.find('.form-check-input.infoByEmail');
    var contactDetails_requiredInputs = contactDetailsStepBlock.find('.form-control.required');

    // Validate if fields are not empty    
    $j(contactDetailsStepBlock).find('input:text').each(function(){
        checkInputNotEmpty( $j(this) );
        if ( $j(this).attr('id').indexOf('phone') >= 0) {
            // $j(this).inputmask({mask:"+3\\6999999999", "placeholder": "" });
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
    if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);

    // <<< END ONLOAD OR ON BACK TO THIS STEP <<<

    // >>> START ELEMENTS EVENTS >>>

    // Add validation on "input" event for required fields.
    // First and Last names should contain english + german letters.
    // Phone should start from +49, 13-15 numbers.
    // Email should be in valid format.
    contactDetails_requiredInputs.each(function(){
        if ( $j(this).attr('id').indexOf('firstName') >= 0) {
            $j(this).on('input', function (e) {
                isInputValueValid($j(this), new RegExp(regs.letters));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('lastName') >= 0 ) {
            $j(this).on('input', function (e) {
                isInputValueValid($j(this), new RegExp(regs.letters));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('phone') >= 0) {
            $j(this).on('input', function (e) {
                isInputValueValid($j(this), new RegExp(regs.phone));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('email') >= 0) {
            $j(this).on('input', function (e) {
                isInputValueValid($j(this), new RegExp(regs.email));
                checkInputNotEmpty($j(this));
                checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
                if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
            });
        } else
        if ( $j(this).attr('id').indexOf('numberofcardscontactdetails') >= 0) {
            $j(this).on('input', function (e) {
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
    phoneContactAgreement.on('click', function() {
        checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
        if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
    });

    infoByEmailAgreement.on('click', function() {
        checkRequiredFieldsAndToggleButton(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
        if ( ! phoneContactAgreement.is(':checked') || ! infoByEmailAgreement.is(':checked') ) contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
    });
    // <<< END ELEMENTS EVENTS <<<
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
    isValid = validatedFields.includes(false) ? false : true;

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
        step: 10000,
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

function enableDisableContinueButton() {
    var disabledButtons = $j('.cards-tech-parameters .cards-list .btn-done:disabled');
    if (disabledButtons.length == 0) {
        $j('.cards-tech-parameters .btn.continue').removeAttr('disabled');
    } else {
        $j('.cards-tech-parameters .btn.continue').attr('disabled', true);
    }
}

/* IMPORTANT!!! This is for event functions on blocks (should recall on complete methods when blocks are rerendering) */
function onPageLoad(){
    /* GENERAL EVENTS */

    // Create range slider
    createSlider('slider', 'creditLimitInput', 'idInputHidden', 100, 100, 600);
    if ($j('#slider').find('.slider-active-line').length == 0) {
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
    var country = 'Hungary';
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

    var country = 'Hungary';
    liveagent.addCustomDetail("Chat country", country, false).saveToTranscript('Country__c');
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

function scrollToTopEvent() {
    $j('#top, #order').click(function () {
        $j('body, html').animate({
            scrollTop: 0
        }, 800);
        return false;
    });
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