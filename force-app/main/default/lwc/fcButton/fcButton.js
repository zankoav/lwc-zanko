/** 
    <c-fc-button 
        css-class="class name" 
        title="title" 
        disabled>
    </c-fc-button>
 */

import { LightningElement, api, track } from 'lwc';

const BASE_CLASS_NAME = "fc-button";
const DISABLED_CLASS_NAME = "fc-button_disabled";

export default class FcButton extends LightningElement {
    
    @track className = BASE_CLASS_NAME;
    @track _disabled;

    @api cssClass;
    @api title = 'Button';
    @api 
    set disabled(value){
        this._disabled = value;
        if(this._disabled){
            this.className += ` ${DISABLED_CLASS_NAME}`;
        }else{
            this.className = this.className.trim()
            .split(' ')
            .filter(function (item) {
                return ( item !== DISABLED_CLASS_NAME && item !== ' ');
            })
            .join(' ');
        }
    }
    get disabled(){
        return this._disabled;
    }

    connectedCallback() {
        if(this.cssClass){
            this.className += ` ${this.cssClass}`;
        }
    }
}