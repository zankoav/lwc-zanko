$j = jQuery.noConflict();

var apiTokenDaData = "ac4d32571890162a53f3f4fe0537841d1bd0c173";
var pattern = /^([a-z0-9_\.-])+@[a-z0-9-]+\.([a-z]{2,4}\.)?[a-z]{2,4}$/i;

var tabActive = false;

var chatActivityTimeout;
var chatOfflineUpdateTimeout;
var chatOfflineOLDText;
var autoChatLastStep;
var autoChatTimeOut;

var cardPrevCount = 0;

var regs = {
    phone: /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/,
    inn: /^\d{10}|\d{12}$/,
    email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/,
    companyName: /^[0-9a-zA-Zа-яА-ЯёЁ\w"\s"'`/()&@,;!?$#№%.+-]+$/,
    numbers: /^[0-9]+$/,
    letters: /^[а-яА-ЯёЁ\s'-]+$/,
    address: /^[0-9а-яА-ЯёЁIVX\s,.'"\/()-]+$/,
    bankName: /^[0-9nN№а-яА-ЯёЁ\s."'()!-]+$/,
    position: /^[а-яА-Я\s.'-]+$/,
    codeWord: /^[а-яА-ЯёЁ]+$/,
    passportCode: /^(\d{3})([\-]{1})(\d{3})$/,
    date: /^(0[1-9]|[12][0-9]|3[01])[.](0[1-9]|1[012])[.](19|20)\d\d$/
};

$j(document).ready(function(){

    //setStartParameters();
    //setStartStep();

    $('html').attr('lang', 'ru');

    var query = getQueryParams(document.location.search);

    if(query.link == undefined){
        setActiveStep('ContactDetails');
    } else {
        setStartStep();
    }

    setEvents_ContactDetails();

    setEvents_companyDetails();
    switchDaDaOn();

    setEvents_order();

    setEvents_summaryOrder();

    setEvents_legalDetails();

    setEvents_paymentDetails();

 /*   $j(".close").on("click" , function(){
        var thisBlock = $j(this);
        thisBlock.closest(".block__inputs").removeClass("error");
        thisBlock.closest(".block__inputs").find("input").val("");
        thisBlock.closest(".block__inputs").find("input").focus()
    });

    $j(".js-count-cart").on("keyup" , function(){
        if($j(this).val().length > 0) {
            $j(".stetps__blocks_hide").slideDown().addClass("active")
        }
    });

    $j(".js-goods-order").on("click" , function(){
        if($j('input[name=tariff]:checked').val() != undefined) {
            $j(".js-past-tariff").val($j('input[name=tariff]:checked').val())
        }
        if($j(this).closest(".stetps__blocks-content").find("input[type='checkbox']:checked").length == 0) {
            $j(".dop__services").addClass("none")
        }
        else {
            $j(this).closest(".stetps__blocks-content").find("input[type='checkbox']:checked").each(function(){
                $j(".dop__services").find(".values." + $j(this).closest(".block_checkbox").data("name")).removeClass("none")
            });
        }

        $j(".js-past-cart").val($j(".js-count-cart").val())
        $j(".step-3-1").slideUp()
        $j(".step-3-2").removeClass("none")
    });

    $j(".js-end-order").on("click" , function(){
        $j(this).hide();
        $j(this).closest(".stetps__blocks-footer").find(".goods_data").show();
        setTimeout(function(){
            $j(".step-order-information .stetps__blocks_container").slideUp().removeClass("current");
            $j(".step-4 .stetps__blocks_container").slideDown().addClass("current active");
        } , 2000)
    });

    $j(".js-tooltips-text").each(function(){
        $j(this).css("top" , "-"+$j(this).outerHeight()-20 +"px");
    });

    if ($j(document).height() > $j(window).height()) {
         $j('footer').css('position', 'relative');
    } else {
        $j('footer').css('position', 'absolute');
    } */

    setChatOptions();
    var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    if(isMobile == true){
        setDeviceType("Mobile");
    } else {
        setDeviceType("Desktop");
    };
});

function getQueryParams(qs) {
    qs = qs.split('+').join(' ');
    var params = {},
        tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;
    while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
    }
    return params;
}

function footerPosition(){
    if ($j(document).height() >= $j(window).height()) {
         $j('footer').css('position', 'relative');
    } else {
        $j('footer').css('position', 'absolute');
    }
}

function tog(v){
    return v?'addClass':'removeClass';
}

function eraseInputValue(stepClass){
    $('.' + stepClass).on('input', '.clearable', function(){
        $(this)[tog(this.value)]('x');
        if($(this).closest(".block__inputs").hasClass('goods')){
            $(this).removeClass('x');
        }
    }).on('mousemove', '.x', function( e ){
        $(this)[tog(this.offsetWidth-35 < e.clientX-this.getBoundingClientRect().left && e.clientX-this.getBoundingClientRect().left < this.offsetWidth-22)]('onX');
    }).on('touchstart click', '.onX', function( ev ){
        ev.preventDefault();
        $(this).removeClass('x onX').val('').change();
    });

    $('.' + stepClass + ' .clearable').blur(function(){
    	$(this).removeClass('x');
    });

    $('.' + stepClass + ' .clearable').focus(function(){
        if($(this).val().length !=0 && $(this).closest(".block__inputs").hasClass('goods') == false){
            $(this).addClass('x');
        }
    });
}

function scrollToTopInput(block){
    var inputsFirstErrorBlock = block[0];
    if ( !isScrolledIntoView(inputsFirstErrorBlock) ){
        inputsFirstErrorBlock.scrollIntoView();
    }
}

function isScrolledIntoView(elem) {
   var docViewTop = $j(window).scrollTop();
   var docViewBottom = docViewTop + $j(window).height();

   var elemTop = $j(elem).offset().top;
   var elemBottom = elemTop + $j(elem).height();

   return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
}

function noScrollBackground(){
    $('html, body').css({
        overflow: 'hidden',
        height: 'auto'
    });
    $("body").css("padding-right", "17px");
}

function modalOpen(modal) {
    $( "#"+modal ).on('show.bs.modal', function(){
        $('html, body').css({
            overflow: 'hidden',
            height: 'auto'
        });
        $("body").css("padding-right", "17px");
    });
}

function modalClose(modal) {
    $( "#"+modal ).on('hidden.bs.modal', function(){
        $('html, body').css({
            overflow: '',
            height: ''
        });
        $("body").css("padding-right", "");
    });
}

function checkPersonalDataAgreement(){
    var element = $j('.step-contact-details').find('.personal_data_agreement');
    var isValid = element.is(":checked");
    if(!isValid){
        element.closest(".block__inputs").addClass("error");
    }
}

function isCheckBoxChecked(element){
    return element.is(":checked");
}

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.closest(".block__inputs").removeClass("error");
        element.closest(".block__inputs").addClass("goods");
        isValid = true;
    } else {
        element.closest(".block__inputs").removeClass("goods");
        element.closest(".block__inputs").addClass("error");
        isValid = false;
    }
    return isValid;
}

function isInputValueValidOnInput(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.closest(".block__inputs").addClass("goods");
        element.closest(".block__inputs").removeClass("error");
        isValid = true;
    } else {
        element.closest(".block__inputs").removeClass("goods");
        isValid = false;
    }
    return isValid;
}

function checkInputLengthOnInput(inputName, inputLength){
    if($j("."+inputName).val().length != inputLength) {
        $j("."+inputName).closest(".block__inputs").removeClass("goods");
    }
    else {
        $j("."+inputName).closest(".block__inputs").addClass("goods");
    }
}

function animateScrollToNextBlock(id){
    var element = document.querySelector("#"+id);
    element.scrollIntoView();
}

function animateScrollToTop(id){
    var element = document.querySelector("."+id);
    element.scrollIntoView();
}

function setActiveStep(activeStep){
    if(activeStep == 'ContactDetails'){
        $j(".step-company-information .stetps__blocks_container").slideUp();
        $j(".step-contact-details .stetps__blocks_container").slideDown();

        $j('.step-contact-details .headers__stepts').addClass("header-is-active");
        $j('.step-contact-details.stetps__blocks').addClass("active current");

        $j('.step-company-information .headers__stepts').removeClass("header-is-active");
        $j('.step-company-information.stetps__blocks').removeClass("active current");

        $j(".ordering__steps-item.ordering__steps-step").removeClass("active");
    }
    else if (activeStep == 'CompanyInformation'){
        $j(".step-company-information .stetps__blocks_container").slideDown();
        $j(".step-contact-details .stetps__blocks_container").slideUp();
        $j(".stetps__blocks_container.step-3-1").slideUp();

        $j('.step-contact-details .headers__stepts').addClass("header-is-active");
        $j('.step-contact-details.stetps__blocks').removeClass("active current");

        $j('.step-company-information .headers__stepts').addClass("header-is-active");
        $j('.step-company-information.stetps__blocks').addClass("active current");

        $j('.step-order-information.stetps__blocks').removeClass("active current");
        $j('.step-order-information .headers__stepts').removeClass("header-is-active");
    }
    else if (activeStep == 'Order'){
        $j('.step-company-information .stetps__blocks_container').slideUp();

        $j('.step-company-information.stetps__blocks').removeClass("active current");
        $j('.step-order-information.stetps__blocks').addClass("active current");
        $j(".stetps__blocks_container.step-3-2").slideUp();
        $j(".stetps__blocks_container.step-3-1").slideDown();

        $j('.step-legal-and-payment-details .headers__stepts').removeClass('header-is-active');
    }
    else if (activeStep == 'SummaryOrder'){
        $j('.step-company-information.stetps__blocks').removeClass("active current");
        $j('.step-order-information.stetps__blocks').addClass("active current");
        $j('.step-legal-and-payment-details.stetps__blocks').removeClass("active current");
        $j('.step-legal-and-payment-details .headers__stepts').removeClass('header-is-active');
        $j(".stetps__blocks_container.step-3-1").slideUp();
        $j(".step-legal-details").slideUp();
        $j(".stetps__blocks_container.step-3-2").slideDown();
    }
    else if (activeStep == 'LegalDetails'){
        $j('.step-order-information.stetps__blocks').removeClass("active current");
        $j('.step-legal-and-payment-details.stetps__blocks').addClass("active current");
        $j(".step-legal-details").slideDown();
        $j(".step-payment-details").slideUp();
        $j(".stetps__blocks_container.step-3-2").slideUp();
    }
    else if (activeStep == 'PaymentDetails'){
        $j('.step-order-information.stetps__blocks').removeClass("active current");
        $j('.step-legal-and-payment-details.stetps__blocks').addClass("active current");
        $j(".step-legal-details").slideUp();
        $j(".step-congratulations").slideUp();
        $j(".step-payment-details").slideDown();
    }
    else if (activeStep == 'Congratulations'){
        $j('.step-congratulations.stetps__blocks').addClass("active current");
        $j('.step-legal-and-payment-details.stetps__blocks').removeClass("active current");
        $j('.step-company-information .headers__stepts').addClass("header-is-active");
        $j('.step-congratulations .headers__stepts').addClass("header-is-active");
    }
    else if (activeStep == 'ErrorMessage'){
        $j('.step-legal-and-payment-details.stetps__blocks').hide();
        $j('.step-company-information.stetps__blocks').hide();
        $j('.step-contact-details.stetps__blocks').hide();
        $j('.step-order-information.stetps__blocks').hide();
        $j('.step-congratulations').hide();
    }
    return false;
}

function checkInputLength(inputName, inputLength){
    $j("."+inputName).blur(function(){
        if($j("."+inputName).val().length != inputLength) {
            $j("."+inputName).closest(".block__inputs").addClass("error").removeClass("goods");
        }
        else {
            $j("."+inputName).closest(".block__inputs").addClass("goods").removeClass("error");
        }
    });
}

function checkForAutoPasteNumericValues(block){
    $j("."+block).bind("paste", function(event) {
        var self = this;
        var origin = $j(self).val();
        setTimeout(function() {
            var val = $j(self).val();
            if($.isNumeric(val)){
            }
            else {
                 $j("."+block).val(origin);
            }
        }, 0);
    });
}

function checkForAutoPasteValues(block, regex){
    $j("."+block).bind("paste", function(event) {
        var self = this;
        var origin = $j(self).val();
        setTimeout(function() {
            var val = $j(self).val();
            if(regex.test(val)){
            }
            else {
                 $j("."+block).val(origin);
            }
        }, 0);
    });
}

    //  Enter numbers only
function keyDownNumeric(block){
    $j('.'+block).on('keydown' , function (event) {
        if ($.inArray(event.keyCode, [46, 8, 9, 27, 13]) !== -1 ||                         // backspace, delete, tab, escape, enter and .
            (event.keyCode === 65 && (event.ctrlKey === true || event.metaKey === true)) ||         // Ctrl+A, Command+A
            (event.keyCode === 86 && (event.ctrlKey === true || event.metaKey === true)) ||         // Ctrl+V, Command+V
            (event.keyCode >= 35 && event.keyCode <= 40)) {                                     // home, end, left, right, down, up

            return;
        }
        if ((event.shiftKey || (event.keyCode < 48 || event.keyCode > 57)) && (event.keyCode <= 96 || event.keyCode > 105)) {
           event.preventDefault();
        }

    });
}

    //  Enter numbers only (first zero is blocked)
function keyDownFirstZeroBlock(block){
    $j('.'+block).on('keydown' , function (event) {
        if (($j(this).val().length == 0) && (event.keyCode == 48))
        {
            event.preventDefault();
        }
    });
}

    //  Remove multiple click on dropdown list
function removeMultipleClick(input, list) {
    $j("."+input).on("click" , function() {

        setTimeout(function() {
           if ($j('.'+list).css("display") == "none" && $j('.'+input).val().length > 0) {
               $j("."+list).slideDown();
           }
        }, 0);
   });
}

// ----- DADATA FUNCTIONS START -----

    // DaData request

function sendRequestToDadata(source, query, type) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", " https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/" + source);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.setRequestHeader("Authorization", "Token " + apiTokenDaData);
    xhttp.onreadystatechange = function () {
       if (this.readyState === 4 && this.status === 200) {
               var response = JSON.parse(xhttp.responseText);
               formResultList(response, type);
         } else {
             return false;
         }
    };
    query = query.split('"');
    var jsonRequest = '{ "query": "'+query+'" ';
    //if(source == 'party') jsonRequest += ',"branch_type": ["MAIN"]'; //Head organization
    jsonRequest +='}';
    xhttp.send(jsonRequest);
}

    // Form dropdown list

function formResultList(response, type){
     var listName;
     var listItem;
     if (type == 'searchCompany'){
         listName = 'list-oranization';
         listItem = 'oranization-item';
     } else if (type == 'companyInn'){
          listName = 'list-inn';
          listItem = 'list-inn-item';
     } else if (type == 'searchLegalAddress'){
         listName = 'legal-address-list';
         listItem = 'legal-address-item';
     } else if (type == 'searchDocumentAddress'){
         listName = 'document-address-list';
         listItem = 'document-address-item';
     } else if (type == 'searchBank'){
         listName = 'bank-name-list';
         listItem = 'bank-name-item';
     } else {
         return false;
     }

     $j('.'+listName).find('.mCSB_container .'+listItem).remove();
     if (response == null){
         $j('.'+listName).hide();
         $j('.'+listName).closest('.input__obl').removeClass("border-list-input");
         return false;
     } else {
         if (type != 'searchCompany_noShow'){
            $j('.'+listName).show();
            $j('.'+listName).closest('.input__obl').addClass("border-list-input");
         } else {
            type = 'searchCompany';
         }
     }

     var suggestions = response.suggestions;

     for (var i = 0; i < suggestions.length; i++){
         var htmlCodeItem = generateListItem(suggestions[i], type, listItem);
         $j('.'+listName).find('.mCSB_container').append(htmlCodeItem);
     }
     if (suggestions.length > 0){
         $j('.'+listName).height(suggestions.length*82);
         $j('.'+listName).find('.mCSB_container .suggestions-hint').remove();
         $j('.'+listName).mCustomScrollbar('scrollTo',['top',null]);
         if (suggestions.length <= 2){
            $j('.'+listName).mCustomScrollbar("disable");
         }
         else {
            $j('.'+listName).mCustomScrollbar("update");
         }
     }
     else if(!$j('.'+listName).find('.mCSB_container').find('.suggestions-hint')[0]) {
         $j('.'+listName).height(40);
         var notFoundText = '';
         if (type == 'searchCompany' || type == 'companyInn'){
             notFoundText = 'Неизвестная организация';
         } else if (type == 'searchLegalAddress' || type == 'searchDocumentAddress'){
             notFoundText = 'Неизвестный адрес';
         } else if (type == 'searchBank'){
             notFoundText = 'Неизвестный банк';
         }
         $j('.'+listName).find('.mCSB_container').append('<div class="suggestions-hint">'+notFoundText+'</div>');
     }
 }

    // Generate dropdown list attributes from DaData

function generateListItem(suggestion, type, listItem){
    var htmlCodeItem = '';
    if(type == 'searchCompany' || type == 'companyInn'){
        htmlCodeItem = '<div class="'+listItem+'" data-name="' + suggestion.unrestricted_value + '" '+
                       'data-inn="' + suggestion.data.inn +'" '+
                       'data-name-full="' + suggestion.data.name.full_with_opf.split('"').join('&amp;quote') +'" '+
                       'data-address="'+suggestion.data.address.value+'">'+
                       '<strong>'+suggestion.unrestricted_value+'</strong><span>'+suggestion.data.address.value+'<br/>'+suggestion.data.inn+'</span></div>';
    }
    else if(type == 'searchDocumentAddress' || type == 'searchLegalAddress'){
        htmlCodeItem = '<div class="'+listItem+'" data-name="' + suggestion.unrestricted_value + '" ';

        var region = '';
        if (suggestion.data.region_with_type != null) {
            region = suggestion.data.region_with_type;
        }
        htmlCodeItem += ' data-region="' + region + '" ';

        var city = '';
        if (suggestion.data.city_with_type != null) {
            city = suggestion.data.city_with_type;
        } else if (suggestion.data.settlement_with_type != null) {
            city = suggestion.data.settlement_with_type;
        }
        htmlCodeItem += ' data-city="' + city + '" ';

        var postalCode = '';
        if (suggestion.data.postal_code != null) {
            postalCode = suggestion.data.postal_code;
        }
        htmlCodeItem += ' data-postal_code="' + postalCode + '" ';

        var street = '';
        if (suggestion.data.street_with_type != null) {
            street = suggestion.data.street_with_type;
        }
        htmlCodeItem += ' data-street="' + street + '" ';

        htmlCodeItem += ' data-house="';
        if (suggestion.data.house != null) {
            htmlCodeItem += suggestion.data.house + ' ';
        }
        if (suggestion.data.block_type != null) {
            htmlCodeItem += suggestion.data.block_type + ' ';
        }
        if (suggestion.data.block != null) {
            htmlCodeItem += suggestion.data.block;
        }
        htmlCodeItem += '"> <strong>' + suggestion.unrestricted_value+'</strong></div>';
    }
    else if(type == 'searchBank'){
        var bankTown = '';
        if(suggestion.data.address.data != null) {
            bankTown = suggestion.data.address.data.city_with_type;
        }
        var bankNameShort = suggestion.data.name.short;
        if(bankNameShort == null){
            bankNameShort = suggestion.data.name.payment;
        }
        htmlCodeItem = '<div class="'+listItem+'" data-name="' + suggestion.data.name.payment.split('"').join('&amp;quote') + '" '+
                       'data-name-short="' + bankNameShort.split('"').join('&amp;quote') + '" '+
                       'data-bic="' + suggestion.data.bic + '" '+
                       'data-kc="'+ suggestion.data.correspondent_account + '" '+
                       'data-okpo="'+ suggestion.data.okpo + '" '+
                       'data-town="'+ bankTown + '" '+
                       'data-address="'+ suggestion.data.address.value + '" '+
                       '><strong>'+suggestion.data.name.payment+'</strong><span>'+suggestion.data.bic+'<br/>'+suggestion.data.address.value+'</span></div>';
    }
    return htmlCodeItem;
}

    // Fill dropdown list from DaData

function setDaDataInputList(inputClass,listClass){
    var inputBlock = inputClass.parent();
    if (!inputBlock.find('.'+listClass)[0]){
         inputBlock.append('<div class="'+listClass+'"></div>');
    }

     $j(document).mouseup(function (e) {
        var containers = $j('.'+listClass);
        if (containers.has(e.target).length === 0){
            containers.slideUp();
        }
    });

    $j('.'+listClass).mCustomScrollbar({
        theme:"dark"
    });
}

    // Switch DaData service on

function switchDaDaOn(){
    var searchCompanyBlock = $j('.searchCompany');
    setDaDataInputList(searchCompanyBlock,'list-oranization');

    var searchINN = $j('.companyInn');
    setDaDataInputList(searchINN,'list-inn');

    $j('.searchCompany').on('input click',function(e){
        var textQuery =  $j(".searchCompany").val();
        if (textQuery != ''){
            sendRequestToDadata('party', textQuery, 'searchCompany');
            if(e.type != 'input'){
                if($j(".searchCompany").closest(".input__obl").hasClass('border-list-input')){
                    $j(".searchCompany").closest(".input__obl").removeClass("border-list-input");
                } else {
                    $j(".searchCompany").closest(".input__obl").addClass("border-list-input");
                }
            }
        }
        else {
            formResultList(null, 'searchCompany');
        }
        saveCompanyInformation('');

    });

    $j('.searchCompany').blur(function(){
        $j(".searchCompany").closest(".input__obl").removeClass("border-list-input");
    });

    $j('.companyInn').on('input',function(e){
        var textQuery =  $j(".companyInn").val();
        $j('.searchCompany').val('');
        formResultList(null, 'searchCompany');
        if (textQuery != ''){
           if($.isNumeric(textQuery)){
               if ( textQuery.length > 9 ){
                   sendRequestToDadata('party', textQuery, 'companyInn');
//                   $j(".companyInn").closest(".input__obl").addClass("border-list-input");
               }
           }
        }
        else {
            formResultList(null, 'companyInn');
        }
    });

    $j('.companyInn').blur(function(){
        $j(".companyInn").closest(".input__obl").removeClass("border-list-input");
    });

    removeMultipleClick('searchCompany', 'list-oranization');

    $j("body").on("click",'.oranization-item' , function(event) {
        var inn  = $j(this).data("inn");
        $j(".list-oranization").slideUp();
        $j(".searchCompany").val($j(this).find("strong").text());
        $j(".searchCompany").closest(".block__inputs").addClass("goods");

        $j(".searchCompany").closest(".input__obl").removeClass("border-list-input");

        if($j(".companyInn").val().length != 0) {
            $j(".companyInn").closest(".block__inputs").addClass("goods");
        }
        $j(".companyInn").val(inn);
        $j(".searchCompany").closest(".block__inputs").removeClass("error");
        $j(".companyInn").closest(".block__inputs").removeClass("error");

        $j('.list-oranization').addClass('good');

        var textQuery =  $j(".searchCompany").val();
        if (textQuery != ''){
            sendRequestToDadata('party', textQuery, 'searchCompany_noShow');
//            $j(".searchCompany").hide();
//            $j(".searchCompany").closest('.input__obl').removeClass("border-list-input");
        }
        else {
            formResultList(null, 'searchCompany');
        }

        saveCompanyInformation($j(this).data("name-full"));
        saveSoleProprietorLegalAddress($j(this).data("address"));
    });

    $j("body").on("click",'.list-inn-item' , function(event) {
        var company  = $j(this).find("strong").text();
        $j(".list-inn").slideUp();
        $j(".companyInn").val($j(this).data("inn"));
        $j(".companyInn").closest(".block__inputs").addClass("goods");

        $j(".companyInn").closest(".input__obl").removeClass("border-list-input");

        $j(".searchCompany").closest(".block__inputs").addClass("goods");
        $j(".searchCompany").val(company);
        $j(".companyInn").closest(".block__inputs").removeClass("error");
        $j(".searchCompany").closest(".block__inputs").removeClass("error");

        var textQuery =  $j(".searchCompany").val();
        if (textQuery != ''){
           sendRequestToDadata('party', textQuery, 'searchCompany_noShow');
//           $j(".searchCompany").hide();
//           $j(".searchCompany").closest('.input__obl').removeClass("border-list-input");
        }
        else {
            formResultList(null, 'searchCompany');
        }

        $j('.list-oranization').mCustomScrollbar("update");
        $j('.list-oranization').addClass('good');

        saveCompanyInformation($j(this).data("name-full"));
        saveSoleProprietorLegalAddress($j(this).data("address"));

        setTimeout(setTimeoutInterval, 400);
    });
}

function companyDetailsManualEntryEvents(){
    var currentStepBlock = $j('.step-company-information');
    var company = currentStepBlock.find('.searchCompany');
    company.blur(function(e){
        isInputValueValid(company, new RegExp(regs.companyName));
    });
    checkForAutoPasteValues('searchCompany', new RegExp(regs.companyName));

    var inn = currentStepBlock.find('.companyInn');
    inn.blur(function(e){
        isInputValueValid(inn, new RegExp(regs.inn));
    });
    checkForAutoPasteNumericValues('companyInn');
}

function setTimeoutInterval(){
    $j('.list-oranization').hide();
}
// ----- DADATA FUNCTIONS END -----

    //  Tooltip Management
function tooltipInput_controller(inputClass) {

    $j("."+inputClass).closest('.block__inputs').find('.df').on("click" , function() {
        if ($(window).width() < 768) {
            var self = $(this).closest('.block__inputs').find('.mobile__tooltips');
            var icon = $(this).closest('.block__inputs').find('.tooltip-image')
            if( self.hasClass('active_input') == true ) {
                self.removeClass("active_input");
                icon.removeClass('arrow-up').addClass('arrow-down');
            } else {
                self.addClass("active_input");
                icon.removeClass('arrow-down').addClass('arrow-up');
            }
        }
    });

}

function tooltipCheckbox_controller() {

    $j(".block__dops").find('.block_checkbox').find('.tooltip-image').on("click" , function(){
        if ($(window).width() < 768) {
            var self = $(this).closest('.checkbox_helptext').find('.mobile__tooltips');
            if( self.hasClass('active') == true ) {
                self.removeClass("active");
                $(this).removeClass('arrow-up').addClass('arrow-down');
            } else {
                self.addClass("active");
                $(this).removeClass('arrow-down').addClass('arrow-up');
            }
        }
    });

}

function tooltipMode(){
    if($(window).width() < 768){
        $('[data-toggle="tooltip"]').tooltip('disable');
    } else {
        $('[data-toggle="tooltip"]').tooltip('enable');
    }

    $j( window ).resize(function() {
        if($(this).width() < 768){
            $('[data-toggle="tooltip"]').tooltip('disable');
        } else {
            $('.tooltip-image').removeClass('arrow-down').removeClass('arrow-up');
            $('[data-toggle="tooltip"]').tooltip('enable');
            $('.mobile__tooltips').removeClass('active_input');
            $('.mobile__tooltips').removeClass('active');
        }
    });
}

// ----- CONTACT Details step START -----
function setEvents_ContactDetails(){
    $j('.phoneNumber').mask('+7 (000) 000-00-00');
    var contactDetailsBlock = $j('.step-contact-details .block__inputs').find('input');
    preventPressingEnterButton(contactDetailsBlock);

    checkForAutoPasteValues('emailAddress', new RegExp(regs.email));
    checkForAutoPasteNumericValues('phoneNumber');

    $j(".phoneNumber").blur(function(){
        isInputValueValid($j(this), new RegExp(regs.phone));
    });
    checkInputLength("phoneNumber", 18);

    $j(".phoneNumber").on('input',function(){
        isInputValueValidOnInput($j(this), new RegExp(regs.phone));
        checkInputLengthOnInput("phoneNumber", 18);
    });

    $j(".emailAddress").blur(function(){
        isInputValueValid($j(this), new RegExp(regs.email));
    });

    $j(".emailAddress").on('input',function(){
        isInputValueValidOnInput($j(this), new RegExp(regs.email));
    });

    $j('.personal_data_agreement').change( function(){
        if($j(this).is(":checked") == true) {
            $j(this).closest(".block__inputs").removeClass("error");
        }
        ga('send', 'event', 'checkbox', 'click', 'personal_data');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_personal_data');
        }
    });

    $j('.agreement-to-receive-information').change( function(){
        ga('send', 'event', 'checkbox', 'click', 'get_info');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_get_info');
        }
    });

    $j(".modal-body").mCustomScrollbar({
       theme:"dark"
    });

    modalOpen('myModal');
    modalClose('myModal');

    eraseInputValue('step-contact-details');

    $('.preview-inside-button').attr('data-dismiss','modal');

    tooltipMode();
    tooltipInput_controller('phoneNumber');
    tooltipInput_controller('emailAddress');
}

function validateContactDetails(){
    var currentStepBlock = $j('.step-contact-details');
    var phoneNumber = currentStepBlock.find('.phoneNumber');
    var emailAddress = currentStepBlock.find('.emailAddress');
    var personalPolitic = currentStepBlock.find('.personal_data_agreement');
    var isValid = false;
    var isInvalidOnlyPersonalPolitic = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(phoneNumber, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailAddress, new RegExp(regs.email)));
    validatedFields.push(personalPolitic.is(":checked"));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;
    isInvalidOnlyPersonalPolitic = validatedFields.indexOf(false) == 2 ? true : false;

    if(isValid){
       goToCompanyDetails();
    } else if (isInvalidOnlyPersonalPolitic) {
        updateContactPhone();
    } else {
      var contactDetailsBlock = $j('.step-contact-details .block__inputs.error');
      scrollToTopInput(contactDetailsBlock);
    }
}

/*function validateContactDetailsOnLoad(){
    var currentStepBlock = $j('.step-contact-details');
    var phoneNumber = currentStepBlock.find('.phoneNumber');
    var emailAddress = currentStepBlock.find('.emailAddress');
    var personalPolitic = currentStepBlock.find('.personal_data_agreement');

    if(phoneNumber != '') {
        isInputValueValid(phoneNumber, new RegExp(regs.phone));
    }
    if(emailAddress != '') {
        isInputValueValid(emailAddress, new RegExp(regs.email));
    }
}*/

// ----- CONTACT Details step END -----

// ----- COMPANY Details step START -----
function setEvents_companyDetails(){
    checkForAutoPasteNumericValues('companyInn');
    checkForAutoPasteValues('searchCompany', new RegExp(regs.companyName));
    var companyDetailsBlock = $j('.step-company-information .block__inputs').find('input');
    preventPressingEnterButton(companyDetailsBlock);

    $j('.companyInn').mask("999999999999");

    $j('.companyNotExist').on('change',function(){
        ga('send', 'event', 'checkbox', 'click', 'manually');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_manually');
        }

        var value = $j(this).val();
        if($j(this).is(":checked") == true) {
            isManualEntryFunctionDaDataOff();
        } else {
            isManualEntryFunction();
        }
    });

    var chatButtonOnline = document.getElementById("chat-button-online");
    if(chatButtonOnline != null){
        chatButtonOnline.style.visibility = "visible";
    }

    var chatButtonOffline = document.getElementById("chat-button-offline");
    if(chatButtonOffline != null){
        chatButtonOffline.style.visibility = "visible";
    }

    $j('.searchCompany').on('input',function(e){
        $j(".searchCompany").closest(".block__inputs").removeClass("goods");
        var check = $j('.companyNotExist');
        if(check.is(":checked") == false) {
            $j(".companyInn").closest(".block__inputs").removeClass("goods");
            $j('.companyInn').val('');
            $j('.list-oranization').removeClass('good');
        }
        $j(".companyInn").closest(".block__inputs").removeClass("goods");
    });

    $j('.searchCompany').blur(function(){
        var check = $j('.companyNotExist');
        if(check.is(":checked") == true) {
            $j(this).closest(".block__inputs").addClass("goods");
        }
    });

    $j('.companyInn').on('input',function(e){
        $j(".companyInn").closest(".block__inputs").removeClass("goods");
        var check = $j('.companyNotExist');
        if(check.is(":checked") == false) {
            $j(".searchCompany").closest(".block__inputs").removeClass("goods");
        }
    });

    eraseInputValue('step-company-information');

    tooltipMode();
    tooltipInput_controller('companyInn');
    tooltipInput_controller('searchCompany');

    return false;
}

function validateCompanyDetails(){
    var currentStepBlock = $j('.step-company-information');
    var searchCompanyName = currentStepBlock.find('.searchCompany');
    var companyInn = currentStepBlock.find('.companyInn');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(searchCompanyName, new RegExp(regs.companyName)));
    validatedFields.push(isInputValueValid(companyInn, new RegExp(regs.inn)));
    if($j('.companyNotExist').is(":checked") == false){
        validatedFields.push(isInnValid(searchCompanyName, companyInn));
    }
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    if(isValid){
       goToOrderInformation();
    } else {
       searchCompanyName.closest(".block__inputs").removeClass("goods");
       $j('.list-oranization').removeClass('good');
       searchCompanyName.removeAttr("disabled");
       var companyDetailsBlock = $j('.step-company-information .block__inputs.error');
       scrollToTopInput(companyDetailsBlock);
    }
}

function isInnValid(companyName, companyInn){
    var isInnValid = false;
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/party", false);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.setRequestHeader("Authorization", "Token " + apiTokenDaData);
    xhttp.send('{ "query": "'+companyInn.val()+'" }');
    var response = JSON.parse(xhttp.responseText);
    var suggestions = response.suggestions;
    if(suggestions.length > 0){
        for (var i = 0; i < suggestions.length; i++){
            if(suggestions[i].data.inn == companyInn.val() && suggestions[i].unrestricted_value.toUpperCase() == companyName.val().toUpperCase()){
                isInnValid = true;
                break;
            }
        }
    } else if (($j('.companyNotExist').is(":checked") == true) && (isInputValueValid(companyInn, new RegExp(regs.inn)))){
        isInnValid = true;
    }

    if(isInnValid){
        companyInn.closest(".block__inputs").removeClass("error");
        companyInn.closest(".block__inputs").addClass("goods");
    } else {
        companyInn.closest(".block__inputs").removeClass("goods");
        companyInn.closest(".block__inputs").addClass("error");
    }
    return isInnValid;
}

function prepareBackToContactDetails(){
    backToContactDetails();
    //validateContactDetailsOnLoad();
}
// ----- COMPANY Details step END -----

// ----- ORDER Details step START -----
function setEvents_order(){

    var orderDetailsBlock = $j('.step-order-information .block__inputs').find('input');
    preventPressingEnterButton(orderDetailsBlock);

    $j('.PERSONAL-MANAGER').change( function(){
        ga('send', 'event', 'checkbox', 'click', 'consultation');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_consultation');
        }
    });
    $j('.DOCS-DELIVERY').change( function(){
        ga('send', 'event', 'checkbox', 'click', 'delivery');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_delivery');
        }
    });

    tooltipMode();
    tooltipInput_controller('js-count-cart');

//    keyDownNumeric('js-count-cart');
    keyDownFirstZeroBlock('js-count-cart');
    $j('.js-count-cart').mask("999");

    $j(".stetps__blocks_hide").slideUp();

    if (typeof $j(".js-count-cart").val() !== "undefined"){
        if($j(".js-count-cart").val().length < 1) {
          $j(".step-order-information .stetps__blocks_hide").slideDown().removeClass("active");
          $j(".js-count-cart").closest(".block__inputs").removeClass("goods");
        } else {
            //startTariffsLoad();
            $j(".step-order-information .stetps__blocks_hide").slideDown();
        }
    }

    $j('.js-count-cart').blur(function(){
        if($j(this).val().length < 1 ){
            $j(".js-count-cart").closest(".block__inputs").addClass("error");
        } else {
            $j(".js-count-cart").closest(".block__inputs").removeClass("error");
        }
    });

    $j(".js-count-cart").on("keyup" , function(){

        var isTariffsSeparation =  parseInt($j('[id$=isTariffsSeparation]').text());
        var currentNumberOfCards = 0;
        var newNumberOfCards = 0;
        if(isNaN(parseInt($j('[id$=currentNumberOfCards]').text())) == false){
            currentNumberOfCards =  parseInt($j('[id$=currentNumberOfCards]').text());
        }
        if(isNaN(parseInt($j(this).val())) == false){
            newNumberOfCards = parseInt($j(this).val());
        }
        if(newNumberOfCards == 0 ){
            $j(".js-count-cart").closest(".block__inputs").addClass("error").removeClass("goods");
        } else {
            $j(".js-count-cart").closest(".block__inputs").addClass("goods").removeClass("error");
            if(amountOfCardsRange(currentNumberOfCards, 1, isTariffsSeparation) != amountOfCardsRange(newNumberOfCards, 1, isTariffsSeparation) || currentNumberOfCards == 0) {
                var suffix = '_CONTRACT';
                if(amountOfCardsRange(newNumberOfCards, 1, isTariffsSeparation)){
                  var suffix = '_CARDS';
                }
                setTariffsContent(suffix);
                $j('[id$=currentNumberOfCards]').text(newNumberOfCards);
            }
        }
    });

        //  TARIFFS

    setEvents_loadTariffs();

        //  PRODUCT

    $j(document).mouseup(function (e) {
        var containers = $j('.list-product');
        if (containers.has(e.target).length === 0){
            containers.slideUp();
        }
    });

    $j('.product-item').on('click' , function() {
        var text  = $j(this).text();
        var id  = $j(this).attr('product-id');
        $j('.list-product').slideUp();
        $j('.js-product').val(text);
        putProduct(id);
    });

    $j('.js-product').on('keydown' , function(event){
       event.preventDefault();
    });

    $j('.list-product').mCustomScrollbar({
       theme: 'dark'
    });

    removeMultipleClick('js-product', 'list-product');

        //  PROMOCODE

    setEvents_checkPromocode();
    getPromocodeResult();

        // CHECKBOXES SERVICES

    //setTimeout(checkboxesCursor , 1000);
    tooltipCheckbox_controller();

    $j( window ).resize(function() {
        if($('.tariffs-block').css('display') == 'block'){
            setTimeout(alignProperties , 1000);
        }
    });

}

function startTariffsLoad(){
    var isTariffsSeparation =  parseInt($j('[id$=isTariffsSeparation]').text());

    var value = $j(".js-count-cart").val();
    var suffix = '_CONTRACT';
    if(amountOfCardsRange(parseInt(value), 1, isTariffsSeparation)){
        var suffix = '_CARDS';
    }

    setTariffsContent(suffix);
}

function setEvents_loadTariffs(){
    if (typeof $j(".js-count-cart").val() !== "undefined"){
        if($j(".js-count-cart").val().length > 0 ){
            $j(".stetps__blocks_hide").slideDown().addClass("active");
            $j(".js-count-cart").closest(".block__inputs").addClass("goods");
        }
        else {
            $j(".js-count-cart").closest(".block__inputs").removeClass("goods");
        }
    }

    $('a[data-toggle="tab"]').on('shown.bs.tab', function (event) {
        var id = $(event.target).attr('href').replace('#', ''); // activated tab
        var value = $(event.target).text(); // activated tab
        $j('input[name=tariff][id='+id+']').prop('checked', true);
        setActiveTariffBorder(id);
        putTariff(value, id);
        if(value == 'Оптимальный'){
            ga('send', 'event', 'checkbox', 'click', 'optimal');
            window.onload = function() {
                yaCounter1965880.reachGoal('checkbox_optimal');
            }
        } else if (value == 'Избранный'){
            ga('send', 'event', 'checkbox', 'click', 'elect');
            window.onload = function() {
                yaCounter1965880.reachGoal('checkbox_elect');
            }
        }
    });

   $j('input[name=tariff][class=desktop]').on('change' , function(){
        var id = $j(this).attr('id');
        var value = $j(this).val();
        $('.nav-pills a[href=#'+id+']').tab('show');
        setActiveTariffBorder(id);
        putTariff(value, id);
   });

    alignProperties();
    carouselTariffs();
    $j('i').parent().children("span").remove();

    var href = $j('.nav-item').last().find('a').attr('href');
    var cards = $j('.js-count-cart').val();
    if(amountOfCardsRange(parseInt(cards), 1, 5)){
        var href = $j('.nav-item').last().find('a').attr('href');
    }

    $('.nav-pills a[href='+href+']').tab('show');

    modalOpen('DiscountsModal');
    modalClose('DiscountsModal');
    tooltipMode();
}

function setEvents_checkPromocode(){

    eraseInputValue('promocode-section');

    $j('.js-promocode').blur(function(){
        var text_label = $j(".promocode-label").text();
        var text_error = $j('.promocode-section .error--text').text();
        if($j(this).val().length > 0 ||  text_label != '' || text_error != ''){
            checkPromocode($j(this).val());
        }
    });

    $j('.js-promocode').on('input', function() {
        $j('.js-promocode').closest(".block__inputs").removeClass("goods");
    });

    $j(document).mouseup(function (e) {
        var containers = $j('.list-promocode');
        if (containers.has(e.target).length == 0){
            containers.slideUp();
        }
    });

    removeMultipleClick('js-promocode-option', 'list-promocode');

    $j(".promocode-item").on('click' , function() {
        var text  = $j(this).text();
        var id  = $j(this).attr('promocode-id');
        $j('.list-promocode').slideUp();
        $j('.js-promocode-option').val(text);
        setPromocodeItem(text);
    });

    $j('.js-promocode-option').on('keydown' , function(event){
        event.preventDefault();
    });

    $j('.list-promocode').mCustomScrollbar({
        theme: 'dark'
    });

    tooltipMode();
    tooltipInput_controller('js-promocode');
}

function amountOfCardsRange(x, min, max) {
    return x >= min && x <= max;
}

function onChangeTariff(){
    $j("input[name=tariff][class=desktop]").on("change" , function(){
        var id = $j(this).attr('id');
        var value = $j(this).val();
        $('.nav-pills a[href=#'+id+']').tab('show');
        setActiveTariffBorder(id);
        putTariff(value, id);
    });
}

function getPromocodeResult(){

    var promocodeValue = $j('.js-promocode').val();

    if(promocodeValue != undefined){
        if(promocodeValue == undefined && promocodeValue.length > 0){

            var text = $j(".promocode-label").text();
            if(text == null || text == ''){
                $j(".promocode-section").removeClass('promocode-block');
                $j(".js-promocode").closest(".block__inputs").addClass("error");
                $j(".promocode-label").addClass('none');
                $j('.js-promocode').closest(".block__inputs").removeClass("goods");
                $('.promocode-complete').remove();
            } else {
                $j(".promocode-section").addClass('promocode-block');
                $j(".promocode-complete").removeClass('none');
                $j('.js-promocode').closest(".input__obl").addClass("margin-promocode");
                $j(".js-promocode").closest(".block__inputs").removeClass("error");
                $j(".promocode-label").removeClass('none');
                $j('.js-promocode').closest(".block__inputs").addClass("goods");
            }

            var text_input = $j(".js-promocode-option").val();
            if(text_input == null || text_input == '' || text_input == undefined){
                //$j('.promocode-list-hide').remove();
                $j('.fake__inputs-text').closest('.promocode-complete .block__inputs').addClass('margin-promocode-value');
            } else {
                $j('.promocode-list-hide').removeClass('none');
            }
        } else{
            $('.promocode-complete').remove();
        }
    }
}

function lockPromocode(){
    var promocodeValue = $j('.js-promocode').val();
    if(promocodeValue.length > 0){
        var parent = $j('.js-promocode').closest('.input__obl');
        $j('.js-promocode').remove();
        parent.closest('.block__inputs').removeClass('goods');
        parent.css('border', '0');
        parent.append("<div class='fake__inputs-text'>"+promocodeValue+"</div>");
    }
}

function carouselTariffs(){

    if($('.item').length == 1){
        var lengthTariffs = $( ".tariff-block" ).length;
        lengthTariffs = (lengthTariffs + lengthTariffs%2) / 2 - 1;
        if(lengthTariffs == 0) {
            $('.carousel-indicators').addClass('none');
            $('.carousel-control').addClass('none');
        } else {
            $('.carousel-indicators').removeClass('none');
            $('.carousel-control').removeClass('none');
        }
        for (var i = 0; i < lengthTariffs; i++) {
            $( ".item" ).last().clone().appendTo( ".carousel-inner" );
            $( ".item" ).last().removeClass('active');
            $( ".carousel-indicator-custom" ).last().clone().appendTo( ".carousel-indicators" );
            var new_id = $( ".carousel-indicators" ).children().length-1;
            var index = '' + new_id;
            $( ".carousel-indicator-custom" ).last().attr('data-slide-to', index);
            $( ".carousel-indicator-custom" ).last().removeClass('active');
        }
        //deleteCarouselElements();
        onChangeTariff();
    }

}

function deleteCarouselElements(){

    var i = 1;
    var i_next = i+1;
    var iStr = 'tariff-' + i;
    var i_nextStr = 'tariff-' + i_next;
    $( ".item" ).each(function( index ) {

        $(this).children().each(function( index ) {
            var className = $(this).attr('class');
            if(className.indexOf(iStr) == -1 &&  className.indexOf(i_nextStr) == -1){
                $(this).remove();
            }
        });
        i++;
        i++;
        if($('.carousel-indicator-custom').length == i){
            i_next = 1;
        } else {
            i_next++;
            i_next++;
        }
        iStr = 'tariff-' + i;
        i_nextStr = 'tariff-' + i_next;
    });

}

function putTariff(tariff, tariffID){
    $("#TariffErrorDesktop").css('padding', '0px 0 5px');
    $("#TariffErrorDesktop").css('display', 'none');
    $("#TariffErrorMobile").css('padding', '0px 0 5px');
    $("#TariffErrorMobile").css('display', 'none');
    setTariff(tariff, tariffID);
}

function putProduct(productID){
    $j(".js-promocode").val('');
    setProduct(productID);
}

function updateTariffs(){
    loadTariffs();
}

function setActiveTariffBorder(id){

    $j('.tariff-'+id).css( "border", "1px solid #4fcfcc" );

    $("input:radio:not(:checked)").each(function (index, value) {
       var id_not_checked = $(this).attr('id');
       $j('.tariff-'+id_not_checked).css( "border", "1px solid #ebebeb" );
    });

}

function alignProperties(){

    if ($(window).width() > 768) {
        $( ".property-block" ).each(function() {
           var property = $( this ).attr('property-name');
            $( ".property-"+property).each(function() {
               var maxHeight = Math.max.apply(null, $(".property-"+property).map(function ()
               {
                   return $(this).height();
               }).get());
               $( this ).height(maxHeight);
            });
        });
    }

}

function checkboxesCursor(){
    $(".js-tooltips-text").each(function(){
        $(this).css("top" , "-"+$(this).outerHeight()-20 +"px");
    });
}

function validateOrderInformation(){
    var isValidMobile = $("ul#TariffPills li.active a").attr('href');
    var isValidDesktop = $('input[name=tariff]').is(":checked");
    var isValidAmountCards = amountOfCardsRange($j('.js-count-cart').val(), 1, 999);

    if(!isValidAmountCards){
        $j('.js-count-cart').closest(".block__inputs").removeClass("goods").addClass("error");
    }
    if(!isValidDesktop && isValidMobile == undefined){
        $("#TariffErrorDesktop").css('padding', '0px 0 5px');
        $("#TariffErrorDesktop").css('display', 'block');
        $("#TariffErrorMobile").css('padding', '0px 0 5px');
        $("#TariffErrorMobile").css('display', 'block');
    }

    if(!isValidAmountCards){
        var orderDetailsBlock = $j('.step-order-information .block__inputs.error');
        scrollToTopInput(orderDetailsBlock);
        return;
    }
    if (!isValidDesktop && isValidMobile == undefined){
        var orderDetailsBlock = $j('.scroll__error')[0];
        if ( !isScrolledIntoView(orderDetailsBlock) ){
            orderDetailsBlock.scrollIntoView();
        }
    }
    else{
        putTariff();
        goToSummaryOrder();
    }
}

// ----- ORDER Details step END -----

// ----- SummaryOrder Details step START -----

function setEvents_summaryOrder(){

    var orderDetailsBlock = $j('.step-order-information .block__inputs').find('input');
    preventPressingEnterButton(orderDetailsBlock);

    if($j('.js-goods-order').closest('.stetps__blocks-content').find("input[type='checkbox']:checked").length == 0) {
        $('.dop__services').addClass('none');
    }
    else {
        $j('.js-goods-order').closest('.stetps__blocks-content').find("input[type='checkbox']:checked").each(function(){
            var id = $(this).attr('class');
            id = '.values.' + id;
            $j('.dop__services').find(id).removeClass('none');
        });
    }

    $j('.js-past-cart').val($j('.js-count-cart').val());

    $j('.mobile__tooltips').removeClass('active');

    $('.js-tooltips-text').each(function(){
       $(this).css('top' , '-'+$(this).outerHeight()-20 +'px');
    });

    $('.js-tooltips').on('click' , function(){
      if ($(window).width() < 768) {
         $(this).closest('.checkbox_helptext').find('.mobile__tooltips').html($(this).find('.js-tooltips-text').html()).addClass('active');
      }
    });

    $('.block__inputs-podr').click(function(e) {
        e.preventDefault();  //stop the browser from following
        window.location.href = 'https://www.cmu.edu/blackboard/files/evaluate/tests-example.xls';
    });

    var text_input = $j(".promocode-result").text().trim();
    if(text_input == null || text_input == ''){
        $j('.promocode-result').addClass('none');
    } else {
       $j('.promocode-result').removeClass('none');
    }

    $('#DiscountsModal').prop('id', 'DiscountsModal_prev');
    modalOpen('DiscountsModal');
    modalClose('DiscountsModal');
    tooltipMode();
    tooltipCheckbox_controller();

    $j('i').parent().children("span").last().remove();

    return false;
}

function goBackToSummaryOrder(){
    $j('.step-legal-and-payment-details .stetps__blocks_container').slideUp();
    $j('.step-order-information .stetps__blocks_container').slideDown();

    $('.js-end-order').removeClass('none');
    //$('.js-end-order').closest('.stetps__blocks-footer').find('.goods_data').removeClass('active');

    backToSummaryOrder();
}


function validateSummaryOrder(){
//    $('.js-end-order').on('click' , function(){
//        $(this).addClass('none')
//        $(this).closest('.stetps__blocks-footer').find('.goods_data').addClass('active');
//    });
    goToLegalDetails();
    return false;
}
// ----- SummaryOrder Details step END -----

// ----- Legal Details step START -----

function setEvents_legalDetails(){
    var currentStepBlock = $j('.step-legal-details');
    var legalAndPaymentDetailsBlock = $j('.step-legal-and-payment-details .block__inputs').find('input');
    preventPressingEnterButton(legalAndPaymentDetailsBlock);

    eraseInputValue('step-legal-details');

    setEvents_sparkFields();

    var documentAddress = currentStepBlock.find('.document-address');
    documentAddress.blur(function(e){
        validateAddressInformation(documentAddress);
    });
    checkForAutoPasteValues('document-address', new RegExp(regs.address));
    documentAddress.blur(function(){
        documentAddress.closest(".input__obl").removeClass("border-list-input");
    });

    var checkboxForDocAddress = currentStepBlock.find('.address-2');

    var executivePersonFullName = currentStepBlock.find('.executivePersonFullName');
    executivePersonFullName.blur(function(e){
        isInputValueValid(executivePersonFullName, new RegExp(regs.letters));
    });
    checkForAutoPasteValues('executivePersonFullName', new RegExp(regs.letters));
    executivePersonFullName.on('input',function(){
        isInputValidOnChange(executivePersonFullName);
    });

    var executivePersonPosition = currentStepBlock.find('.executivePersonPosition');
    executivePersonPosition.blur(function(e){
        isInputValueValid(executivePersonPosition, new RegExp(regs.position));
    });
    checkForAutoPasteValues('executivePersonPosition', new RegExp(regs.position));
    executivePersonPosition.on('input',function(){
        isInputValidOnChange(executivePersonPosition);
    });

    var codeWord = currentStepBlock.find('.codeWord');
    codeWord.blur(function(e){
        isCodeWordValueValid(codeWord, new RegExp(regs.codeWord));
    });
    checkForAutoPasteValues('codeWord', new RegExp(regs.codeWord));
    codeWord.on('input',function(){
        isInputValidOnChange(codeWord);
    });

    var accountEmail = currentStepBlock.find('.account-email');
    accountEmail.blur(function(e){
        isInputValueValid(accountEmail, new RegExp(regs.email));
    });
    checkForAutoPasteValues('account-email', new RegExp(regs.email));
    accountEmail.on('input',function(){
        isInputValueValidOnInput(accountEmail, new RegExp(regs.email));
    });

    $j(".close").on("click" , function(){
        var th = $j(this);
        th.closest(".block__inputs").removeClass("error");
        th.closest(".block__inputs").find("input").val("");
        th.closest(".block__inputs").find("input").focus();
    });

    $j("input[class=address-2]").on("change" , function() {
        ga('send', 'event', 'checkbox', 'click', 'address');
        window.onload = function() {
            yaCounter1965880.reachGoal('checkbox_address');
        }

        if($j(this).is(":checked") == true) {
            $j(".document-address").closest(".block__inputs").removeClass("error");
            $j(".document-address").val($(".legal-address").val());
            $j(".document-address").removeClass("error");
            saveAddressInformation('postalAddress',
                                    $j('[id$=legalAddressInformationCity]').val(),
                                    $j('[id$=legalAddressInformationPostalCode]').val(),
                                    $j('[id$=legalAddressInformationState]').val(),
                                    $j('[id$=legalAddressInformationStreet]').val(),
                                    $j('[id$=legalAddressInformationHouse]').val()
            );
            $j(".document-address").attr("disabled" , "disabled");

            $j(".document-address-additionally").val($j(".legal-address-additionally").val());
            $j(".document-address-additionally").attr("disabled" , "disabled");
        }
        else {
            saveAddressInformation('postalAddress', '', '', '', '', '');
            $j(".document-address").val("");
            $j(".document-address").removeAttr("disabled");
            $j(".document-address-additionally").val("");
            $j(".document-address-additionally").removeAttr("disabled");
        }
    });

//    $j('.step-order-information .stetps__blocks_container').slideUp();
    $j(".step-order-information").removeClass("current");
    $j(".step-legal-and-payment-details").addClass("active");
    $j(".step-legal-details").addClass("active");

    /* Document address search START */
    var searchDocumentAddressBlock = $j('.document-address').parent();
    if (!searchDocumentAddressBlock.find('.document-address-list')[0]){
         searchDocumentAddressBlock.append('<div class="document-address-list"></div>');
    }

    $j('.document-address').on('input click',function(e){
        var textQuery =  $j(this).val();
        if (textQuery != ''){
            sendRequestToDadata('address', textQuery, 'searchDocumentAddress');
        }
        else {
            formResultList(null,'searchDocumentAddress');
        }
        if(e.type == 'input'){
            saveAddressInformation('postalAddress','','','','');
            $j('.document-address').closest(".block__inputs").removeClass("error");
            $j('.document-address').closest(".block__inputs").removeClass("goods");
            $j('.document-address-list').removeClass('good');
        }
    });

    removeMultipleClick('document-address', 'document-address-list');

    $j("body").on("click",'.document-address-item' , function(event) {
        $j(".document-address-list").slideUp();
        $j(".document-address").closest(".input__obl").removeClass("border-list-input");
        $j('.document-address').addClass('good');
        $j(".document-address").val($j(this).find("strong").text());
        $j('.document-address-list').addClass('good');
        saveAddressInformation('postalAddress',
                               $j(this).data("city"),
                               $j(this).data("postal_code"),
                               $j(this).data("region"),
                               $j(this).data("street"),
                               $j(this).data("house"));
        validateAddressInformation($j('.step-legal-details .document-address'));
    });

    $j(document).mouseup(function (e) {
                 if ($j('.document-address-list').is(':visible')){
                     if ($j('.document-address-list').has(e.target).length === 0){
                         $j('.document-address-list').slideUp();
                         var addressIsSelected = false;
                         $j(".document-address-item").each(function( index ) {
                              if($j(this).find("strong").text() == $j(".document-address").val()){
                                 addressIsSelected = true;
                              }
                         })
                         if(!addressIsSelected){
                              var firstDocumentAddressItem = $j('.document-address-item').first();
                              $j(".document-address").val(firstDocumentAddressItem.find("strong").text());
                              saveAddressInformation('postalAddress',
                                                       firstDocumentAddressItem.data("city"),
                                                       firstDocumentAddressItem.data("postal_code"),
                                                       firstDocumentAddressItem.data("region"),
                                                       firstDocumentAddressItem.data("street"),
                                                       firstDocumentAddressItem.data("house"));
                              validateAddressInformation($j('.step-legal-details .document-address'));
                         }
                     }
                 }
                 if ($j('.legal-address-list').is(':visible')){
                     if ($j('.legal-address-list').has(e.target).length === 0){
                         $j('.legal-address-list').slideUp();
                         var addressIsSelected = false;
                         $j(".legal-address-item").each(function( index ) {
                              if($j(this).find("strong").text() == $j(".legal-address").val()){
                                 addressIsSelected = true;
                              }
                         })
                         if(!addressIsSelected){
                              var firstDocumentAddressItem = $j('.legal-address-item').first();
                              $j(".legal-address").val(firstDocumentAddressItem.find("strong").text());
                              saveAddressInformation('legalAddress',
                                                      firstDocumentAddressItem.data("city"),
                                                      firstDocumentAddressItem.data("postal_code"),
                                                      firstDocumentAddressItem.data("region"),
                                                      firstDocumentAddressItem.data("street"),
                                                      firstDocumentAddressItem.data("house"));
                              validateAddressInformation($j('.step-legal-details .legal-address'));
                              if($j(".address-2").is(":checked") == true){
                                  $j(".document-address").val(firstDocumentAddressItem.find("strong").text());
                                  saveAddressInformation('postalAddress',
                                                          firstDocumentAddressItem.data("city"),
                                                          firstDocumentAddressItem.data("postal_code"),
                                                          firstDocumentAddressItem.data("region"),
                                                          firstDocumentAddressItem.data("street"),
                                                          firstDocumentAddressItem.data("house"));
                                  validateAddressInformation($j('.step-legal-details .document-address'));
                              }
                         }
                     }
                 }
             });

    $j(".document-address-list").mCustomScrollbar({
        theme:"dark"
    });
    /* Document address search END */

    setTimeout(checkboxesCursor , 1000);

    tooltipMode();
    tooltipInput_controller('codeWord');
    tooltipInput_controller('account-email');
    tooltipInput_controller('delivery-info');

}

function setEvents_sparkFields(){
    $j('.manual-entry').attr('disabled', 'disabled');

    eraseInputValue('spark-fields');

    if($j("input[class=rewrite-spark-values]").val() == 'on'){
        $j("input[class=rewrite-spark-values]").on("change" , function() {
            ga('send', 'event', 'checkbox', 'click', 'change_data');
            window.onload = function() {
                yaCounter1965880.reachGoal('checkbox_change_data');
            }

            if($j(this).is(":checked") == false) {
                recoverDataSpark();
                $j('.manual-entry').attr('disabled', 'disabled');
            }
            else {
                $j('.manual-entry').removeAttr("disabled");
            }
        });
    } else {
        $j('.manual-entry').removeAttr("disabled");
    }

    if($j('.spark-values-checkbox').hasClass('pay-overdraft-lock')){
        $j('.manual-entry').removeAttr("disabled");
    }


    var currentStepBlock = $j('.step-legal-details');

    var ogrn = currentStepBlock.find('.js-orgn');
    ogrn.blur(function(e){
        isLegalInputValueValid(ogrn, new RegExp(regs.numbers), 13, false);
    });
    checkForAutoPasteNumericValues('js-orgn');
    ogrn.on('input',function(){
        isLegalInputValueValidOnInput(ogrn, new RegExp(regs.numbers), 13, false);
    });

    var ogrnip = currentStepBlock.find('.ogrnip');
    ogrnip.blur(function(e){
        isLegalInputValueValid(ogrnip, new RegExp(regs.numbers), 15, false);
    });
    checkForAutoPasteNumericValues('ogrnip');
    ogrnip.on('input',function(){
        isLegalInputValueValidOnInput(ogrnip, new RegExp(regs.numbers), 15, false);
    });

    var kpp = currentStepBlock.find('.js-kpp');
    kpp.blur(function(e){
        isLegalInputValueValid(kpp, new RegExp(regs.numbers), 9, false);
    });
    checkForAutoPasteNumericValues('js-kpp');
    kpp.on('input',function(){
        isLegalInputValueValidOnInput(kpp, new RegExp(regs.numbers), 9, false);
    });

    var okpo = currentStepBlock.find('.js-okpo');
    okpo.blur(function(e){
        isLegalInputValueValid(okpo, new RegExp(regs.numbers), 10, true);
    });
    checkForAutoPasteNumericValues('js-okpo');
    okpo.on('input',function(){
        isLegalInputValueValidOnInput(okpo, new RegExp(regs.numbers), 10, true);
    });

    var legalAddress = currentStepBlock.find('.legal-address');
    legalAddress.blur(function(e){
        validateAddressInformation(legalAddress);
    });
    checkForAutoPasteValues('legal-address', new RegExp(regs.address));

    legalAddress.blur(function(){
        legalAddress.closest(".input__obl").removeClass("border-list-input");
    });

    /* Legal address search START */
    var legalAddressBlock = $j('.legal-address').parent();
    if (!legalAddressBlock.find('.legal-address-list')[0]){
         legalAddressBlock.append('<div class="legal-address-list"></div>');
    }

    $j('.legal-address').on('input click',function(e){
        var textQuery =  $j(this).val();
        if (textQuery != ''){
            sendRequestToDadata('address', textQuery, 'searchLegalAddress');
        }
        else {
            formResultList(null,'searchLegalAddress');
        }
        if(e.type == 'input'){
            saveAddressInformation('legalAddress','','','','');
            $j('.legal-address').closest(".block__inputs").removeClass("error");
            $j('.legal-address').closest(".block__inputs").removeClass("goods");
            $j('.legal-address-list').removeClass('good');
            //validateAddressInformation($j('.step-legal-details .legal-address'));
        }
    });

    $j('.legal-address-additionally').on('input click',function(e){
         if($j(".address-2").is(":checked") == true){
             var legalAddressAdditionally =  $j(this).val();
             $j(".document-address-additionally").val(legalAddressAdditionally);
         }
    });

    removeMultipleClick('legal-address', 'legal-address-list');

    $j("body").on("click",'.legal-address-item' , function(event) {
        $j(".legal-address-list").slideUp();
        $j(".legal-address").closest(".input__obl").removeClass("border-list-input");
        $j(".legal-address").val($j(this).find("strong").text());
        $j(".legal-address").closest(".block__inputs").addClass("goods")
        $j(".legal-address").closest(".block__inputs").removeClass("error");
        $j('.legal-address-list').addClass('good');
        saveAddressInformation('legalAddress',
                               $j(this).data("city"),
                               $j(this).data("postal_code"),
                               $j(this).data("region"),
                               $j(this).data("street"),
                               $j(this).data("house"));
        validateAddressInformation($j('.step-legal-details .legal-address'));
        if($j(".address-2").is(":checked") == true){
            $j(".document-address").val($j(this).find("strong").text());
            saveAddressInformation('postalAddress',
                                   $j(this).data("city"),
                                   $j(this).data("postal_code"),
                                   $j(this).data("region"),
                                   $j(this).data("street"),
                                   $j(this).data("house"));
            validateAddressInformation($j('.step-legal-details .document-address'));
        }
    });

    $j(".legal-address-list").mCustomScrollbar({
        theme:"dark"
    });
    /* Legal address search END */

    if($j('.address-2').is(":checked") == true) {
        $j(".document-address").closest(".block__inputs").removeClass("error");
        $j(".document-address").val($(".legal-address").val());
        $j(".document-address").removeClass("error");
        saveAddressInformation('postalAddress',
                                $j('[id$=legalAddressInformationCity]').val(),
                                $j('[id$=legalAddressInformationPostalCode]').val(),
                                $j('[id$=legalAddressInformationState]').val(),
                                $j('[id$=legalAddressInformationStreet]').val(),
                                $j('[id$=legalAddressInformationHouse]').val()
        );
        $j(".document-address").attr("disabled" , "disabled");

        $j(".document-address-additionally").val($j(".legal-address-additionally").val());
        $j(".document-address-additionally").attr("disabled" , "disabled");
    }

}

function saveCompanyInformation(nameFull){
    $j('[id$=companyInformationFullName]').val(nameFull);
}

function saveSoleProprietorLegalAddress(address) {
    $j('[id$=soleProprietorLegalAddress]').val(address);
}

function saveAddressInformation(addressType, city, postal_code, region, street, house){
    if(addressType == 'postalAddress'){
        $j('[id$=postalAddressInformationCity]').val(city);
        $j('[id$=postalAddressInformationPostalCode]').val(postal_code);
        $j('[id$=postalAddressInformationState]').val(region);
        $j('[id$=postalAddressInformationStreet]').val(street);
        $j('[id$=postalAddressInformationHouse]').val(house);
    } else if (addressType == 'legalAddress'){
        $j('[id$=legalAddressInformationCity]').val(city);
        $j('[id$=legalAddressInformationPostalCode]').val(postal_code);
        $j('[id$=legalAddressInformationState]').val(region);
        $j('[id$=legalAddressInformationStreet]').val(street);
        $j('[id$=legalAddressInformationHouse]').val(house);
    }
}

function saveBankInformation(shortName, okpo, bankTown, bankAddress){
    $j('[id$=bankInformationShortName]').val(shortName);
    $j('[id$=bankInformationOKPO]').val(okpo);
    $j('[id$=bankInformationTown]').val(bankTown);
    $j('[id$=bankInformationAddress]').val(bankAddress);
}

function goBackToOrderInformation(){
    $('#DiscountsModal_prev').prop('id', 'DiscountsModal');

    backToOrderInformation();
    return false;
}

function isCodeWordValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementLength > 4 && elementLength < 21) && regex.test(elementValue)){
        element.closest(".block__inputs").removeClass("error");
        element.closest(".block__inputs").addClass("goods");
        isValid = true;
    } else {
        element.closest(".block__inputs").removeClass("goods");
        element.closest(".block__inputs").addClass("error");
        isValid = false;
    }
    return isValid;
}

function isLegalInputValueValid(element, regex, numberOfSymbols, isOKPO){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if (isOKPO) {
            if((elementLength === numberOfSymbols) || (elementLength === (numberOfSymbols - 2))){
                element.closest(".block__inputs").removeClass("error");
                element.closest(".block__inputs").addClass("goods");
                isValid = true;
            }
            else {
                element.closest(".block__inputs").removeClass("goods");
                element.closest(".block__inputs").addClass("error");
                isValid = false;
            }
        } else {
            if(elementLength === numberOfSymbols) {
                element.closest(".block__inputs").removeClass("error");
                element.closest(".block__inputs").addClass("goods");
                /*element.attr("disabled" , "disabled");*/
                isValid = true;
            }
            else {
                element.closest(".block__inputs").removeClass("goods");
                element.closest(".block__inputs").addClass("error");

                isValid = false;
            }
        }
    } else {
        element.closest(".block__inputs").removeClass("goods");
        element.closest(".block__inputs").addClass("error");

        isValid = false;
    }
    return isValid;
}

function isInputValidOnChange(element){
    element.closest(".block__inputs").removeClass("goods");
}

function isLegalInputValueValidOnInput(element, regex, numberOfSymbols, isOKPO){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if (isOKPO) {
            if((elementLength === numberOfSymbols) || (elementLength === (numberOfSymbols - 2))){
                element.closest(".block__inputs").removeClass("error");
                element.closest(".block__inputs").addClass("goods");
                isValid = true;
            }
            else {
                element.closest(".block__inputs").removeClass("goods");
                isValid = false;
            }
        } else {
            if(elementLength === numberOfSymbols) {
                element.closest(".block__inputs").removeClass("error");
                element.closest(".block__inputs").addClass("goods");
                /*element.attr("disabled" , "disabled");*/
                isValid = true;
            }
            else {
                element.closest(".block__inputs").removeClass("goods");

                isValid = false;
            }
        }
    } else {
        element.closest(".block__inputs").removeClass("goods");

        isValid = false;
    }
    return isValid;
}

function validateLegalDetailsIfLegalEntity(){
    var currentStepBlock = $j('.step-legal-details');
    var ogrn = currentStepBlock.find('.js-orgn');
    var kpp = currentStepBlock.find('.js-kpp');
    var okpo = currentStepBlock.find('.js-okpo');
    var legalAddress = currentStepBlock.find('.legal-address');
    var documentAddress = currentStepBlock.find('.document-address');
    var checkboxForDocAddress = currentStepBlock.find('.address-2');;
    var executivePersonFullName = currentStepBlock.find('.executivePersonFullName');
    var executivePersonPosition = currentStepBlock.find('.executivePersonPosition');
    var codeWord = currentStepBlock.find('.codeWord');
    var accountEmail = currentStepBlock.find('.account-email');
    var isValid = false;
    var validatedFields = [];

    validatedFields.push(isLegalInputValueValid(ogrn, new RegExp(regs.numbers), 13, false));
    validatedFields.push(isLegalInputValueValid(kpp, new RegExp(regs.numbers), 9, false));
    validatedFields.push(isLegalInputValueValid(okpo, new RegExp(regs.numbers), 10, true));
    validatedFields.push(isInputValueValid(executivePersonFullName, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(executivePersonPosition, new RegExp(regs.position)));
    validatedFields.push(isCodeWordValueValid(codeWord, new RegExp(regs.codeWord)));
    validatedFields.push(isInputValueValid(accountEmail, new RegExp(regs.email)));

    validatedFields.push(validateAddressInformation(legalAddress));
    validatedFields.push(isInputValueValid(legalAddress, new RegExp(regs.address)));

    validatedFields.push(validateAddressInformation(documentAddress));
    validatedFields.push(isInputValueValid(documentAddress, new RegExp(regs.address)));

    isValid = validatedFields.indexOf(false) != -1 ? false : true;
    if(isValid){
       goToPaymentDetails();
    } else {
      var legalDetailsBlock = $j('.step-legal-and-payment-details .block__inputs.error');
      scrollToTopInput(legalDetailsBlock);
    }
    return false;
}

function validateAddressInformation(address){
    var isValid = true;

    if( !address.prop("disabled") ){
        if(address.hasClass('document-address')){
            if($j('[id$=postalAddressInformationCity]').val() == '')       { isValid = false; }
            if($j('[id$=postalAddressInformationPostalCode]').val() == '') { isValid = false; }
            if($j('[id$=postalAddressInformationState]').val() == '')      { isValid = false; }
            if($j('[id$=postalAddressInformationStreet]').val() == '')     { isValid = false; }
            if($j('[id$=postalAddressInformationHouse]').val() == '')      { isValid = false; }
        } else if (address.hasClass('legal-address')){
            if($j('[id$=legalAddressInformationCity]').val() == '')       { isValid = false; }
            if($j('[id$=legalAddressInformationPostalCode]').val() == '') { isValid = false; }
            if($j('[id$=legalAddressInformationState]').val() == '')      { isValid = false; }
            if($j('[id$=legalAddressInformationStreet]').val() == '')     { isValid = false; }
            if($j('[id$=legalAddressInformationHouse]').val() == '')      { isValid = false; }
        }
        if(isValid){
            address.closest(".block__inputs").removeClass("error");
            address.closest(".block__inputs").addClass("goods");
        } else {
            address.closest(".block__inputs").removeClass("goods");
            address.closest(".block__inputs").addClass("error");
        }
    }

    return isValid;
}


// IP
function validateLegalDetailsIfSoleProprietor(){
    var currentStepBlock = $j('.step-legal-details');
    var ogrnip = currentStepBlock.find('.ogrnip');
    var okpo = currentStepBlock.find('.js-okpo');
    var legalAddress = currentStepBlock.find('.legal-address');
    var documentAddress = currentStepBlock.find('.document-address');
    var checkboxForDocAddress = currentStepBlock.find('.address-2');
//    var chiefAccountant = currentStepBlock.find('.chiefAccountant');
    var codeWord = currentStepBlock.find('.codeWord');
    var accountEmail = currentStepBlock.find('.account-email');
    var isValid = false;
    var validatedFields = [];

    validatedFields.push(isLegalInputValueValid(ogrnip, new RegExp(regs.numbers), 15, false));
    validatedFields.push(isLegalInputValueValid(okpo, new RegExp(regs.numbers), 10, true));
//    validatedFields.push(isInputValueValid(chiefAccountant, new RegExp(regs.letters)));
    validatedFields.push(isCodeWordValueValid(codeWord, new RegExp(regs.codeWord)));
    validatedFields.push(isInputValueValid(accountEmail, new RegExp(regs.email)));

    validatedFields.push(validateAddressInformation(legalAddress));
    validatedFields.push(isInputValueValid(legalAddress, new RegExp(regs.address)));
    validatedFields.push(validateAddressInformation(documentAddress));
    validatedFields.push(isInputValueValid(documentAddress, new RegExp(regs.address)));

    isValid = validatedFields.indexOf(false) != -1 ? false : true;
    if(isValid){
       goToPaymentDetails();
    } else {
       var legalDetailsBlock = $j('.step-legal-and-payment-details .block__inputs.error');
       scrollToTopInput(legalDetailsBlock);
    }
    return false;
}


function validateLegalDetailsIfLegalEntityOnLoad(){
    var currentStepBlock = $j('.step-legal-details');
    var ogrn = currentStepBlock.find('.js-orgn');
    var kpp = currentStepBlock.find('.js-kpp');
    var okpo = currentStepBlock.find('.js-okpo');
    var legalAddress = currentStepBlock.find('.legal-address');
    var documentAddress = currentStepBlock.find('.document-address');
    var checkboxForDocAddress = currentStepBlock.find('.address-2');;
    var executivePersonFullName = currentStepBlock.find('.executivePersonFullName');
    var executivePersonPosition = currentStepBlock.find('.executivePersonPosition');
//    var chiefAccountant = currentStepBlock.find('.chiefAccountant');
    var codeWord = currentStepBlock.find('.codeWord');
    var accountEmail = currentStepBlock.find('.account-email');

    if(ogrn.val() != '') {
        isLegalInputValueValid(ogrn, new RegExp(regs.numbers), 13, false);
    }
    if(kpp.val() != '') {
        isLegalInputValueValid(kpp, new RegExp(regs.numbers), 9, false);
    }
    if(okpo.val() != '') {
        isLegalInputValueValid(okpo, new RegExp(regs.numbers), 10, true);
    }
    if(legalAddress.val() != '') {
        isInputValueValid(legalAddress, new RegExp(regs.address));
    }
    if(executivePersonFullName.val() != '') {
        isInputValueValid(executivePersonFullName, new RegExp(regs.letters));
    }
    if(executivePersonPosition.val() != '') {
        isInputValueValid(executivePersonPosition, new RegExp(regs.position));
    }
//    if(chiefAccountant.val() != '') {
//        isInputValueValid(chiefAccountant, new RegExp(regs.letters));
//    }
    if(codeWord.val() != '') {
        isCodeWordValueValid(codeWord, new RegExp(regs.codeWord));
    }
    if(documentAddress.val() != '') {
        isInputValueValid(documentAddress, new RegExp(regs.address));
    }
    if(accountEmail.val() != '') {
        isInputValueValid(accountEmail, new RegExp(regs.email));
    }
}

function validateLegalDetailsIfSoleProprietorOnLoad(){
    var currentStepBlock = $j('.step-legal-details');
    var ogrnip = currentStepBlock.find('.ogrnip');
    var okpo = currentStepBlock.find('.js-okpo');
    var legalAddress = currentStepBlock.find('.legal-address');
    var documentAddress = currentStepBlock.find('.document-address');
    var checkboxForDocAddress = currentStepBlock.find('.address-2');
//    var chiefAccountant = currentStepBlock.find('.chiefAccountant');
    var codeWord = currentStepBlock.find('.codeWord');
    var accountEmail = currentStepBlock.find('.account-email');

    if(ogrnip.val() != '') {
        isLegalInputValueValid(ogrnip, new RegExp(regs.numbers), 15, false);
    }
    if(okpo.val() != '') {
        isLegalInputValueValid(okpo, new RegExp(regs.numbers), 10, true);
    }
    if(legalAddress.val() != '') {
        isInputValueValid(legalAddress, new RegExp(regs.address));
    }
//    if(chiefAccountant.val() != '') {
//        isInputValueValid(chiefAccountant, new RegExp(regs.letters));
//    }
    if(codeWord.val() != '') {
        isCodeWordValueValid(codeWord, new RegExp(regs.codeWord));
    }
    if(documentAddress.val() != '') {
        isInputValueValid(documentAddress, new RegExp(regs.address));
    }
    if(accountEmail.val() != '') {
        isInputValueValid(accountEmail, new RegExp(regs.email));
    }
}

/*function validateLegalDetailsOnReturn(){

    $j("input[class=address-2]").on("change" , function() {
        if($j(this).is(":checked") == true) {
            $j(this).closest(".block__inputs").removeClass("error");
            $j(".document-address").val($j(".legal-address").val());
            $j(".document-address").attr("disabled" , "disabled");

            $j(".document-address-additionally").val($j(".legal-address-additionally").val());
            $j(".document-address-additionally").attr("disabled" , "disabled");
        }
        else {
            $j(".document-address").val("");
            $j(".document-address").removeAttr("disabled");

            $j(".document-address-additionally").val("");
            $j(".document-address-additionally").removeAttr("disabled");
        }
    });

}*/

function goBacktoLegalDetails(){
    backToLegalDetails();
    return false;
}

// ----- PAYMENT DETAILS STEP  STARTS-----
function setEvents_paymentDetails(){
    var currentStepBlock = $j('.step-payment-details');

    eraseInputValue('step-payment-details');

    var legalAndPaymentDetailsBlock = $j('.step-legal-and-payment-details .block__inputs').find('input');
    preventPressingEnterButton(legalAndPaymentDetailsBlock);

    var bik = currentStepBlock.find('.js-bik');
    bik.blur(function(e){
        isLegalInputValueValid(bik, new RegExp(regs.numbers), 9, false);
    });
    checkForAutoPasteNumericValues('js-bik');
    bik.on('input',function(){
        isLegalInputValueValidOnInput(bik, new RegExp(regs.numbers), 9, false);
    });

    var checkingAccount = currentStepBlock.find('.checkingAccount');
    checkingAccount.blur(function(e){
        isLegalInputValueValid(checkingAccount, new RegExp(regs.numbers), 20, false);
    });
    checkForAutoPasteNumericValues('checkingAccount');
    checkingAccount.on('input',function(){
        isLegalInputValueValidOnInput(checkingAccount, new RegExp(regs.numbers), 20, false);
    });

    var corAccount = currentStepBlock.find('.corAccount');
    corAccount.blur(function(e){
        isLegalInputValueValid(corAccount, new RegExp(regs.numbers), 20, false);
    });
    checkForAutoPasteNumericValues('corAccount');
    corAccount.on('input',function(){
        isLegalInputValueValidOnInput(corAccount, new RegExp(regs.numbers), 20, false);
    });

    var bankName = currentStepBlock.find('.bankName');
    bankName.blur(function(e){
        isInputValueValid(bankName, new RegExp(regs.bankName));
        bankName.closest(".input__obl").removeClass("border-list-input");
    });
    checkForAutoPasteValues('bankName', new RegExp(regs.bankName));
    bankName.on('input',function(){
        isInputValidOnChange(bankName);
    });

    var prepayment = currentStepBlock.find('.prepayment');
    prepayment.blur(function(e){
        isPrepaymentAmountValueValid(prepayment, new RegExp(regs.numbers));
    });
    checkForAutoPasteNumericValues('prepayment');

    $j(".close").on("click" , function(){
        var th = $j(this);
        th.closest(".block__inputs").removeClass("error");
        th.closest(".block__inputs").find("input").val("");
        th.closest(".block__inputs").find("input").focus()
    });

    var searchBankBlock = $j('.bankName').parent();
    if (!searchBankBlock.find('.bank-name-list')[0]){
         searchBankBlock.append('<div class="bank-name-list"></div>');
    }

    $j('.bankName').on('input',function(e){
        var textQuery =  $j(".bankName").val();
        $j('.bank-name-list').removeClass('good');
        if (textQuery != ''){
            sendRequestToDadata('bank', textQuery, 'searchBank');
        }
        else {
            formResultList(null,'searchBank');
        }
        saveBankInformation('','','','');
    });

    removeMultipleClick('bankName', 'bank-name-list');

    $j("body").on("click",'.bank-name-item' , function(event) {
        $j(".bank-name-list").slideUp();
        $j(".bankName").val($j(this).find("strong").text());
        $j(".bankName").closest(".block__inputs").addClass("goods")
        $j(".bankName").closest(".block__inputs").removeClass("error");
        $j('.bank-name-list').addClass('good');
        $j(".bankName").closest(".input__obl").removeClass("border-list-input");

        $j('.js-bik').val($j(this).data("bic"));
        $j(".js-bik").closest(".block__inputs").addClass("goods")
        $j(".js-bik").closest(".block__inputs").removeClass("error");
        $j('.corAccount').val($j(this).data("kc"));
        $j(".corAccount").closest(".block__inputs").addClass("goods")
        $j(".corAccount").closest(".block__inputs").removeClass("error");
        saveBankInformation($j(this).data("name-short"),
                            $j(this).data("okpo"),
                            $j(this).data("town"),
                            $j(this).data("address"));
    });

    $j(document).mouseup(function (e) {
        var containers = $j(".bank-name-list");
        if (containers.has(e.target).length === 0){
            containers.slideUp();
        }
    });

    $j(".bank-name-list").mCustomScrollbar({
        theme:"dark"
    });

    modalOpen('myModal2');
    modalClose('myModal2');
    $('.modal-button-continue').on("click" , function(){
        setTimeout(noScrollBackground, 500);
    });

    $('.preview-inside-button').attr('data-dismiss','modal');

    tooltipMode();
    tooltipInput_controller('bankName');
    tooltipInput_controller('prepayment');

}

function isPrepaymentAmountValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue >= 2000 && elementValue <= 9999999) && regex.test(elementValue)){
        element.closest(".block__inputs").removeClass("error");
        element.closest(".block__inputs").addClass("goods");

        isValid = true;
    } else {
        element.closest(".block__inputs").removeClass("goods");
        element.closest(".block__inputs").addClass("error");

        isValid = false;
    }
    return isValid;
}

function validatePaymentDetails(){
    var currentStepBlock = $j('.step-payment-details');
    var bank = currentStepBlock.find('.bankName');
    var bic = currentStepBlock.find('.js-bik');
    var checkingAcc = currentStepBlock.find('.checkingAccount');
    var correspondentAcc = currentStepBlock.find('.corAccount');
    var prepaymentAmt = currentStepBlock.find('.prepayment');
    var isValid = false;
    var validatedFields = [];

    validatedFields.push(isInputValueValid(bank, new RegExp(regs.bankName)));
    validatedFields.push(isLegalInputValueValid(bic, new RegExp(regs.numbers), 9, false));
    validatedFields.push(isLegalInputValueValid(checkingAcc, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isLegalInputValueValid(correspondentAcc, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isPrepaymentAmountValueValid(prepaymentAmt, new RegExp(regs.numbers)));

    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    $j('[id$=bankInformationInvalid]').val(getValidityOfBankData($j('.bankName').val(), $j('.js-bik').val(), $j('.corAccount').val()));

    if(isValid){
        //showWarningBeforeGoToCongratulations();
        $('#myModal2').modal('show');
    } else {
        var legalDetailsBlock = $j('.step-legal-and-payment-details .block__inputs.error');
        scrollToTopInput(legalDetailsBlock);
    }
    return false;
}

function validatePaymentDetailsToShowAgreement(){
    var currentStepBlock = $j('.step-payment-details');
    var bank = currentStepBlock.find('.bankName');
    var bic = currentStepBlock.find('.js-bik');
    var checkingAcc = currentStepBlock.find('.checkingAccount');
    var correspondentAcc = currentStepBlock.find('.corAccount');
    var prepaymentAmt = currentStepBlock.find('.prepayment');
    var isValid = false;
    var validatedFields = [];

    validatedFields.push(isInputValueValid(bank, new RegExp(regs.bankName)));
    validatedFields.push(isLegalInputValueValid(bic, new RegExp(regs.numbers), 9, false));
    validatedFields.push(isLegalInputValueValid(checkingAcc, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isLegalInputValueValid(correspondentAcc, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isPrepaymentAmountValueValid(prepaymentAmt, new RegExp(regs.numbers)));

    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    if(isValid){
       previewContract();
    } else {
       var legalDetailsBlock = $j('.step-legal-and-payment-details .block__inputs.error');
       scrollToTopInput(legalDetailsBlock);
    }
}

function validatePaymentDetailsOnLoad(){
    var currentStepBlock = $j('.step-payment-details');
    var bank = currentStepBlock.find('.bankName');
    var bic = currentStepBlock.find('.js-bik');
    var checkingAcc = currentStepBlock.find('.checkingAccount');
    var correspondentAcc = currentStepBlock.find('.corAccount');
    var prepaymentAmt = currentStepBlock.find('.prepayment');

    if(bank.val() != '') {
        isInputValueValid(bank, new RegExp(regs.bankName));
    }
    if(bic.val() != '') {
        isLegalInputValueValid(bic, new RegExp(regs.numbers), 9, false);
    }
    if(checkingAcc.val() != '') {
        isLegalInputValueValid(checkingAcc, new RegExp(regs.numbers), 20, false);
    }
    if(correspondentAcc.val() != '') {
        isLegalInputValueValid(correspondentAcc, new RegExp(regs.numbers), 20, false);
    }
    if(prepaymentAmt.val() != '') {
        isPrepaymentAmountValueValid(prepaymentAmt, new RegExp(regs.numbers));
    }
}

function getValidityOfBankData(bankName, bankBIC, bankKC){
    var bankInformationInvalid = true;
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/bank", false);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.setRequestHeader("Authorization", "Token " + apiTokenDaData);
    xhttp.send('{ "query": "' + bankBIC + '" }');
    var response = JSON.parse(xhttp.responseText);
    var suggestions = response.suggestions;
    if(suggestions.length > 0){
        if( bankName == suggestions[0].data.name.payment &&
            bankBIC == suggestions[0].data.bic &&
            bankKC == suggestions[0].data.correspondent_account ) {
                bankInformationInvalid = false;
        }
        var bankTown = '';
        if(suggestions[0].data.address.data != null) {
            bankTown = suggestions[0].data.address.data.city_with_type;
        }
        var bankNameShort = suggestions[0].data.name.short;
        if(bankNameShort == null){
            bankNameShort = suggestions[0].data.name.payment;
        }
        saveBankInformation(bankNameShort.split('"').join('&amp;quote'),
                            suggestions[0].data.okpo,
                            bankTown,
                            suggestions[0].data.address.value
        );
    }
    return bankInformationInvalid;
}

// ----- PAYMENT DETAILS STEP  ENDS-----

// ----- CONGRATULATIONS STEP  STARTS-----
function setEvents_Congratulations(){
    $j(".step-legal-and-payment-details .stetps__blocks_container").slideUp();
}

// ----- CONGRATULATIONS STEP ENDS-----

function setEvents_Modals(){
    $j(".modal-body").mCustomScrollbar({
        theme:"dark"
    });
}

// ---- CHAT ---

// ----- START CHAT SERVICE -----
function setChatOptions(){
    //First chat init on main page
    setupChatInit();

    autoChatTimeOut = 60000;

    //Event to reset active form  for client on form (auto chat call)
    $j(document).on('keydown click', function(){resetInActive()});

    //check : is tab still active
    $j(document).mouseout(function() { tabActive = false;})
                .mouseover(function() { tabActive = true;});

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
    $j(document).bind('DOMSubtreeModified', function(){
        var elementForms = document.getElementsByTagName('form');
        for (var i = 0; i < elementForms.length; i++) {
            if (elementForms[i].target == 'frameChat'){
                if (elementForms[i].action.toString().indexOf('language%3D%23') != -1){
                    var country = 'Russia';
                    elementForms[i].action = elementForms[i].action.replace('language%3D','language%3D'+country);
                }
            }
        }
    });

    if(screen.width < 1170){
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
    var country = 'Russia';
    if (country == 'Russia' && activeSubStep == 'ContactDetails'){
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
    liveagent.addCustomDetail("Step", activeSubStep , false).saveToTranscript('E2E_Step__c');
    liveagent.addCustomDetail("Mode of initialization", mode, false).saveToTranscript('Mode_of_initialization__c');
    liveagent.addCustomDetail("Type of chat", 'online', false).saveToTranscript('Type__c');
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
    if (document.getElementById('chat-button-online').style.display != 'none') {
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
                  }, 1000);
    }
}

function resetInActive(){
    clearTimeout(chatActivityTimeout);
    chatActivityTimeout = setTimeout(inActive, autoChatTimeOut);
}

function inActive(){
    if(tabActive){
        var chatOnlineButton =  document.getElementById('chat-button-online');
        if ((chatOnlineButton.style.display != 'none') && (chatOnlineButton.style.visibility != 'hidden')){
            var frameChatOnline = document.getElementById('frameChat');
            if((frameChatOnline == null) && !($j('#chatOfflineBlock').hasClass('popup-on'))){
                setupOnlineAutoChat();
            }
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
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes;
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

function redirectToURL(url){
    window.location.replace(url);
}

function preventPressingEnterButton(block) {
    $j(block).keypress(function(event){
    	if (event.keyCode == 13) {
            return false;
         }
    });
}

/*function setStartParameters(){
    var urlParams = window.location.search;
    var params = urlParams.substr(1, urlParams.length).split("&"); //remove '?'
    for (var i = 0; i < params.length; i++) {
        var pair = params[i].split("=");
        var key = decodeURIComponent(pair[0]).toUpperCase();
        var value = decodeURIComponent(pair[1]);
        if (key == 'CPHONE'){
            if(value.substr(0, 1)=='8' && value.length == 11){
                value = '7'+value.substr(1, value.length-1);
            }
            var currentStepBlock = $j('.step-contact-details');
            var phoneNumber = currentStepBlock.find('.phoneNumber');
            phoneNumber.val(value);
        }
        else if (key == 'CEMAIL'){
            var currentStepBlock = $j('.step-contact-details');
            var email = currentStepBlock.find('.emailAddress');
            email.val(value);
        }
    }
}*/