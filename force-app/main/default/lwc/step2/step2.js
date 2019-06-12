import { track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class Step2 extends BaseStep {

    @track ggf = null;
    @track button;
    @track items = [
        {
            label:'Item wef wef we 1',
            value: 'item_1'
        },
        {
            label:'Item 2',
            value: 'item_2'
        },
        {
            label:'Item wefwef  3',
            value: 'item_3'
        },
        {
            label:'Item wefwef 2',
            value: 'item_4'
        },
        {
            label:'Item 3',
            value: 'item_5'
        }
    ];

    renderedCallback() {
        this.button = this.template.querySelector('.submit-js');
    }

    changeButtons(event) {
        const value = event.detail;
        console.log('value', value);
    }
}