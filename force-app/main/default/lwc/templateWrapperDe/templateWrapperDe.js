import { LightningElement, api } from 'lwc';
import {cache} from 'c/cacheHelper';

export default class TemplateWrapper extends LightningElement {
    @api step;
    @api source;
    lang = "DE";
    
    connectedCallback(){
        cache.opportunitySource = this.source;
    }
}