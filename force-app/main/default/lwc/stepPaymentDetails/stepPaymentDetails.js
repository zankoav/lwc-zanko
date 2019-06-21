import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepPaymentDetails extends BaseStep {
    @track loading = true;

    connectedCallback() {
        this.loading = false;
    }

    stepBack(){
        this.backStep();
    }

    stepSubmit(){
        console.log('stepSubmit');
    }

    nameHandler(){
        console.log('nameHandler');
    }

    ibanHandler(){
        console.log('ibanHandler');
    }

    changeVersichere(){
        console.log('changeVersichere');
    }

    changeMit(){
        console.log('changeMit');
    }

    changeDocument(){
        console.log('changeDocument');
    }
}