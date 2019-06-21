import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepAdditionalParameters extends BaseStep {

    @track loading = true;

    connectedCallback(){
        this.loading = false;
    }

    stepBack(){
        this.backStep();
    }

    stepSubmit(){
        console.log('stepSubmit');
    }

    checkBoxHandler(event){
        const value = event.target.active;
        console.log(value);
    }
    
}