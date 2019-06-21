import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepTechnicalParameters extends BaseStep {

    @track loading = true;
    @track cards = [1,2,3,4];

    connectedCallback() {
        this.loading = false;
    }

    stepBack() {
        this.backStep();
    }

    stepSubmit() {
        console.log('stepSubmit');
    }
}