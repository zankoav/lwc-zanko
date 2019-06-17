import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import apexStepSubmit from '@salesforce/apex/StepContactDetailsController.stepSubmit';
import getState from '@salesforce/apex/StaticResourceClass.getStaticData';

export default class StepContactDetails extends BaseStep {

    @api lang;
    @api stateId;

    @api stepContent;
    @api apexService;

    @track staticData;
    @track stateStep;
    submitButton;


    // @wire(getState, { stepContent: '$stepContent', apexService: '$apexService' })
    // wireState({ error, data }) {
    //     if (data) {
    //         this.staticData = data.resource;
    //         this.stateStep = {
    //             country: this.staticData.country,
    //             language: this.staticData.language,
    //             salutation: this.staticData.salutation.value,
    //             first_name: this.staticData.first_name.value,
    //             last_name: this.staticData.last_name.value,
    //             phone: this.staticData.phone.value,
    //             email: this.staticData.email.value,
    //             number_of_cards: this.staticData.number_of_cards.value,
    //             business_type: this.staticData.business_type.value,
    //             news_agreement: this.staticData.news_agreement.value,
    //             continue_button: this.staticData.continue_button.disabled,
    //         };
    //     }
    //     if (error) {
    //         console.log(error);
    //     }
    // }

    connectedCallback() {
        getState({ stepContent: this.stepContent, apexService: this.apexService })
            .then(result => {
                console.log(result);
                this.staticData = result;
                this.stateStep = {
                    country: this.staticData.country,
                    language: this.staticData.language,
                    salutation: this.staticData.salutation.value,
                    first_name: this.staticData.first_name.value,
                    last_name: this.staticData.last_name.value,
                    phone: this.staticData.phone.value,
                    email: this.staticData.email.value,
                    number_of_cards: this.staticData.number_of_cards.value,
                    business_type: this.staticData.business_type.value,
                    news_agreement: this.staticData.news_agreement.value,
                    continue_button: this.staticData.continue_button.disabled,
                };
                this.loading = false;
            }).catch(error => {
                console.log('Error:', error);
            });
    }

    renderedCallback() {
        this.submitButton = this.template.querySelector('c-fc-button');
        this.validateState();
    }

    sexChange(event) {
        this.stateStep.salutation = event.detail;
    }

    changeBusinesType(event) {
        this.stateStep.business_type = event.detail;
    }

    changeNewsAgreement(event) {
        this.stateStep.news_agreement = event.target.active;
        this.validateState();
    }

    firstNameHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.first_name = value;
        if (this.validateFirstName(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.validateState();
    }

    lastNameHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.last_name = value;
        if (this.validateLastName(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.validateState();
    }

    phoneHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.phone = value;
        if (this.validatePhone(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.validateState();
    }

    emailHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.email = value;
        if (this.validateEmailHandler(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.validateState();
    }

    numberOfCardsHandler(event) {
        this.stateStep.number_of_cards = event.detail;
    }

    stepSubmit() {
        this.loading = true;
        console.log("stateStep:", this.stateStep);
        apexStepSubmit({ state: this.stateStep, apexService: this.apexService })
            .then(() => {
                this.nextStep();
            })
            .catch(error => {
                console.log('stepSubmit Error:', error);
                this.loading = false;
            })
    }

    validateState() {
        if (!this.stateStep) {
            return;
        }

        let result = true;

        // first_name
        if (!this.validateFirstName(this.stateStep.first_name)) {
            result = false;
        }

        // last_name
        if (!this.validateLastName(this.stateStep.last_name)) {
            result = false;
        }

        // phone
        if (!this.validatePhone(this.stateStep.phone)) {
            result = false;
        }

        // email
        if (!this.validateEmailHandler(this.stateStep.email)) {
            result = false;
        }

        if (!this.stateStep.news_agreement) {
            result = false;
        }

        if (this.submitButton) {
            this.submitButton.setState(result);
            this.stateStep.continue_button = result ? '' : 'disabled';
        }
    }

    validateFirstName(value) {
        const length = value.length;
        const resource = this.staticData.first_name;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength && length >= resource.minLength);
    }

    validateLastName(value) {
        const length = value.length;
        const resource = this.staticData.last_name;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength && length >= resource.minLength);
    }

    validatePhone(value) {
        const length = value.length;
        const resource = this.staticData.phone;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength);
    }

    validateEmailHandler(value) {
        const length = value.length;
        const lowerValue = value.toLowerCase();
        const resource = this.staticData.email;
        let isRegValid = new RegExp(resource.validationRegex).test(lowerValue);
        return (isRegValid && length <= resource.maxLength);
    }
}