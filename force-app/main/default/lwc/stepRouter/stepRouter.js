import { LightningElement, api } from 'lwc';

export default class StepRouter extends LightningElement {

    stepsElements;
    stepsOrders;

    @api currentStep;

    @api setStep(step) {
        if (step) {
            this.currentStep = step;
            const stepString = this.currentStep.toString();
            for (const item of this.stepsElements) {
                if (item.order === stepString) {
                    item.activate();
                } else {
                    item.deactivate();
                }
            }
        }
    }

    renderedCallback() {
        this.stepsElements = this.querySelectorAll('c-step');
        this.stepsOrders = [];

        for (const item of this.stepsElements) {
            this.stepsOrders.push(parseInt(item.order, 10));
        }

        this.stepsOrders.sort((a, b) => a - b);

        if (this.stepsOrders.length) {
            const currentStep = parseInt(this.currentStep, 10);
            let toStep;
            if (currentStep) {
                toStep = this.stepsOrders.find((item) => {
                    return item === currentStep;
                });
            } else {
                toStep = this.stepsOrders[0];
            }

            if (toStep) {
                this.setStep(toStep);
            }
        }

    }

    toStep(event) {
        const step = parseInt(event.detail, 10);
        const toStep = this.stepsOrders.find((item) => {
            return item === step;
        });
        if (toStep) {
            this.setStep(toStep);
        }
    }

    backStep(event) {
        const currentStep = parseInt(event.detail, 10);
        let prevStep = 0;
        for (let order of this.stepsOrders) {
            if (order === currentStep) {
                break;
            }
            prevStep = order;
        }

        if (prevStep) {
            this.setStep(prevStep);
        }
    }

    nextStep(event) {
        const currentStep = parseInt(event.detail, 10);
        const nextStep = this.stepsOrders.find((item) => {
            return item > currentStep;
        });

        if (nextStep) {
            this.setStep(nextStep);
        }
    }
}