/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepTechnicalParametersController.getStaticData';
import submitState from '@salesforce/apex/StepTechnicalParametersController.stepSubmit';
export default class StepTechnicalParameters extends BaseStep {

    @track loading = true;
    @track staticData;
    @track submitButtonStatus;

    @api stepContent;
    @api apexService;

    stateStep;

    connectedCallback() {
        getState({ stepContent: this.stepContent, apexService: this.apexService, source: this.opportunitySource })
            .then(result => {
                this.staticData = result;
                this.stateStep = iterationCopy(this.staticData);
                this.stateStep.cards = this.staticData.cards.map(item => {
                    return iterationCopy(item);
                });
                this.cards = this.staticData.cards;
                this.loading = false;
                this.submitButtonStatus = this.stateStep.cards.find(item => (item.status !== "done")) ? "disabled" : null;
                console.log("static data StepTechnicalParameters = ", this.staticData);
            }).catch(error => {
                console.log('Error:', error);
            });

    }

    renderedCallback() {
        if (!this.dataSubmit) {
            this.dataSubmit = this.template.querySelector('.js-button-submit');
        }
    }

    stepSubmit() {
        
        delete this.stateStep["back_button"];
        delete this.stateStep["car_type"];
        delete this.stateStep["continue_button"];
        delete this.stateStep["save_card"];

        console.log(this.stateStep);
        this.loading = true;
        submitState({ state: this.stateStep, apexService: this.apexService })
            .then(() => {
                this.nextStep();
                console.log("step complate");
            })
            .catch(error => {
                console.log("error stepSubmit", error);
                this.loading = false;
            })
    }

    validateButtonSubmit() {
        const card = this.stateStep.cards.find(item => (item.status !== "done"));
        if (this.dataSubmit) {
            this.dataSubmit.setState(!card);
        }
    }

    cardReadyHandler(event) {
        const cardModel = event.detail;
        this.stateStep.cards.forEach(element => {
            if (element.card_id === cardModel.card_id) {
                element.company_name = cardModel.company_name;
                element.type_of_car = cardModel.type_of_car;
                element.status = cardModel.status;
                element.need_odometer_options = cardModel.need_odometer_options;
            }
        });
        this.validateButtonSubmit();
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