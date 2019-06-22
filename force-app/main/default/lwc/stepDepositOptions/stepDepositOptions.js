/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepDepositOptionsController.getStaticData';
import save from '@salesforce/apex/StepDepositOptionsController.save';

export default class StepDepositOptions extends BaseStep {

    nameStep = "deposit options";
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    stepState;
    continueButton;
    methods;

    connectedCallback () {
        console.log("step : ", this.nameStep);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then( (result) => {  
                console.log("static data loaded.", result);
                this.staticData = result;
                this.stepState = {
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                    contact_id: this.staticData.contact_id,
                    selected_method: this.staticData.select_block.selected_method,
                    deposit_agreement: this.staticData.deposit_agreement.value,
                    back_button: this.staticData.back_button.disabled,
                    continue_button: this.staticData.continue_button.disabled,
                };
                console.log("stepState = ", this.stepState);
                this.loading = false;
            })
            .catch( error => {
                console.log("static data error = ", error);
            });
    }

    renderedCallback () {
        if (!this.methods || !this.methods.length) {
            this.methods = this.template.querySelectorAll('c-fc-visa-card');
            this.activateSelectedMethod();
        }
        if (!this.continueButton) {
            this.continueButton = this.template.querySelector('.js-submit');
        }
    }

    changeMethodHandler (event) {
        this.stepState.selected_method = event.target.name;
        this.activateSelectedMethod();
    }

    activateSelectedMethod () {
        this.methods.forEach(method => {
            if (method.name === this.stepState.selected_method) {
                method.changeState("active");
            } else {
                method.changeState(null);
            }
        });
    }

    stepValidator () {
        if (!this.stepState) {
            return;
        }

        console.log(this.stepState.deposit_agreement);
        console.log(this.stepState.selected_method);
        let isValidStep = this.stepState.deposit_agreement && this.stepState.selected_method;

        console.log(this.continueButton);
        if (this.continueButton) {
            this.continueButton.setState(isValidStep);
            this.stepState.continue_button = isValidStep ? "" : "disabled";
        }
    }

    changeZahlung (event) {
        this.stepState.deposit_agreement = event.detail;
        this.stepValidator();
    }

    stepSubmit() {
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