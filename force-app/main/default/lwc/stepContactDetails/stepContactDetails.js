import {track } from 'lwc';
import BaseStep from 'c/baseStep';

export default class StepContactDetails extends BaseStep {

	@track sexOptions = [
        {
            label:'Herr',
            value: 'herr'
        },
        {
            label:'Frau',
            value: 'frau'
        }
	];

	@track businesTypesOptions = [
        {
            label:'Firma',
            value: 'firma'
        },
        {
            label:'Einzelfirma',
            value: 'einzelfirma'
		},
        {
            label:'Privatperson',
            value: 'privatperson'
		}
	];
	
	renderedCallback() {
		setTimeout(()=>{
			this.loading = false;
		}, 3000);
	}
}