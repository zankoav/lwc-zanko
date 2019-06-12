/** 
    <c-fc-radio-buttons
        current="value_1"
        options={items}
        onchange={changeButtons}>
    </c-fc-radio-buttons>

    items = [
        {
            label:'Item 1',
            value: 'item_1'
        },
        {
            label:'Item 2',
            value: 'item_2'
        },
        ...
    ];
 */
import { LightningElement, api, track } from 'lwc';

const BASE_ITEM_CLASS_NAME = 'fc-radio-buttons__item';
const ACTIVE_ITEM_CLASS_NAME = 'fc-radio-buttons__item_active';

export default class FcRadioButtons extends LightningElement {

    @api current;
    @api options;

    @track items;

    connectedCallback() {
        const items = [];
        if (this.options && this.options.length) {
            this.options.forEach((item, index) => {
                let className = item.value === this.current ?
                    `${BASE_ITEM_CLASS_NAME} ${ACTIVE_ITEM_CLASS_NAME}` :
                    BASE_ITEM_CLASS_NAME;
                if (!this.current && index === 0) {
                    className = `${BASE_ITEM_CLASS_NAME} ${ACTIVE_ITEM_CLASS_NAME}`;
                }
                items.push({
                    label: item.label,
                    value: item.value,
                    className: className
                });
            });
        }

        this.items = items;
    }

    chooseOption(event) {
        this.template.querySelectorAll('li').forEach((element, index) => {
            element.className = BASE_ITEM_CLASS_NAME;

            if(event.currentTarget === element && this.current !== this.options[index].value){
                element.className += ` ${ACTIVE_ITEM_CLASS_NAME}`;
                this.current = this.options[index].value;
                this.dispatchEvent(
                    new CustomEvent('change', { detail: this.current })
                );
            }else if (event.currentTarget === element){
                element.className += ` ${ACTIVE_ITEM_CLASS_NAME}`;
            }
        });
    }
}