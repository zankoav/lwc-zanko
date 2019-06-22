var paymentMethodAnalytics;
var isDepositAnalytics;
var isCompanySearch;
var isOffersPage;
var isPaymentDetails;
var isPaymentDeposit;
var isTechnicalParameters;
var sameCardsArray;
var diffCardsArray;
var selectedOfferAnalytics;
var activePageAnalytics;


function analytics_ContactDetailsOnLoad() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_1_Form_Contacts',
    'pageType':'Tankkarte_Step_1_Form_Contacts',
    'stepCalc':1
    });
    isCompanySearch = true;
}

function analytics_SearchCompanyOnLoad() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_2_Form_Company',
    'pageType':'Tankkarte_Step_2_Form_Company',
    'stepCalc':2
    });
}

function analytics_SearchCompanyOnClickSave() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_2_Form_Company_Save',
    'pageType':'Tankkarte_Step_2_Form_Company_Save',
    'stepCalc':2
    });
}

function analytics_SearchCompanyOnClickSearch() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_2_Form_Company_Search',
    'pageType':'Tankkarte_Step_2_Form_Company_Search',
    'stepCalc':2
    });
}

function analytics_FuelLitersOnLoad() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_3_Form_FuelLiters',
    'pageType':'Tankkarte_Step_3_Form_FuelLiters',
    'stepCalc':3
    });
    isCompanySearch = true;
}

function analytics_FuelLitersOnClickSave() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_3_Form_FuelLiters_Save',
    'pageType':'Tankkarte_Step_3_Form_FuelLiters_Save',
    'stepCalc':3
    });
}

function analytics_PaymentMethodOnLoad() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_4_Form_PaymentMethod',
    'pageType':'Tankkarte_Step_4_Form_PaymentMethod',
    'stepCalc':4
    });
}

function analytics_PaymentMethodNext(paymentMethod, isDeposit) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_4_Form_PaymentMethod_Selected',
    'pageType':'Tankkarte_Step_4_Form_PaymentMethod_Selected',
    'stepCalc':4,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });
}

function analytics_CardsConfigOnLoad(paymentMethod, isDeposit) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_5_Config_CardsConfiguration',
    'pageType':'Tankkarte_Step_5_Config_CardsConfiguration',
    'stepCalc':5,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });
}

function analytics_CardsConfigOnFinish(cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 1},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep1',
        'nonInter': 'False'
    });
}

function analytics_ConfigOfferOnLoad(paymentMethod, isDeposit, cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_6_Config_Offer',
    'pageType':'Tankkarte_Step_6_Config_Offer',
    'stepCalc':6,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 2},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep2',
        'nonInter': 'False'
    });
}

function analytics_ConfigOfferOnOfferSelection(paymentMethod, isDeposit) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_6_Config_OfferSelected',
    'pageType':'Tankkarte_Step_6_Config_OfferSelected',
    'stepCalc':6,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });
}

function analytics_ConfigOfferOnNext(selectedOfferName) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
          'checkout_option': {
            'actionField': {'step': 2, 'option': selectedOfferName}
          }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutOption',
        'nonInter': 'False'
    });
}

function analytics_CardsPersonOnLoad(paymentMethod, isDeposit, cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_7_Config_CardsPerson',
    'pageType':'Tankkarte_Step_7_Config_CardsPerson',
    'stepCalc':7,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 3},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep3',
        'nonInter': 'False'
    });
}

function analytics_AdditionalOnLoad(paymentMethod, isDeposit, cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_8_Additional',
    'pageType':'Tankkarte_Step_8_Additional',
    'stepCalc':8,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 4},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep4',
        'nonInter': 'False'
    });
}

function analytics_AdditionalOnSelect(selectedOfferName, isAdditionalSelected) {
    if (isAdditionalSelected) {
        window.dataLayer = window.dataLayer || [];
        dataLayer.push({
            'ecommerce': {
              'checkout_option': {
                'actionField': {'step': 4, 'option': selectedOfferName}
              }
            },
            'event': 'GAEcom',
            'eventCategory': 'Ecommerce',
            'eventAction': 'CheckoutOption',
            'nonInter': 'False'
        });
    }
}

function analytics_PaymentDetailsOnLoad(paymentMethod, isDeposit, cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_9_Payment_Details',
    'pageType':'Tankkarte_Step_9_Payment_Details',
    'stepCalc':9,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 5},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep5',
        'nonInter': 'False'
    });
}

function analytics_PaymentDepositOnLoad(paymentMethod, isDeposit, cardsJson) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Step_10_Payment_Deposit',
    'pageType':'Tankkarte_Step_10_Payment_Deposit',
    'stepCalc':10,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit
    });

    dataLayer.push({
        'ecommerce': {
            'checkout': {
                'actionField': {'step': 6},
                'products': cardsJson
            }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutStep6',
        'nonInter': 'False'
    });
}

function analytics_PaymentDepositOnPay(selectedPaymentType) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'ecommerce': {
          'checkout_option': {
            'actionField': {'step': 6, 'option': selectedPaymentType}
          }
        },
        'event': 'GAEcom',
        'eventCategory': 'Ecommerce',
        'eventAction': 'CheckoutOption',
        'nonInter': 'False'
    });
}

function analytics_thankYouPage(paymentMethod, isDeposit, cardsJson, pageType, paymentType) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
    'event':'Tankkarte_Success',
    'pageType':'Tankkarte_Success',
    'stepCalc':13,
    'pay_method': paymentMethod,
    'pay_deposit': isDeposit,
    'type_type': pageType
    });

    dataLayer.push({
      'ecommerce': {
        'purchase': {
          'actionField': {
            'id': Date.now(),
            'revenue': '1',
            'tax':'1',
            'affiliation':'Tankkarte_' + pageType + '_' + paymentType + '_' + isDeposit,
            'shipping': '0',
            'coupon': ''
          },
          'products': cardsJson
        }
      },
      'event': 'GAEcom',
      'eventCategory': 'Ecommerce',
      'eventAction': 'Purchase',
      'nonInter': 'False'
    });
}

var analyticsErrorsMap = new Map();
analyticsErrorsMap.set('0','Tankkarte_Step_1_Form_Contacts');
analyticsErrorsMap.set('1-Search company','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Company not found','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Already in process','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Already a customer','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-More than two paid reports','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Set total consumption','Tankkarte_Step_3_Form_FuelLiters');
analyticsErrorsMap.set('1-Report does not exist','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Too high limit','Tankkarte_Step_3_Form_FuelLiters');
analyticsErrorsMap.set('1-Authorization not granted','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Black list','Tankkarte_Step_2_Form_Company');
analyticsErrorsMap.set('1-Calculating credit score','Tankkarte_Step_4_Form_PaymentMethod');
analyticsErrorsMap.set('2-Card configuration','Tankkarte_Step_5_Config_CardsConfiguration');
analyticsErrorsMap.set('2-Choosing offer','Tankkarte_Step_5_Config_CardsConfiguration');
analyticsErrorsMap.set('2-Technical parameters','Tankkarte_Step_7_Config_CardsPerson');
analyticsErrorsMap.set('3-Additional services','Tankkarte_Step_8_Additional');
analyticsErrorsMap.set('4-DirectDebit','Tankkarte_Step_9_Payment_Details');
analyticsErrorsMap.set('4-DirectDebitDeposit','Tankkarte_Step_10_Payment_Deposit');
analyticsErrorsMap.set('5-Congratulations','Tankkarte_Success');

function analytics_anyError(errorSubStep, errorPage, errorText) {
    var analyticsFinalError = '';
    if (errorPage == '0') {
        analyticsFinalError = analyticsErrorsMap.get('0');
    } else
    if (errorPage == undefined) {
        analyticsFinalError = 'Undefined Step';
    } else {
        analyticsFinalError = analyticsErrorsMap.get(errorPage + '-' + errorSubStep);
    }
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        event: 'TankkarteError',
        eventCategory: 'TankkarteStepError',
        eventAction: errorText,
        eventLabel: analyticsFinalError
    });
}

// UI
function analytics_onClickButtonSendUI(buttonName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'click',
       eventLabel: 'button: ' + buttonName
    });
}

function analytics_onActionSendUI(action, buttonName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: action,
       eventLabel: buttonName
    });
}

function analytics_onClickOrderButtonSendUI(buttonName, activeSubStep) {
    var category;
    if (activeSubStep == 'Search company') {
        category = 'UI_02_Tankkarte_Step_2_Form_Company';
    } else if (activeSubStep == 'Set total consumption') {
        category = 'UI_03_Tankkarte_Step_3_Form_FuelLiters';
    } else if (activeSubStep == 'Calculating credit score') {
        category = 'UI_04_Tankkarte_Step_4_Form_PaymentMethod';
    } else if (activeSubStep == 'Card configuration') {
        category = 'UI_05_Tankkarte_Step_5_Config_CardsConfiguration';
    } else if (activeSubStep == 'Choosing offer') {
        category = 'UI_06_Tankkarte_Step_6_Config_Offer';
    } else if (activeSubStep == 'Technical parameters') {
        category = 'UI_07_Tankkarte_Step_7_Config_CardsPerson';
    } else if (activeSubStep == 'Additional services') {
        category = 'UI_08_Tankkarte_Step_8_Additional';
    } else if (activeSubStep == 'DirectDebit') {
        category = 'UI_09_Tankkarte_Step_9_Payment_Details';
    } else if (activeSubStep == 'DirectDebitDeposit') {
        category = 'UI_10_Tankkarte_Step_10_Payment_Deposit';
    }

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'click',
       eventLabel: 'button: ' + buttonName
    });
}


function analytics_onBlurInputSendUI(input, inputName, category) {
    if (input != null && input != undefined && input.val() != null && input.val() != '') {
        window.dataLayer = window.dataLayer || [];
        dataLayer.push({
           event: 'TankkarteUI',
           eventCategory: category,
           eventAction: 'fill',
           eventLabel: 'input: ' + inputName
        });
    }
}


function analytics_onClickCheckboxSendUI(input, checkboxName, category) {
    var checkbox_value = checkboxName;
    if (input.prop('checked')) {
        checkbox_value = checkbox_value + '_on';
    } else {
        checkbox_value = checkbox_value + '_off';
    }

    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'click',
       eventLabel: 'checkbox: ' + checkbox_value
    });
}


function analytics_onErrorSendUI(errorDescription, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'error',
       eventLabel: 'error: ' + errorDescription
    });
}


function analytics_onClickTabsSendUI(tabName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'click',
       eventLabel: 'tabs: ' + tabName
    });
}


function analytics_onClickRadioSendUI(radioName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'click',
       eventLabel: 'radio: ' + radioName
    });
}


function analytics_onClickSlideSendUI(sliderValue, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI',
       eventCategory: category,
       eventAction: 'slide',
       eventLabel: 'slider: ' + sliderValue
    });
}