import { LightningElement, api } from 'lwc';

export default class BaseStep extends LightningElement {
    
    @api order;

    nextStep(){
        this.stepComplate('nextstep');
    }

    backStep(){
        this.stepComplate('backstep');
    }

    stepComplate(navigationType){
        this.dispatchEvent(
            new CustomEvent(navigationType, {
                detail: this.order,
                bubbles: true
            })
        );
    }
}