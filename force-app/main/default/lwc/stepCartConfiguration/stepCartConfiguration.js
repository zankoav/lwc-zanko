/* eslint-disable no-console */
import { track, api } from 'lwc';
import BaseStep from 'c/baseStep';
import getState from '@salesforce/apex/StepCardsConfigurationController.getStaticData';
import save from '@salesforce/apex/StepCardsConfigurationController.save';

export default class StepCartConfiguration extends BaseStep {

    stepName = "cards configuration";
    @api stepContent;
    @api apexService;
    @track stepState;
    @track staticData;

    @track loading = true;
    @track dynamic;


    tabs = [];
    iosBoxes = [];
    fSection = {
        monatliche: {
            label: "Monatliche Kartengebühr",
            value: "3.95",
            currency: "€",
            description1: "für",
            description2: "Karte",
            description3: "Karten"
        },
        nationale: {
            label: "Nationale Transaktionen",
            help: "Werden die Karten in Deutschland eingesetzt, können in bestimmten Fällen Zusatzgebühren pro Transaktion erhoben werden.",
            items: [
                {
                    label: "Kraftstoff (Shell Stationen)",
                    value: "0.00",
                    currency: "€"
                },
                {
                    label: "Kraftstoff (Shell Partner)",
                    value: "2.00",
                    currency: "€",
                    help: "Für mehr Flexibilität beim Einsatz der Shell Karte ist es möglich, auch an Shell Partnerstationen zu tanken. Für diese Tankvorgänge wird eine Zusatzgebühr erhoben."
                },
                {
                    label: "Shopartikel",
                    value: "1.00",
                    currency: "€",
                    help: "Alles, was mit einer Karte bezahlt wird und nicht mit Kraftstoffen zusammenhängt, gilt als Waren und Dienstleistungen."
                }	
            ]
        },
        internationale: {
            header: "Internationale Transaktionen",
            help: "Wenn Karten außerhalb von Deutschland verwendet werden, wird sowohl für Kraftstoff-Transaktionen als auch für Waren und Dienstleistungen eine Zusatzgebühr erhoben.",
            label: "Alle Arten",
            value: "1.00",
            currency: "%",
            remark: "Alle Preise exkl. MwSt."
        },
        weitere: {
            collapse_header: "Weitere mögliche Gebühren",
            header: "Werden nur in Sonderfällen erhoben",
            items: [
                {
                    label: "Rechnungsduplikat",
                    value: "5.00",
                    currency: "€",
                    help: "Gebühren für Rechnungsduplikate werden nur erhoben, wenn ein Duplikat von einer Papierrechnung erstellt und per Post an Sie gesandt werden soll."
                },
                {
                    label: "Zahlungsverzug",
                    value: "50.00",
                    currency: "€",
                    help: "Eine Gebühr für die verspätete Zahlung wird nur dann auf Ihrer nächsten Rechnung aufgeführt, wenn die aktuelle Rechnung gar nicht oder nach dem Fälligkeitsdatum bezahlt wurde."
                }	
            ]
        }
    };

    connectedCallback () {
        this.tabs = [];
        console.log("step : ", this.stepName);
        getState ({
            stepContent : this.stepContent,
            apexService : this.apexService,
            source : this.opportunitySource
        })
            .then( (result) => {
                console.log("static data loaded.", result);
                this.staticData = result;
                this.stepState = {
                    opportunity_id: this.staticData.opportunity_id,
                    account_id: this.staticData.account_id, 
                    number_of_cards: this.staticData.number_of_cards.value,
                    category : this.staticData.choose_type_section.selected_value,
                    pumpOutsideCountry : this.staticData.pumpOutsideCountry,
                    pumpAtPartners : this.staticData.pumpAtPartners,
                    country : this.staticData.country,
                    language : this.staticData.language,
                };
                this.setTabs();
                this.setIosBoxes();
                this.setDynemic();
                this.loading = false;
            })
            .catch( (error) => {
                console.log("static load error : ", error);
            });

    }

    setTabs () {
        let staticTabs = [
            this.staticData.choose_type_section.card_type_1,
            this.staticData.choose_type_section.card_type_2,
            this.staticData.choose_type_section.card_type_3,
        ];

        staticTabs.forEach(element => {
            let tab = {
                label: element.label,
                value: element.value,
                items: Object.values(element.description),
                active: this.staticData.category === element.value ? "active" : ""
            }
            this.tabs.push(tab);
        });
    }

    setIosBoxes () {
        let box1 = iterationCopy(this.staticData.choose_pump_type_section.items[0]);
        box1.selected_value = this.stepState.pumpOutsideCountry;
        let box2 = iterationCopy(this.staticData.choose_pump_type_section.items[1]);
        box2.selected_value = this.stepState.pumpAtPartners;
        this.iosBoxes = [
            box1, box2
        ];
        
    }

    

    setDynemic () {
        const number = parseInt(this.stepState.number_of_cards, 10);
        const price_one = parseFloat(this.fSection.monatliche.value, 10);
        this.dynamic = {
            str : number > 1 ? `für ${number} Karten` : 'für 1 Karte',
            cost : (number * price_one).toFixed(2)
        }
    }

    numberOfCardsHandler(event){
        let value = event.detail;
        this.stepState.number_of_cards = value;
        this.setDynemic();
    }

    tabChangeHandler(event){
        console.log(event.detail);
        this.stepState.category = event.detail;
    }

    pumpChangeHanler (event) {
        let title = event.target.title;
        let value = event.detail;
        if (title === 'Tanken im Ausland') {
            this.stepState.pumpOutsideCountry = value;
        }
        if (title === 'Tanken an Shell Partnerstationen') {
            this.stepState.pumpAtPartners = value;
        }
    }

    stepSubmit(){
        this.loading = true;
        console.log("step state = ", this.stepState);
        save({
            apexService : this.apexService, 
            stepState : this.stepState
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

function iterationCopy(src) {
    let target = {};
    for (let prop in src) {
        if (src.hasOwnProperty(prop)) {
            target[prop] = src[prop];
        }
    }
    return target;
}