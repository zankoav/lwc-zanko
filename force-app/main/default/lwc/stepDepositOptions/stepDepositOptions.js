import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepDepositOptions extends BaseStep {

    @track loading = true;

    connectedCallback() {
        this.loading = false;
    }

    stepBack() {
        this.backStep();
    }

    stepSubmit() {
        console.log('stepSubmit');
    }

    changeZahlung(){
        console.log('changeZahlung');
    }
}