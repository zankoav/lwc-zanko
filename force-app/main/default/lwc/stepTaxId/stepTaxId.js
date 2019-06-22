/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/stepTaxIdController.getStaticData';
import save from '@salesforce/apex/stepTaxIdController.save';

export default class StepTaxId extends BaseStep {

    nameStep = "taxId";
    @api stepContent;
    @api apexService;

    @track staticData;
    @track stateStep;
    @track loading = true;
    continueButton;

    connectedCallback () {
        console.log("step : ", this.nameStep);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then( (result) => {  
                this.staticData = result;
                this.stateStep = {
                    tax_id : this.staticData.tax_id.value,
                    continue_button : this.staticData.continue_button.disabled,
                    back_button : this.staticData.back_button.disabled,
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                }
                this.loading = false;
                console.log("static data = ", this.staticData);
            })
            .catch( error => {
                console.log("static load error : ",error);
            });
    }

    renderedCallback() {
        this.continueButton = this.template.querySelector('c-fc-button[data-button="continue"]');
        this.validateState();
    }

    //company_name
    taxIdHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.tax_id = value;
        if (this.taxIdValidate(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.validateState();
    }

    taxIdValidate(value) {
        const length = value.length;
        const resource = this.staticData.tax_id;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength);
    }

    validateState() {
        if (!this.stateStep) { return; }

        let result = this.taxIdValidate(this.stateStep.tax_id)

        if (this.continueButton) {
            this.continueButton.setState(result);
            this.stateStep.continue_button = result ? "" : "disabled";
        }
    }

    stepSubmit() {
        this.loading = true;
        save({
            apexService : this.apexService, 
            stateStep : this.stateStep
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