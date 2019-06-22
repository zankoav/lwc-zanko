/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepCreditScoringController.getStaticData';
import apexStepSubmit from '@salesforce/apex/StepCreditScoringController.stepSubmit';
import apexChangeBillingPeriod from '@salesforce/apex/StepCreditScoringController.changeBillingPeriod';
import apexChangeCreditLimit from '@salesforce/apex/StepCreditScoringController.changeCreditLimit';

export default class StepCreditScoring extends BaseStep {
    @api lang;
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    @track stateStep;
    @track paymentDescription;
    @track billingDescription;

    submitButton;

    connectedCallback() {
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then(result => {
                console.log('static loaded : ', result);
                this.staticData = result;
                this.stateStep = {
                    country: this.staticData.country,
                    language: this.staticData.language,
                    payment_method: this.staticData.payment_method,
                    billing_period: this.staticData.billing_period,
                    credit_limit: iterationCopy(this.staticData.credit_limit),
                    credit_limit_min: this.staticData.credit_limit_min,
                    credit_limit_max: this.staticData.credit_limit_max,
                    credit_limit_step: this.staticData.credit_limit_step,
                    deposit: this.staticData.deposit,
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                    monthly_volume: this.staticData.monthly_volume,
                    total_consumption: this.staticData.total_consumption,
                };
                this.paymentDescription = this.getPaymantDescriptionByValue(this.stateStep.payment_method.value);
                this.billingDescription = this.getBillingDescriptionByValue(this.stateStep.billing_period.value);
                this.loading = false;
            })
            .catch(error => {
                console.log('static load error : ', error);
            });
    }

    renderedCallback() {
        this.submitButton = this.template.querySelectorAll('c-fc-button')[1];
    }

    changePaymentMethod(event) {
        this.stateStep.payment_method.value = event.detail;
        this.paymentDescription = this.getPaymantDescriptionByValue(this.stateStep.payment_method);
    }

    changePayBills(event) {
        this.stateStep.billing_period.value = event.detail;
        this.billingDescription = this.getBillingDescriptionByValue(this.stateStep.billing_period.value);
        this.loading = true;
        apexChangeBillingPeriod({ 
            apexService: this.apexService,
            stateStep: this.stateStep,
        })
            .then(result => {
                console.log(result);
                this.loading = false;
            })
            .catch(error => {
                console.log('error apexChangeBillingPeriod', error);
                this.loading = false;
            });
    }

    

    addCreditLimit() {
        const maxValue = parseInt(this.stateStep.credit_limit_max, 10);
        const stepValue = parseInt(this.stateStep.credit_limit_step, 10);
        const currentValue = parseInt(this.stateStep.credit_limit.value, 10);

        if (currentValue + stepValue <= maxValue) {
            this.stateStep.credit_limit.value = currentValue + stepValue;
            this.stateStep = iterationCopy(this.stateStep);
            this.changeCreditLimitHelper();
        }
    }

    minusCreditLimit() {
        const minValue = parseInt(this.stateStep.credit_limit_min, 10);
        const stepValue = parseInt(this.stateStep.credit_limit_step, 10);
        const currentValue = parseInt(this.stateStep.credit_limit.value, 10);

        if (currentValue - stepValue >= minValue) {
            this.stateStep.credit_limit.value = currentValue - stepValue;
            this.stateStep = iterationCopy(this.stateStep);
            this.changeCreditLimitHelper();
        }
    }

    changeCreditLimit(event) {
        this.stateStep.credit_limit.value = parseInt(event.target.value, 10);
        this.stateStep = iterationCopy(this.stateStep);
        this.changeCreditLimitHelper();
    }

    getPaymantDescriptionByValue(value) {
        const methodItem = this.staticData.payment_method.options.find(item => item.value === value);
        return methodItem ? methodItem.description : null;
    }

    getBillingDescriptionByValue(value) {
        const methodItem = this.staticData.billing_period.options.find(item => item.value === value);
        return methodItem ? methodItem.description : null;
    }

    changeCreditLimitHelper() {
        this.loading = true;
        apexChangeCreditLimit({ 
            apexService: this.apexService,
            stateStep: this.stateStep,
        })
            .then(result => {
                console.log('result', result);
                this.loading = false;
            })
            .catch(error => {
                console.log('error', error);
                this.loading = false;
            });
    }

    stepSubmit() {
        this.loading = true;
        console.log("state step  = ", this.stateStep);
        console.log("state step credit value = ", this.stateStep.credit_limit.value);
        apexStepSubmit({
            apexService : this.apexService, 
            stateStep : this.stateStep
        })
            .then(result => {
                console.log('result apexStepSubmit', result);
                this.nextStep();
            })
            .catch(error => {
                console.log('error apexStepSubmit', error);
                this.loading = false;
            });
    }

}

function iterationCopy(src) {
    let target = {};
    for (let prop in src) {
        if (src.hasOwnProperty(prop)) {
            target[prop] = src[prop];
        }
    }
    return target;
}