var isCompanyDetails = true;
var isPaymentDetails = true;
var isDocuments = true;
var isOffers = true;
var isCongrats = true;
var isDeposit = true;
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

function analytics_ZeroStepOnLoad() {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_0_EnterStep', 
		'pageType':'Tankkarte_0_EnterStep', 
		'stepCalc':0
	});
}

function analytics_ContactDetailsOnLoad() {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_Contacts', 
		'pageType':'Tankkarte_Form_Contacts', 
		'stepCalc':1
	});
}

function analytics_SearchCompanyOnLoad(companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	if (isCompanyDetails) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Form_Company', 
			'pageType':'Tankkarte_Form_Company',
			'stepCalc':2,
			'tabs_contacts': tabNumber
		});
		isCompanyDetails = false;
	}
}

function analytics_CompaniesListOnLoad(companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_Company_Search', 
		'pageType':'Tankkarte_Form_Company_Search',
		'stepCalc':2,
		'tabs_contacts': tabNumber
	});
}

function analytics_TotalConsumptionOnLoad(companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_FuelLiters', 
		'pageType':'Tankkarte_Form_FuelLiters',
		'stepCalc':3,
		'tabs_contacts': tabNumber
	});
}

function analytics_PaymentMethodOnLoad(companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_PaymentMethod', 
		'pageType':'Tankkarte_Form_PaymentMethod',
		'stepCalc':4,
		'tabs_contacts': tabNumber
	});
}


function analytics_PaymentMethodOnSelect(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_PaymentMethod_Selected', 
		'pageType':'Tankkarte_Form_PaymentMethod_Selected',
		'stepCalc':4,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_CardConfigurationOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsConfiguration', 
		'pageType':'Tankkarte_Config_CardsConfiguration',
		'stepCalc':5,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}

function analytics_CardConfigurationOptionsOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsConfigurationOptions', 
		'pageType':'Tankkarte_Config_CardsConfigurationOptions',
		'stepCalc':6,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_CardConfigurationPersonOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsPerson', 
		'pageType':'Tankkarte_Config_CardsPerson',
		'stepCalc':7,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_CardConfigurationSummaryOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsSummary', 
		'pageType':'Tankkarte_Config_CardsSummary',
		'stepCalc':8,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_SpecialOfferOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	if (isOffers) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Config_Offer', 
			'pageType': 'Tankkarte_Config_Offer',
			'stepCalc':9,
			'pay_method': paymentMethod,
			'pay_deposit': deposit,
			'tabs_contacts': tabNumber
		});
		isOffers = false;
	}
}

function analytics_AdditionalOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Additional', 
		'pageType': 'Tankkarte_Additional',
		'stepCalc':10,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}

function analytics_DBOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_BD', 
		'pageType': 'Tankkarte_BD',
		'stepCalc':11,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_DocumentsOnLoad(paymentMethod, deposit, companyForm) {
	if (isDocuments) {
		isDocuments = false;
		var tabNumber = returnTabNumber(companyForm);
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_AttentionSign', 
			'pageType': 'Tankkarte_AttentionSign',
			'stepCalc':12,
			'pay_method': paymentMethod,
			'pay_deposit': deposit,
			'tabs_contacts': tabNumber
		});
	}	
}


function analytics_PaymentDetailsDepositOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Payment_Details', 
		'pageType': 'Tankkarte_Payment_Details',
		'stepCalc':13,
		'pay_method': paymentMethod,
		'pay_deposit': deposit,
		'tabs_contacts': tabNumber
	});
}


function analytics_CongratsOnLoad(paymentMethod, deposit, companyForm) {
	var tabNumber = returnTabNumber(companyForm);
	if (isCongrats) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Success',
			'pageType':'Tankkarte_Success',
			'stepCalc':14,
			'pay_method': paymentMethod, 
			'pay_deposit': deposit,
			'tabs_contacts': tabNumber
		});
		isCongrats = false;
	}
}

var analyticsErrorsMap = new Map();
analyticsErrorsMap.set('0','Tankkarte_Form_Contacts');
analyticsErrorsMap.set('1-Search company','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Company not found','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Already in process','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Already a customer','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-More than two paid reports','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Authorization not granted','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Black list','Tankkarte_Form_Company');
analyticsErrorsMap.set('1-Set total consumption','Tankkarte_Form_FuelLiters');
// analyticsErrorsMap.set('1-Report does not exist','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Too high limit','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Too high limit. Additional Credit Scoring Allowance','Tankkarte_Form_FuelLiters');
// analyticsErrorsMap.set('1-Enter Tax ID','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Calculating credit score','Tankkarte_Form_PaymentMethod');
analyticsErrorsMap.set('2-Card configuration','Tankkarte_Config_CardsConfiguration');
// analyticsErrorsMap.set('2-Technical parameters','Tankkarte_Config_CardsPerson');
analyticsErrorsMap.set('2-Additional services','Tankkarte_Additional');
analyticsErrorsMap.set('3-Documents','Tankkarte_AttentionSign');
analyticsErrorsMap.set('4-DirectDebitDeposit','Tankkarte_Payment_Deposit');
analyticsErrorsMap.set('4-BankTransferDeposit','Tankkarte_Payment_Deposit');
analyticsErrorsMap.set('5-Congratulations','Tankkarte_Success');

function analytics_AddError(step, page, eventaction) {
    var analyticsFinalError = '';
    if (page == 'Contact details') {
        analyticsFinalError = analyticsErrorsMap.get('0');
    } else {
        analyticsFinalError = analyticsErrorsMap.get(step + '-' + page);
    }
    dataLayer.push({
    	'event': 'TankkarteError', 
    	'eventCategory': 'TankkarteStepError', 
    	'eventAction': eventaction, 
    	'eventLabel': analyticsFinalError
    });
}
