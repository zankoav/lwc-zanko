import { LightningElement, api, track } from 'lwc';

export default class LiverpoolTemplate extends LightningElement {

    @api sidebar = 'left';
    @track sidebarClassName = 'liverpool__sidebar';

    connectedCallback(){
        if(this.sidebar === 'right'){
            this.sidebarClassName = 'liverpool__sidebar liverpool__sidebar_right';
        }
    }
}