var paymentMethodAnalytics;
var isDepositAnalytics;
var isCompanySearch;
var isOffersPage;
var isPaymentDetails;
var isTechnicalParameters;
var sameCardsArray;
var diffCardsArray;
var selectedOfferAnalytics;
var isPaymentDeposit;
var activePageAnalytics;

function returnTabNumber(companyForm) {
    if (companyForm == 'Company') {
        return 1;
    } else
    if (companyForm == 'Solo-trader') {
        return 2;
    } else 
    if (companyForm == 'Private') {
        return 3;
    }
    return 0;
}

function analytics_ContactDetailsOnLoad() {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_Contacts', 
        'pageType':'Tankkarte_Form_Contacts', 
        'stepCalc':1
    });
    isCompanySearch = true;
}

function analytics_SearchCompanyOnLoad(companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_Company', 
        'pageType':'Tankkarte_Form_Company', 
        'stepCalc':2,
        'tabs_contacts': tabNumber
    });
}

function analytics_SearchCompanyOnClickSearch(companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_Company_Search', 
        'pageType':'Tankkarte_Form_Company_Search', 
        'stepCalc':2,
        'tabs_contacts':tabNumber
    });
}

function analytics_FuelLitersOnLoad(companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_FuelLiters', 
        'pageType':'Tankkarte_Form_FuelLiters', 
        'stepCalc':3,
        'tabs_contacts':tabNumber
    });
    isCompanySearch = true;
}

function analytics_PaymentMethodOnLoad(companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_PaymentMethod', 
        'pageType':'Tankkarte_Form_PaymentMethod', 
        'stepCalc':4,
        'tabs_contacts':tabNumber
    });
}

function analytics_PaymentMethodNext(paymentMethod, isDeposit, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Form_PaymentMethod_Selected', 
        'pageType':'Tankkarte_Form_PaymentMethod_Selected',
        'stepCalc':4,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts':tabNumber
    });
}

function analytics_CardsConfigOnLoad(paymentMethod, isDeposit, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Config_CardsConfiguration', 
        'pageType':'Tankkarte_Config_CardsConfiguration',
        'stepCalc':5,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts':tabNumber
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

function analytics_ConfigOfferOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Config_Offer', 
        'pageType':'Tankkarte_Config_Offer',
        'stepCalc':6,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts':tabNumber
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

function analytics_CardsPersonOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Config_CardsPerson', 
        'pageType':'Tankkarte_Config_CardsPerson',
        'stepCalc':7,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts':tabNumber
    });
}

function analytics_AdditionalOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Additional', 
        'pageType':'Tankkarte_Additional',
        'stepCalc':8,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts': tabNumber
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

function analytics_DOBOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_BD', 
        'pageType':'Tankkarte_BD',
        'stepCalc':9,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts': tabNumber
    });
}

function analytics_DocumentsOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_AttentionSign', 
        'pageType':'Tankkarte_AttentionSign',
        'stepCalc':10,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts': tabNumber
    });
}

function analytics_PaymentDepositOnLoad(paymentMethod, isDeposit, cardsJson, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Payment_Deposit', 
        'pageType':'Tankkarte_Payment_Deposit',
        'stepCalc':11,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts': tabNumber
    });
    console.log(paymentMethod);
    console.log(isDeposit);
    console.log(tabNumber);
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

function analytics_thankYouPage(paymentMethod, isDeposit, companyForm) {
    var tabNumber = returnTabNumber(companyForm);
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
        'event':'Tankkarte_Success', 
        'pageType':'Tankkarte_Success',
        'stepCalc':12,
        'pay_method': paymentMethod,
        'pay_deposit': isDeposit,
        'tabs_contacts':tabNumber
    });
}

var analyticsErrorsMap = new Map();
analyticsErrorsMap.set('0','Tankkarte_Form_Contacts');
analyticsErrorsMap.set('1-Search company','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Company not found','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Already in process','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Already a customer','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Too many reports','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Set total consumption','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Report does not exist','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Too high limit. Additional Credit Scoring Allowance','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Risky but manageable','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Too risky','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Authorization not granted','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Black list','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Calculating credit score','Tankkarte_Form_PaymentMethod');
analyticsErrorsMap.set('2-Card configuration','Tankkarte_Config_CardsConfiguration');
analyticsErrorsMap.set('2-Choosing offer','Tankkarte_Config_CardsConfiguration');
analyticsErrorsMap.set('2-Technical parameters','Tankkarte_Config_CardsPerson');
analyticsErrorsMap.set('2-Additional services','Tankkarte_Additional');
analyticsErrorsMap.set('2-Enter Date of Birth','Tankkarte_DB');
analyticsErrorsMap.set('3-Documents','Tankkarte_AttentionSign');
analyticsErrorsMap.set('4-BankTransferDeposit','Tankkarte_Payment_Deposit');
analyticsErrorsMap.set('4-DirectDebitDeposit','Tankkarte_Payment_Deposit');
analyticsErrorsMap.set('5-Congratulations','Tankkarte_Success');

function analytics_anyError(errorSubstep,errorPage,errorText) {
    var analyticsFinalError = '';
    if (errorPage == '0') {
        analyticsFinalError = analyticsErrorsMap.get('0');
    } else 
    if (errorPage == undefined) {
        analyticsFinalError = 'Undefined Step';
    } else {
        analyticsFinalError = analyticsErrorsMap.get(errorPage + '-' + errorSubstep);
    }
    dataLayer.push({
        'event': 'TankkarteError', 
        'eventCategory': 'TankkarteStepError', 
        'eventAction': errorText, 
        'eventLabel': analyticsFinalError
    });
}

// UI
function analytics_onClickButtonSendUI(action, buttonName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI', 
       eventAction: action, 
       eventLabel: buttonName, 
       eventCategory: category
    });
}

function analytics_onClickOrderButtonSendUI(buttonName, activeSubStep) {
    var category;
    if (activeSubStep == 'Search company') {
        category = 'UI_02_Tankkarte_Step_2_Form_Company';
    } else if (activeSubStep == 'Set total consumption' || activeSubStep == 'Additional Credit Scoring Allowance') {
        category = 'UI_03_Tankkarte_Step_3_Form_FuelLiters';
    } else if (activeSubStep == 'Calculating credit score') {
        category = 'UI_04_Tankkarte_Step_4_Form_PaymentMethod';
    } else if (activeSubStep == 'Card configuration') {
        category = 'UI_05_Tankkarte_Step_5_Config_CardsConfiguration';
    } else if (activeSubStep == 'Choosing offer') {
        category = 'UI_05_Tankkarte_Step_5_Config_CardsConfiguration';
    } else if (activeSubStep == 'Technical parameters') {
        category = 'UI_07_Tankkarte_Step_7_Config_CardsPerson';
    } else if (activeSubStep == 'Additional services') {
        category = 'UI_08_Tankkarte_Step_8_Additional';
    } else if (activeSubStep == 'Enter Date of Birth') {
        category = 'UI_09_Tankkarte_Step_9_BD';
    } else if (activeSubStep == 'BankTransferDeposit') {
        category = 'UI_11_Tankkarte_Step_11_Payment_Deposit';
    } else if (activeSubStep == 'DirectDebitDeposit') {
        category = 'UI_11_Tankkarte_Step_11_Payment_Deposit';
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


function analytics_onClickSlideSendUI(sliderName, category) {
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
       event: 'TankkarteUI', 
       eventCategory: category, 
       eventAction: 'slide', 
       eventLabel: 'slider: ' + sliderName
    });
}



