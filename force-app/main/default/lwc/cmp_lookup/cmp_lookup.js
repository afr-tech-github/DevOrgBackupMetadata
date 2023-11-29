/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getRecentRecords from '@salesforce/apex/strike_lookupController.getRecentRecords'
import getRecords from '@salesforce/apex/strike_lookupController.getRecords'

export default class Cmp_lookup extends LightningElement {
    @api placeHolder;
    @api objectType;
    @api searchField;
    @api subtitleField;
    @api extraSearchFields;
    @api optionalFields;
    @api filter;
    @api label;
    @api ref;
    @api limit = "5";
    @api showRecentRecords = false;
    @api required = false;
    @api showError() { this._hasError = true; }
    @api focus() { setTimeout(() => { this.template.querySelector('input').focus() }, 0) }
    @api 
    get value() { return this._value; }
    set value(val) { 
        if (!val) {
            this._searchTerm = null;
            this._value = null;
            this._valueLabel = null;
            this._jsonStringSingle = null;
        }
        else if (this._value !== val) {
            this._value = val;
            if (!this._isPageLoad) {
                this.setJsonStringSingle();
            }
        }
    }
    @api get selectedRecord() { return this._selectedRecord; }
    @api 
    get searchTerm() { return this._searchTerm; }
    set searchTerm(val) { 
        //if component is being init, the methods may not be available yet
        setTimeout(() => {
            this.onChange({ target: { value: val }});
            this.focus();
        }, 0);
    }

    @track _hasFocus = false;
    @track _parentValue;
    @track _hasError = false;
    @track _value;
    @track _valueLabel;
    @track _isSearching = true;
    @track _isLoading = false;
    @track _isPageLoad = true;
    @track _searchTerm = '';
    _listRecent = [];
    _listResult = [];
    _jsonStringRecent;
    _jsonStringSingle;
    _jsonString;
    @track _iconColor;
    @track _iconSrc;
    
    
    @wire(getRecentRecords, { jsonString: '$_jsonStringRecent' })
    getRecent({data, error}) {
        if (error) { console.error(error); }
        if (data) {
            this._listRecent = JSON.parse(data).results.data;
        }
        this._isSearching = false;
    }

    @wire(getRecords, { jsonString: '$_jsonString' })
    getResult({data, error}) {
        if (error) { console.error(error); }
        if (data) {
            this._listResult = JSON.parse(data).results.data;
        }
        this._isSearching = false;
    }

    @wire(getRecords, { jsonString: '$_jsonStringSingle' })
    getSingle({data, error}) {
        if (error) { console.error(error); }
        if (data) {
            const response = JSON.parse(data);
            if (response.isSuccess) {
                let record = response.results.data[0];
                this._value = record.value;
                this._valueLabel = record.label;
                this._selectedRecord = record;
            }
        }
        this._isLoading = false;
    }
    
    @wire(getObjectInfo, { objectApiName: '$objectType' })
    _objectInfo({ data, error }) {
        if (error) { console.error(error); }
        if (data) {
            this._iconColor = 'background: #' + data.themeInfo.color;
            this._iconSrc = data.themeInfo.iconUrl
        }
    }

    get _showNoData() { 
        let records = this._listRecords;
        return !this._isSearching && records && records.length === 0;
    }
    get _showData() {
        let records = this._listRecords;
        return records && records.length > 0;
    }
    get _listRecords() { 
        if (this.showRecentRecords && this._searchTerm === '') {
            return this._listRecent;
        }
        return this._listResult;
    }
    get _containerCssClass() { return 'slds-combobox_container ' + (this._value ? 'slds-has-selection' : '')}
    get _wrapperCssClass() { return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ' +  (this._hasFocus ? ' slds-is-open' : '') + (this._hasError ? ' slds-has-error' : ''); }

    connectedCallback() {
        this._isPageLoad = false;
        this.setJsonStringRecent();
        if (this._value) {
            this.setJsonStringSingle();
        }
    }

    setJsonStringRecent() {
        this._isSearching = true;
        this._jsonStringRecent = JSON.stringify({ 
            "filter": this.filter,
            "optionalFields": this.optionalFields,
            ...this.searchSettings
        });
    }

    setJsonString() {
        this._isSearching = true;
        this._jsonString = JSON.stringify({ 
            "filter": this.filter,
            "searchTerm": this._searchTerm,
            "limit": this.limit,
            ...this.searchSettings
        });
    }

    setJsonStringSingle() {
        this._isLoading = true;
        this._jsonStringSingle = JSON.stringify({ 
            "filter": `Id = '${this._value}'`, 
            ...this.searchSettings 
        });
    }

    get searchSettings() {
        return {
            "object": this.objectType, 
            "searchField": this.searchField,
            "subtitleField": this.subtitleField,
            "extraSearchFields": this.extraSearchFields,
            "optionalFields": this.optionalFields
        };
    }

    onFocus() { this._hasFocus = true; }
    onBlur() { this._hasFocus = false; }
    onChange(e) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = e.target.value;
        if (searchKey === '') {
            this._searchTerm = searchKey;
            return;
        }
        this.delayTimeout = setTimeout(() => {
            this._searchTerm = searchKey;
            this.setJsonString();
        }, 300);
    }
    doSelect(e) {
        this._hasError = false;
        this._value = e.currentTarget.dataset.val;

        const selected = this._listRecords.find(x => x.value === this._value);

        this._selectedRecord = selected.record;
        this._valueLabel = selected.label;

        this.dispatchEvent(new CustomEvent('select', { detail: { ref: this.ref, value: e.currentTarget.dataset.val, record: this._selectedRecord }}));
    }
    doRemoveSelection() {
        this._jsonStringSingle = null;
        this._value = null;
        this._valueLabel = null;
        setTimeout(() => { this.template.querySelector('.txt-search').focus() }, 0);
        this.dispatchEvent(new CustomEvent('select', { detail: { ref: this.ref, value: null }}));
    }
    handleChange(event) {
        const value = event.target.value;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
      }

    @api reportValidity() {
        return !this.required || this._value;
    }
}