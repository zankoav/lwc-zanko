/* eslint-disable no-console */
import { api, track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepOfferSelection extends BaseStep {

    @api lang;
    @api stepContent;
    @api apexService;

    @track loading = true;
    @track staticData;
    @track stateStep;

    connectedCallback(){
        this.loading = false;   
        
    }

    stepBack(){
        this.backStep();
    }

    stepSubmit(){
        console.log('stepSubmit');
    }
}