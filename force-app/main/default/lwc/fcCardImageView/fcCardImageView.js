import { LightningElement, api } from 'lwc';

export default class FcCardImageView extends LightningElement {
    @api title
    @api number;
    @api labelCard;
    @api labelNumber;
    @api counter;
}