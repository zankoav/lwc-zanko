import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepCartConfiguration extends BaseStep {
    

    numberOfCardsHandler(event){
        console.log(event.detail);
    }

    stepBack(){
        this.backStep();
    }

    stepSubmit(){
        console.log('stepSubmit');
    }

    tabChangeHandler(event){
        console.log(event.detail);
    }
}