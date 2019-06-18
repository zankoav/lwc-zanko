import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import apexStepSubmit from '@salesforce/apex/StepCreditScoringController.stepSubmit';
import getState from '@salesforce/apex/StaticResourceClass.getStaticData';

export default class StepCreditScoring extends BaseStep {
    @api lang;
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    @track stateStep;

    submitButton;

    @track paymantMethods = [
        {
            label: 'Lastschrift',
            value: 'lastschrift'
        }, {
            label: 'Überweisung',
            value: 'uberweisung'
        }
    ];

    @track payBills = [
        {
            label: 'Wöchentlich',
            value: 'wöchentlich'
        }, {
            label: 'Vierzehntägig',
            value: 'vierzehntägig'
        }
    ];

    connectedCallback() {
        // getState({ stepContent: this.stepContent, apexService: this.apexService })
        //     .then(result => {
        //         console.log(result);
        //         this.staticData = result;
        //         this.stateStep = {

        //         };
        //         this.loading = false;
        //     }).catch(error => {
        //         console.log('Error:', error);
        //     });

        this.stateStep = {

        };
        this.loading = false;
    }

    renderedCallback() {
        this.submitButton = this.template.querySelector('c-fc-button');
    }

    changePaymentMethod(event) {
        const value = event.detail;
        console.log('paymentMethod', value);
    }

    changePayBills(event) {
        const value = event.detail;
        console.log('changePayBills', value);
    }

    stepBack(){
        console.log('stepBack');
        this.backStep();
    }

    stepSubmit(){
        console.log('stepSubmit');
    }
}