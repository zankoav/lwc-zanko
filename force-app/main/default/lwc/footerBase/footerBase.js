import { LightningElement, api } from 'lwc';

export default class FooterBase extends LightningElement {

    @api company = "FLEETCOR";
    @api rightResived = "&copy;2019 All rights reserved.";
    @api cookieTitle = "Cookies Policy";
    @api cookieLink = "#";
    @api policyTitle = "Privacy Policy";
    @api policyLink = "#";
    
}