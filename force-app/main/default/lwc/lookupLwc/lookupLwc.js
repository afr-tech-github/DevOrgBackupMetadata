import lookUp from '@salesforce/apex/FMS_SortByCurrentSOController.lookUp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';

export default class LookupLwc extends LightningElement {

    @api valueId;
    @api fieldApiName;
    @api objName;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api filters = '';
    @api showLabel = false;
    @api uniqueKey;
    @api placeholder = 'Search';
    @api displayFields = 'Name';
    @api displayFormat;
    @api isChecked = false;
    @api isDisplay = false;
    objLabelName;

    /*Create Record Start*/
    @api createRecord;
    @track recordTypeOptions;
    @track createRecordOpen;
    @track recordTypeSelector;
    @track mainRecord;
    @track isLoaded = false;

    //stencil
    @track cols = [1, 2];
    @track opacs = ['opacity: 1', 'opacity: 0.9', 'opacity: 0.8', 'opacity: 0.7', 'opacity: 0.6', 'opacity: 0.5', 'opacity: 0.4', 'opacity: 0.3', 'opacity: 0.2', 'opacity: 0.1'];
    @track double = true;

    //For Stencil
    @track stencilClass = '';
    @track stencilReplacement = 'slds-hide';
    //css
    @track myPadding = 'slds-modal__content';
    /*Create Record End*/

    @track label;
    @track options; //lookup values
    @track isValue;
    @track blurTimeout;
    @track defaultValue;

    searchTerm;
    href;
    blurTimeout;

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    connectedCallback() {
        this.defaultValue = this.valueId;
        //console.log('defaultValue : ' + this.defaultValue);
        if (!this.displayFormat) {
            let splitFields = this.displayFields.split(',');
            this.displayFormat = splitFields[0];
        }
    }

    apply(event){
        let isChecked = this.isChecked;
        let key = this.uniqueKey;
        let fieldApiName = this.fieldApiName;
        let selectedId = '';
        if(this.href != '' || this.href != undefined || this.href != null){
            selectedId = this.href.replace('/','');
        }
        if(isChecked == '' || isChecked == undefined) isChecked = false;

        console.log('apply isChecked ' + this.isChecked);
        console.log('apply selectedId ' + this.href + ' - ' + selectedId);

        const evt = new CustomEvent('customapply', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail:{
                data: {key, selectedId, fieldApiName, isChecked}
            }
        });
        this.dispatchEvent(evt);
        
        console.log('finish apply ' + JSON.stringify(evt.detail.data));
        //selectItem(record)
        this.valueId = evt.detail.data.selectedId;
        this.defaultValue = this.valueId;
        /*this.options.forEach(option => {
            if (option.Id === this.valueId) {
                this.selectItem(option);
            }
        });*/

        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
    }

    cancel(event){

    }

    changeApply(event){
        if(!this.isChecked){
            this.isChecked = true;
        }
        else this.isChecked = false;

        let isChecked = this.isChecked;
        const evt = new CustomEvent('changeapply', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail:{
                data: {isChecked}
            }
        });
        this.dispatchEvent(evt);
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        console.log('changeApply ' + isChecked);
    }

    renderedCallback() {
        if (this.objName) {
            let temp = this.objName;
            if (temp.includes('__c')) {
                let newObjName = temp.replace(/__c/g, "");
                if (newObjName.includes('_')) {
                    let vNewObjName = newObjName.replace(/_/g, " ");
                    this.objLabelName = vNewObjName;
                } else {
                    this.objLabelName = newObjName;
                }

            } else {
                this.objLabelName = this.objName;
            }
        }
    }

    //Used for creating Record Start
    @wire(getObjectInfo, { objectApiName: '$objName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.error = undefined;

            let recordTypeInfos = Object.entries(data.recordTypeInfos);
            if (recordTypeInfos.length > 1) {
                let temp = [];
                recordTypeInfos.forEach(([key, value]) => {
                    if (value.available === true && value.master !== true) {
                        temp.push({ "label": value.name, "value": value.recordTypeId });
                    }
                });
                this.recordTypeOptions = temp;
            } else {
                this.recordTypeId = data.defaultRecordTypeId;
            }
        } else if (error) {
            this.error = error;
        }
    }
    //Used for creating Record End

    @wire(lookUp, { searchTerm: '$searchTerm', objectName: '$objName', filters: '$filters', fields: '$displayFields' })
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.options = [];
            data.forEach(item => {
                let option = { ...item };
                option.label = this.generateLabel(option);
                this.options.push(option);
            });
        } else if (error) {
            this.error = error;
        }
    }

    @wire(lookUp, { recordId: '$valueId', objectName: '$objName', fields: '$displayFields' })
    wiredDefault({ error, data }) {
        if (data) {
            if (this.valueId) {
                this.selectItem(data[0]);
                this.options = undefined;
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    inblur() {
        this.blurTimeout = setTimeout(() => { this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
    }

    onSelect(event) {
        let ele = event.currentTarget;
        let selectedId = ele.dataset.id;
        let key = this.uniqueKey;
        let fieldApiName = this.fieldApiName;
        let isDisplay = this.isDisplay;

        const evt = new CustomEvent('valueselect', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { selectedId, key, fieldApiName, isDisplay },
            }
        });

        this.dispatchEvent(evt);

        console.log('onSelect :' + JSON.stringify(evt));

        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }

        this.options.forEach(option => {
            if (option.Id === selectedId) {
                this.selectItem(option);
            }
        });
    }

    selectItem(record) {
        //show selection value on screen
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.label = this.generateLabel(record);
        this.href = '/' + record.Id;
        this.isValue = true;
        this.options = undefined;
    }

    generateLabel(record) {
        //console.log('record', record);
        let label = this.displayFormat;
        let splitFields = this.displayFields.split(',');
        splitFields.forEach(field => {
            field = field.trim();
            let value;

            //logic to handle relationhships in queries
            if (field.indexOf('.') > -1) {
                let splitRelations = field.split('.');
                splitRelations.forEach(item => {
                    value = (value ? value[item] : record[item]);
                });
            } else {
                value = record[field];
            }
            label = label.replace(field, value);
        });
        return label;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    handleRemovePill() {
        this.isValue = false;
        this.valueId = '';
        let selectedId = '';
        let fieldApiName = this.fieldApiName;
        let key = this.uniqueKey;
        let isDisplay = this.isDisplay;
        const evt = new CustomEvent('valueselect', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { selectedId, key, fieldApiName, isDisplay },
            }
        });
        this.dispatchEvent(evt);
        console.log('Event ' + JSON.stringify(evt));
    }

    createRecordFunc() {
        if (this.recordTypeOptions) {
            this.recordTypeSelector = true;
        } else {
            this.recordTypeSelector = false;
            this.mainRecord = true;
            //stencil before getting data
            this.stencilClass = '';
            this.stencilReplacement = 'slds-hide';
        }
        this.createRecordOpen = true;
    }

    handleRecTypeChange(event) {
        this.recordTypeId = event.target.value;
    }

    createRecordMain() {
        this.recordTypeSelector = false;
        this.mainRecord = true;
        //stencil before getting data
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
    }

    handleLoad(event) {
        let details = event.detail;

        if (details) {
            setTimeout(() => {
                this.stencilClass = 'slds-hide';
                this.stencilReplacement = '';
                this.myPadding = 'slds-p-around_medium slds-modal__content';
            }, 1000);
        }

    }

    handleSubmit() {
        this.template.querySelector('lightning-record-form').submit();
    }

    handleSuccess(event) {

        this.createRecordOpen = false;
        this.mainRecord = false;
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';

        let selectedId = event.detail.id;
        let key = this.uniqueKey;

        this.dispatchEvent(new CustomEvent('valueselect', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { selectedId, key, fieldApiName }
            }
        }));

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: `Record saved successfully with id: ${event.detail.id}`,
                variant: 'success',
            }),
        )
    }

    handleError() {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Error saving the record',
                variant: 'error',
            }),
        )
    }

    closeModal() {
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
        this.createRecordOpen = false;
        this.recordTypeSelector = false;
        this.mainRecord = false;
    }
}