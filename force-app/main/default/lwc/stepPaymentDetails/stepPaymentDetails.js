/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepPaymentOptionsController.getStaticData';
import save from '@salesforce/apex/StepPaymentOptionsController.save';

export default class StepPaymentDetails extends BaseStep {

    nameStep = "payment options";
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    stepState;
    continueButton;

    connectedCallback () {
        console.log("step : ", this.nameStep);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then( (result) => {  
                console.log("static data loaded.");
                this.staticData = result;
                this.stepState = {
                    country: this.staticData.country,
                    language: this.staticData.language,
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                    contact_id: this.staticData.contact_id,
                    iban: this.staticData.iban.value,
                    swift: this.staticData.swift.value,
                    sepa_block: this.staticData.sepa_block.accept_value === "false" ? false : true,
                    account_holder: this.staticData.account_holder.value,
                    paper_invoice: this.staticData.paper_invoice.value,
                    decision_agreement: this.staticData.decision_agreement.value === "false" ? false : true,
                    terms_and_cond_agreement: this.staticData.terms_and_cond_agreement.value === "false" ? false : true,
                    continue_button: this.staticData.continue_button.disabled,
                };
                console.log(this.stepState);
                this.loading = false;
            })
            .catch( error => {
                console.log("static data error = ", error);
            });
    }

    renderedCallback () {
        this.continueButton = this.template.querySelector('c-fc-button[data-name="continue_button"]');
        this.stepValidator();
    }

    accountHolderHandler (event) {
        const element = event.target;
        const value = event.detail;
        this.stepState.account_holder = value;
        if ( this.accountHolderValidator(value) ) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.stepValidator();
    }

    accountHolderValidator (value) {
        const length = value.length;
        const resource = this.staticData.account_holder;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength && length >= resource.minLength);
    }

    ibanHandler (event) {
        const element = event.target;
        const value = event.detail;
        this.stepState.iban = value;
        if ( this.ibanValidator(value) ) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.stepValidator();
    }

    ibanValidator (value) {
        const length = value.length;
        const resource = this.staticData.iban;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength && length >= resource.minLength);
    }

    swiftHandler (event) {
        const element = event.target;
        const value = event.detail;
        this.stepState.swift = value;
        if ( this.swiftValidator(value) ) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.stepValidator();
    }

    swiftValidator (value) {
        const length = value.length;
        const resource = this.staticData.swift;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength && length >= resource.minLength);
    }

    paperInvoiceHandler (event) {
        const value = event.detail;
        this.stepState.paper_invoice = value;
    }

    sepaBlockHandler (event) {
        const value = event.detail;
        this.stepState.sepa_block = value;
        this.stepValidator();
    }
    
    decisionAgreementHandler (event) {
        const value = event.detail;
        this.stepState.decision_agreement = value;
        this.stepValidator();
    }

    termAndCondHandler (event) {
        const value = event.detail;
        this.stepState.terms_and_cond_agreement = value;
        this.stepValidator();
    }

    stepValidator () {
        if ( !this.stepState) {
            return;
        }

        let isValidStep = true;
        //account_holder
        if ( !this.accountHolderValidator(this.stepState.account_holder) ) {
            isValidStep = false;
        }
        //iban
        if ( !this.ibanValidator(this.stepState.iban) ) {
            isValidStep = false;
        }
        //swift
        if ( this.staticData.swift.show_field === "true" && !this.swiftValidator(this.stepState.swift) ) {
            isValidStep = false;
        }
        //checkboxes
        if ( !this.stepState.sepa_block || !this.stepState.decision_agreement || !this.stepState.terms_and_cond_agreement) {
            isValidStep = false;
        }

        if (this.continueButton) {
            this.continueButton.setState(isValidStep);
            this.stepState.continue_button = isValidStep ? "" : "disabled";
        }
    }

    stepSubmit () {
        console.log('stepState : ', this.stepState);
        this.loading = true;
        save({
            apexService : this.apexService, 
            stepState : this.stepState
        })
            .then( () => {
                console.log("save complete!");
                this.nextStep();
            })
            .catch ( (error) => {
                console.log("save error = ", error);
                this.loading = false;
            });
    }
}