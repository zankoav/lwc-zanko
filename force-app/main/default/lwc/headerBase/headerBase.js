import { LightningElement, api} from 'lwc';

export default class HeaderBase extends LightningElement {
    @api title = 'Title';
    @api subtitle = 'Subtitle';
}