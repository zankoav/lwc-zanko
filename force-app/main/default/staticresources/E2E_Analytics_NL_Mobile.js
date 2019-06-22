var isCompanyDetails = true;
var isPaymentDetails = true;
var isOffers = true;
var isCongrats = true;
var isDeposit = true;
var isSearchCompany = true;
var activePageAnalytics;

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

function analytics_SearchCompanyOnLoad() {
	if (isCompanyDetails) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Form_Company', 
			'pageType':'Tankkarte_Form_Company',
			'stepCalc':2
		});
		isCompanyDetails = false;
	}
}

function analytics_TaxIdOnLoad() {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_Company_TaxID', 
		'pageType':'Tankkarte_Form_Company_TaxID', 
		'stepCalc':2
	});
}

function analytics_CompaniesListOnLoad() {
	if (isSearchCompany) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Form_Company_Search', 
			'pageType':'Tankkarte_Form_Company_Search',
			'stepCalc':2
		});
		isSearchCompany = false;
	}
}

function analytics_TotalConsumptionOnLoad() {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_FuelLiters', 
		'pageType':'Tankkarte_Form_FuelLiters',
		'stepCalc':3
	});
}

function analytics_PaymentMethodOnLoad() {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_PaymentMethod', 
		'pageType':'Tankkarte_Form_PaymentMethod',
		'stepCalc':4
	});
}


function analytics_PaymentMethodOnSelect(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Form_PaymentMethod_Selected', 
		'pageType':'Tankkarte_Form_PaymentMethod_Selected',
		'stepCalc':4,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}


function analytics_CardConfigurationOnLoad(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsConfiguration', 
		'pageType':'Tankkarte_Config_CardsConfiguration',
		'stepCalc':5,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}

function analytics_CardConfigurationOptionsOnLoad(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsConfigurationOptions', 
		'pageType':'Tankkarte_Config_CardsConfigurationOptions',
		'stepCalc':6,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}


function analytics_CardConfigurationPersonOnLoad(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsPerson', 
		'pageType':'Tankkarte_Config_CardsPerson',
		'stepCalc':7,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}


function analytics_CardConfigurationSummaryOnLoad(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Config_CardsSummary', 
		'pageType':'Tankkarte_Config_CardsSummary',
		'stepCalc':8,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}


function analytics_SpecialOfferOnLoad(paymentMethod, deposit) {
	if (isOffers) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Config_Offer', 
			'pageType': 'Tankkarte_Config_Offer',
			'stepCalc':9,
			'pay_method': paymentMethod,
			'pay_deposit': deposit
		});
		isOffers = false;
	}
}

function analytics_AdditionalOnLoad(paymentMethod, deposit) {
	window.dataLayer = window.dataLayer || [];
	dataLayer.push({
		'event':'Tankkarte_Additional', 
		'pageType': 'Tankkarte_Additional',
		'stepCalc':10,
		'pay_method': paymentMethod,
		'pay_deposit': deposit
	});
}

function analytics_PaymentDetailsOnLoad(paymentMethod, deposit) {
	if (isPaymentDetails) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Payment_Details', 
			'pageType':'Tankkarte_Payment_Details',
			'stepCalc':11,
			'pay_method': paymentMethod,
			'pay_deposit': deposit
		});
		isPaymentDetails = false;
	}
}


function analytics_PaymentDetailsDepositOnLoad() {
	if (isDeposit) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Payment_Details_PaySystem', 
			'pageType':'Tankkarte_Payment_Details_PaySystem', 
			'stepCalc':11
		});
		isDeposit = false;
	}
}


function analytics_CongratsOnLoad(paymentMethod, deposit) {
	if (isCongrats) {
		window.dataLayer = window.dataLayer || [];
		dataLayer.push({
			'event':'Tankkarte_Success',
			'pageType':'Tankkarte_Success',
			'stepCalc':12,
			'pay_method': paymentMethod, 
			'pay_deposit': deposit
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
analyticsErrorsMap.set('1-Too high limit','Tankkarte_Form_FuelLiters');
analyticsErrorsMap.set('1-Calculating credit score','Tankkarte_Form_PaymentMethod');
analyticsErrorsMap.set('2-Card configuration','Tankkarte_Config_CardsConfiguration');
analyticsErrorsMap.set('3-Additional services','Tankkarte_Additional');
analyticsErrorsMap.set('4-DirectDebit','Tankkarte_Payment_Details');
analyticsErrorsMap.set('4-BankTransfer','Tankkarte_Payment_Details');
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
