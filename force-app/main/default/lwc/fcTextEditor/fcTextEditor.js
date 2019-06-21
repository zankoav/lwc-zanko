import { LightningElement, api } from 'lwc';

export default class FcTextEditor extends LightningElement {
    @api htmlText;

    renderedCallback(){
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        this.template.querySelector('.text-editor').innerHTML = this.htmlText;
    }
}