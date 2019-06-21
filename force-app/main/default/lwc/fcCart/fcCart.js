import { LightningElement, api, track } from 'lwc';

const CART_CLASS_NAME = 'card';
const CART_VARIANT_BLUE = ' card_blue';
const CART_VARIANT_DARKBLUE = ' card_darkblue';
export default class FcCart extends LightningElement {

    @api variant;
    @track className = CART_CLASS_NAME;

    connectedCallback() {
        switch (this.variant) {
            case 'blue':
                this.className += CART_VARIANT_BLUE
                break;
            case 'darkblue':
                this.className += CART_VARIANT_DARKBLUE
                break;
            default: break;
        }
    }
}