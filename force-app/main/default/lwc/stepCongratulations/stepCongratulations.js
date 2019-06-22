import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepCongratulationsController.getStaticData';

export default class StepCongratulations extends BaseStep {
    
    @track staticData;
    @track loading = true;
    @api stepContent;
    @api apexService;

    connectedCallback(){
        getState({ stepContent: this.stepContent, apexService: this.apexService, source: this.opportunitySource })
            .then(result => {
                this.staticData = result;
                this.hideSidebar();
                this.loading = false;
            }).catch(error => {
                console.log('Error:', error);
            });
    }
}