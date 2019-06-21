import { LightningElement, api, track } from 'lwc';

const CLASS_NAME_CONTENT = 'line__title';
const CLASS_NAME_CONTENT_SMALL = 'line__title_small';
const SMALL = 'small';

export default class FcPriceLine extends LightningElement {
    @api title;
    @api helpText;
    @api sublabel;
    @api price;
    @api currency;
    @api variant;
    @track className;

    connectedCallback() {
        this.className = this.variant === SMALL ? `${CLASS_NAME_CONTENT} ${CLASS_NAME_CONTENT_SMALL}` : CLASS_NAME_CONTENT;
    }

}