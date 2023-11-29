import { LightningElement, api, wire, track } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';

import BILLING_COUNTRY from '@salesforce/schema/Account.BillingCountry';

import BILLING_STATE from '@salesforce/schema/Account.BillingState';

import BILLING_CITY from '@salesforce/schema/Account.BillingCity';

import BILLING_STREET from '@salesforce/schema/Account.BillingStreet';

import BILLING_POSTALCODE from '@salesforce/schema/Account.BillingPostalCode';

export default class NSP_Location_Map extends LightningElement {

    @api recordId;

    @track mapMarkers;

    @wire(getRecord, {

        recordId: '$recordId',

        fields: [BILLING_COUNTRY, BILLING_STATE, BILLING_CITY, BILLING_STREET, BILLING_POSTALCODE]

    })

    fetchAddressDetails({data, error}){

        if(data){

            this.mapMarkers = [

                {

                    location: {

                        Country: data.fields.BillingCountry.value,

                        State: data.fields.BillingState.value,

                        City: data.fields.BillingCity.value,

                        Street: data.fields.BillingStreet.value,

                        PostalCode: data.fields.BillingPostalCode.value

                    }

                }

            ];
            console.log('error' + error);

        }else if(error){

            console.log('error' + error);

        }

    }

}