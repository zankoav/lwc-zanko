/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/stepTotalConsumptionController.getStaticData';
import save from '@salesforce/apex/stepTotalConsumptionController.save';

export default class StepTotalConsumption extends BaseStep {

    nameStep = "total consumption";
    @api stepContent;
    @api apexService;

    @track staticData;
    @track stateStep;
    @track loading = true;
    continueButton;

    connectedCallback () {
        console.log("step : ",this.nameStep);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then( (result) => {  
                this.staticData = result;
                this.stateStep = {
                    total_consumption : this.staticData.total_consumption.value,
                    continue_button : this.staticData.continue_button.disabled,
                    back_button : this.staticData.back_button.disabled,
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                }
                this.loading = false;
                console.log("static data = ", this.staticData);
            })
            .catch( error => {
                console.log(error);
            });
    }

    renderedCallback() {
        this.continueButton = this.template.querySelector('c-fc-button[data-button="continue"]');
        this.validateState();
    }

    //company_name
    totalConsumptionHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.total_consumption = value;
        if (this.totalConsumtionValidate(value)) {
            element.setSuccess();
        } else {
            const resource = this.staticData.total_consumption;
            element.errorText = value > 50000 ? resource.errorMessage2 : resource.errorMessage;
            element.showError();
        }
        this.validateState();
    }

    totalConsumtionValidate(value) {
        const length = value.length;
        const resource = this.staticData.total_consumption;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (
            isRegValid && 
            length <= resource.maxLength && 
            length >= resource.minLength && 
            value >= 75 && 
            value <= 50000
        );
    }

    validateState() {
        if (!this.stateStep) { return; }

        let result = this.totalConsumtionValidate(this.stateStep.total_consumption)

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