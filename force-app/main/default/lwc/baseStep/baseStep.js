import { LightningElement, api, track } from 'lwc';
import {cache} from 'c/cacheHelper';

export default class BaseStep extends LightningElement {

    @api order;
    nameStep = 'baseStep';
    opportunitySource;
    globalCache = cache;

    constructor(){
        super();
        this.opportunitySource = this.globalCache.opportunitySource;
    }

    nextStep() {
        this.stepComplate('nextstep');
    }

    backStep() {
        this.stepComplate('backstep');
    }

    stepComplate(navigationType) {
        this.dispatchEvent(
            new CustomEvent(navigationType, {
                detail: this.order,
                bubbles: true
            })
        );
    }

    hideSidebar(){
        this.dispatchEvent(
            new CustomEvent('sidebarhide', {
                detail: null,
                bubbles: true
            })
        );
    }

    showSidebar(){
        this.dispatchEvent(
            new CustomEvent('sidebarshow', {
                detail: null,
                bubbles: true
            })
        );
    }
}