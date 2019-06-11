import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class Step2 extends BaseStep {

    @track ggf = null;
    @track button;

    renderedCallback() {
        this.button = this.template.querySelector('.submit-js');
    }

    gg() {
        console.log('button click');
        if (this.button.disabled) {
            this.button.disabled = null;
        } else {
            this.button.disabled = "disabled";
        }

        setTimeout(() => {
            console.log('clear');
            this.button.disabled = null;
        }, 3000);

    }
}