import { LightningElement, api, track } from 'lwc';

const BLOCK_BASIC = 'fc-flag__block ';
const BLOCK_ACTIVE = 'fc-flag__red ';

export default class FcFlag extends LightningElement {
    @api title;
    @api description;
    @api active;
    @track blockClass;

    connectedCallback () {
        this.setBlockClass();
    }

    @api turnOn () {
        this.active = true;
        this.setBlockClass();
    }

    @api turnOff () {
        this.active = false;
        this.setBlockClass();
    }

    setBlockClass () {
        this.blockClass = this.active ? (BLOCK_BASIC + BLOCK_ACTIVE) : BLOCK_BASIC;
    }
}