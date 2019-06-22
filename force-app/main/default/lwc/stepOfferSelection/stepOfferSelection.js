/* eslint-disable no-console */
import { api, track } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepOfferSelectionController.getStaticData';
import submitState from '@salesforce/apex/StepOfferSelectionController.stepSubmit';
export default class StepOfferSelection extends BaseStep {

    @api lang;
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    @track stateStep;
    
    flagView;
    buttonSubmit;

    @track buttonVariant;
    @track offer1FlagActive;
    

    connectedCallback() {
        getState({ stepContent: this.stepContent, apexService: this.apexService, source: this.opportunitySource })
            .then(result => {
                this.staticData = result;
                console.log(this.staticData);
                this.stateStep = {
                    selected_offer: this.staticData.selected_offer,
                    account_id: this.staticData.account_id,
                    opportunity_id: this.staticData.opportunity_id,
                    country: this.staticData.country,
                    language: this.staticData.language
                };
                this.offer1FlagActive = this.staticData.selected_offer;
                this.buttonVariant = this.offer1FlagActive ? "gray" : null;
                this.loading = false;
                console.log("stateStep data StepOfferSelection = ", this.stateStep);
            }).catch(error => {
                console.log('Error:', error);
            });
    }

    renderedCallback() {
        this.flagView = this.template.querySelector('c-fc-flag');
        this.buttonSubmit = this.template.querySelector('.submit');
        if(this.stateStep && this.buttonSubmit){
            this.buttonSubmit.setState(this.stateStep.selected_offer);
        }
    }

    offer1Handler(event) {
        console.log('offer1Handler');
        const buttonElement = event.target;
        this.buttonVariant = this.buttonVariant ? null : "gray";
        buttonElement.setVariant(this.buttonVariant);
        if(this.buttonVariant){
            this.flagView.turnOn();
            this.stateStep.selected_offer = this.staticData.non_home_offers[0].product_name;
        }else{
            this.stateStep.selected_offer = null;
            this.flagView.turnOff();
        }
        this.buttonSubmit.setState(this.stateStep.selected_offer);
    }

    stepSubmit() {
        this.loading = true;
        console.log("stateStep = ", this.stateStep);
        submitState({
            state:this.stateStep, 
            apexService:this.apexService
        })
        .then(() => {
            this.nextStep();
            this.loading = false;
        })
        .catch(error => {
            console.log(error);
            this.loading = false;
        });
    }
}