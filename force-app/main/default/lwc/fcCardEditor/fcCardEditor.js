import { LightningElement, track, api } from 'lwc';

export default class FcCardEditor extends LightningElement {
    @api number;
    @api card;
    @api staicData;
    @track cardImageView;
    @track isEdit;
    @track isEditFirmen;
    @track companyName;
    @track cardType;
    @track needOdometerOption;

    connectedCallback() {
        if (this.number != null) {
            this.number = parseInt(this.number, 10) + 1;
        }
        this.labelCard = `${this.card.card_name} ${this.number}`;
        this.companyName = this.card.company_name;
        this.cardType = this.card.type_of_car;
        this.needOdometerOption = this.card.need_odometer_options;

        if (this.card.status === "done") {
            this.isEditFirmen = false;
            this.cardImageView = true;
            this.isEdit = false;
        }
    }

    renderedCallback() {
        if (!this.saveButton) {
            this.saveButton = this.template.querySelector('c-fc-button');
        }
    }

    edit() {
        this.isEdit = true;
    }

    saveHandler() {
        // send custom event

        const dataDetails = {
            card_id: this.card.card_id,
            company_name: this.companyName,
            type_of_car: this.cardType,
            need_odometer_options: this.needOdometerOption,
            status: 'done'
        };

        this.dispatchEvent(
            new CustomEvent('cardready', {
                detail: dataDetails
            })
        );

        this.isEditFirmen = false;
        this.cardImageView = true;
        this.isEdit = false;
     }

    editFirmen() {
        this.isEditFirmen = true;
    }

    firmenHandler(event) {
        const value = event.detail;
        const element = event.target;
        this.companyName = value;
        this.card.company_name = this.companyName;
        if (this.validateFirmenHandler()) {
            element.setSuccess();
            this.saveButton.setState(true);
        } else {
            element.showError();
            this.saveButton.setState(false);
        }
    }

    carTypeHandler(event) {
        this.cardType = event.detail;
    }

    odometerHandler(event) {
        this.needOdometerOption = event.detail;
    }

    validateFirmenHandler() {
        return this.companyName.length < 26 && this.companyName.length > 0;
    }
}