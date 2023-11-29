import { LightningElement,api, track, wire } from 'lwc';
import findCargos from '@salesforce/apex/CargosPickingController.findCargos';
const columns = [
    { label: 'Product Name', fieldName: 'Product__r.Name' },
    { label: 'Inbound Date', fieldName: 'InboundDate__c', type: 'date' },
    { label: 'Expired Date', fieldName: 'ExpiredDate__c', type: 'date' },
    { label: 'Cargo Name', fieldName: 'Name', type: 'text' },
];
export default class CargosPickingCmp extends LightningElement {
    @api recordId;
    @track data = [];
    @track columns = columns;
    fields = ["ProductID__c"];
    @track searchKey = '';

    @wire(findCargos, { searchKey: '$searchKey' })
    contacts;
    connectedCallback() {
        // initialize component
    }
}