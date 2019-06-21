import { api } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepCongratulations extends BaseStep {
    
    connectedCallback(){
        this.hideSidebar();
    }
}