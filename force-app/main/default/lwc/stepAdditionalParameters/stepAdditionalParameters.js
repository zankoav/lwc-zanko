/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepAdditionalParametersController.getStaticData';
import save from '@salesforce/apex/StepAdditionalParametersController.save';

export default class StepAdditionalParameters extends BaseStep {

    nameStep = "additional parameters";
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    continueButton;
    searchButton;
    @track checkbox_value;


    connectedCallback () {
        console.log("step : ", this.nameStep);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.opportunitySource 
        })
            .then( (result) => {  
                this.staticData = result;
                this.checkbox_value = this.staticData.additional_services[0].checkbox_value === "true";
                this.loading = false;
                console.log("static data loaded.", this.staticData);
            })
            .catch( error => {
                console.log("static data error = ", error);
            });
    }

    checkBoxHandler(event){
        const value = event.target.active;
        this.checkbox_value = value;
    }

    stepSubmit(){
        this.loading = true;
        const stepState = {
            services: [
                {
                    checkbox_value: this.checkbox_value
                }
            ],
            opportunity_id: this.staticData.opportunity_id,
            account_id: this.staticData.account_id
        };
        console.log(stepState);
        save({
            apexService : this.apexService, 
            stepState : stepState
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