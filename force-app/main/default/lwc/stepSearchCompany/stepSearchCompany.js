/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepSearchCompanyController.getStaticData';
import saveCompany from '@salesforce/apex/StepSearchCompanyController.saveCompany';
import searchCompanies from '@salesforce/apex/StepSearchCompanyController.searchCompanies';
import save from '@salesforce/apex/StepSearchCompanyController.save';

export default class StepSearchCompany extends BaseStep {

    nameStep = "searchCompany";
    @api source = "hzAijhWTmfwWZOe6zK0zSXE%2BQ62FzKkm/IOf1N%2Bwa7tKfnnxPNj1mxWf6%2BjbT6T4";
    @api stepContent;
    @api apexService;

    @track staticData;
    @track stateStep;
    continueButton;
    searchButton;

    selectedCompany;
    @track companies;

    connectedCallback () {
        document.cookie.split(";").forEach(next => {
            console.log(next);
            if (next.split("=")[0].trim().toLowerCase() === "source") {
                this.source = next.split("=")[1];
            }  
        });
        console.log("source = ",this.source);
        getState({ 
            stepContent: this.stepContent, 
            apexService: this.apexService, 
            source : this.source 
        })
            .then( (result) => {  
                console.log("static data loaded.");
                this.staticData = result;
                this.stateStep = {
                    company_name: this.staticData.company_name.value,
                    city: this.staticData.city.value,
                    search_button: this.staticData.search_button.disabled,
                    back_button: this.staticData.back_button.disabled,
                    continue_button: this.staticData.continue_button.disabled,
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id,
                    selected_company_id: ''
                }
                this.loading = false;
            })
            .catch( error => {
                console.log("static data error = ", error);
            });
    }

    renderedCallback() {
        this.continueButton = this.template.querySelector('c-fc-button[data-button="continue"]');
        this.searchButton = this.template.querySelector('c-fc-button[data-button="search"]');
        this.validateState();
    }

    //company_name
    companyNameHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.company_name = value;
        if (this.companyNameValidate(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.clearCompanies();
        this.validateState();
    }

    companyNameValidate(value) {
        const length = value.length;
        const resource = this.staticData.company_name;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength);
    }

    //city
    cityHandler(event) {
        const element = event.target;
        const value = event.detail;
        this.stateStep.city = value;
        if (this.cityValidate(value)) {
            element.setSuccess();
        } else {
            element.showError();
        }
        this.clearCompanies();
        this.validateState();
    }

    cityValidate(value) {
        const length = value.length;
        const resource = this.staticData.city;
        let isRegValid = new RegExp(resource.validationRegex).test(value);
        return (isRegValid && length <= resource.maxLength);
    }

    //select companies
    selectCompanies () {
        this.loading = true;

        saveCompany({
            stepState : this.stateStep, 
            stepContent : this.stepContent, 
            apexService : this.apexService
        })
            .then( () => {
                console.log("Company saved!");
                searchCompanies({
                    stepState : this.stateStep, 
                    apexService : this.apexService
                })
                    .then( (result) => {
                        this.companies = result;
                        this.loading = false;
                    })
            })
            .catch( (error) => {
                console.log("saveCompany error = " + error);
                this.loading = false;
            });
        
    }

    companySelectionHandler (event) {
        if (this.selectedCompany && this.selectedCompany !== event.target.dataset.label) {
            let elem = this.template.querySelector(`div[data-label="${this.selectedCompany}"]`);
            elem.classList.remove('selected');
        }
        this.selectedCompany = event.target.dataset.label;
        let elem = this.template.querySelector(`div[data-label="${this.selectedCompany}"]`);
        elem.classList.add('selected');

        if (this.continueButton) {
            this.continueButton.setState(this.selectedCompany);
            this.stateStep.continue_button = this.selectedCompany ? "" : "disabled";
        }
    }

    clearCompanies () {
        this.companies = undefined;
        this.selectedCompany = undefined;
    }

    validateState() {
        if (!this.stateStep) { return; }

        let result = true;
        // company_name
        if (!this.companyNameValidate(this.stateStep.company_name)) {
            result = false;
        }
        // city
        if (!this.cityValidate(this.stateStep.city)) {
            result = false;
        }

        if (this.searchButton && !this.companies) {
            this.searchButton.setState(result);
            this.stateStep.search_button = result ? "" : "disabled";
        }

        if (this.companies && !this.selectedCompany) {
            this.searchButton.setState();
            this.stateStep.search_button = "disabled";
        }

        if (this.continueButton && !this.companies) {
            this.continueButton.setState();
            this.stateStep.continue_button = "disabled";
        }
    }

    backHandle () {
        this.backStep();
    }

    stepSubmit() {
        this.loading = true;
        this.stateStep.selected_company_id = this.selectedCompany;
        save({
            stepContent : this.stepContent, 
            apexService : this.apexService, 
            data : this.stateStep
        })
            .then( () => {
                console.log("save complete!");
                this.nextStep();
            })
            .catch ( (error) => {
                console.log("save error = ", error);
                this.loading = false;
            });
    }

   
}