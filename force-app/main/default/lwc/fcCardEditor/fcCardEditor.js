import { LightningElement, track } from 'lwc';

export default class FcCardEditor extends LightningElement {
    @track cardImageView;
    @track isEdit;
    @track isEditFirmen;

    @track options = [
        {
            label: 'pkw',
            value: 'pkw'
        },
        {
            label: 'lkw',
            value: 'lkw'
        }
    ];

    edit() {
        this.isEdit = true;
    }

    save() {
        this.isEdit = false;
        this.isEditFirmen = false;
        this.cardImageView = true;
    }

    editFirmen() {
        this.isEditFirmen = true;
    }

    firmenHandler(event) {
        const value = event.detail;
        const element = event.target;
        if (this.validateFirmenHandler(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
    }

    validateFirmenHandler(value){
        return value.length < 26 && value.length > 0;
    }
}