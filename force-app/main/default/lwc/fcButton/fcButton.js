/** 
    <c-fc-button 
        variant="gray" 
        title="title" 
        disabled>
    </c-fc-button>
 */

import { LightningElement, api, track } from 'lwc';

const BASE_CLASS_NAME = "fc-button";
const DISABLED_CLASS_NAME = "fc-button_disabled";
const GRAY_CLASS_NAME = "fc-button_gray";
const DISABLED = "disabled";
const BASE_LABEL = "Button";

export default class FcButton extends LightningElement {

    @track className = BASE_CLASS_NAME;
    @api disabled;
    @api title = BASE_LABEL;
    @api variant;

    activate() {
        this.disabled = null;
        this.className = BASE_CLASS_NAME;
        if (this.variant === "gray") {
            this.className += ' ' + GRAY_CLASS_NAME;
        }
    }

    deactivate() {
        this.disabled = DISABLED;
        this.className = `${BASE_CLASS_NAME} ${DISABLED_CLASS_NAME}`;
        if (this.variant === "gray") {
            this.className += ' ' + GRAY_CLASS_NAME;
        }
    }

    @api setState(value) {
        if (value) {
            this.activate();
        } else {
            this.deactivate();
        }
    }

    connectedCallback() {
        this.className = this.disabled === DISABLED ? `${BASE_CLASS_NAME} ${DISABLED_CLASS_NAME}` : BASE_CLASS_NAME;
        if (this.variant === "gray") {
            this.className += ' ' + GRAY_CLASS_NAME;
        }
    }
}