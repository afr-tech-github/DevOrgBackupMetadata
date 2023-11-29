/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';
import { searchUtils } from 'c/utilities';

export default class Cmp_autocomplete extends LightningElement {
    @api 
    get records() { return this._listAllRecords; }
    set records(val) { 
        this._listAllRecords = this._listRecords = val; 
        //remove selected value if not exists in the new record list
        if (this._selectedValue && !this._listAllRecords.some(x => x.value === this._selectedValue)) {
            this.doRemoveSelection();
        }
        if (this.autoSearch) {
            this._searchTerm = null;
        }
    }
    @api messageWhenNotFound = 'No result found';
    @api enableCreate = false;
    @api labelCreate = 'Create new record';
    @api autoSearch = false;
    @api placeHolder;
    @api label;
    @api required = false;
    @api showError() { this._hasError = true; }
    @api focus() { setTimeout(() => { this.template.querySelector('input').focus() }, 0) }
    @api 
    get value() { return this._selectedValue; }
    set value(val) { 
        this._searchTerm = null;
        if (this._listAllRecords.some(x => x.value === val)) {
            this._selectedValue = val;
        } else {
            this._selectedValue = null;
        }
    }

    @track _hasFocus = false;
    @track _hasError = false;
    @track _selectedValue;
    @track _searchTerm = '';
    @track _listAllRecords = [];
    @track _listRecords = [];

    get _selectedLabel() { return this._listAllRecords.find(x => x.value === this._selectedValue).label; }
    get _showNoData() { return this._listRecords.length === 0; }
    get _containerCssClass() { return 'slds-combobox_container ' + (this._selectedValue ? 'slds-has-selection' : '')}
    get _wrapperCssClass() { return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ' +  (this._hasFocus ? ' slds-is-open' : '') + (this._hasError ? ' slds-has-error' : ''); }

    connectedCallback() { }

    onFocus() { this._hasFocus = true; }
    onBlur() { this._hasFocus = false; }

    onChange(e) {
        window.clearTimeout(this.delayTimeout);
        this._searchTerm = e.target.value;
        if (!this._searchTerm || this._searchTerm  === '') {
            this._listRecords = this._listAllRecords;
            return;
        }
        this.delayTimeout = setTimeout(() => { 
            if (this.autoSearch) {
                this._listRecords = searchUtils.search(this._listAllRecords, this._searchTerm);
            } else {
                this.dispatchEvent(new CustomEvent('search', { detail: { value: this._searchTerm }}));
            }
        }, 300);
    }

    doSelect(e) {
        this._hasError = false;
        this._selectedValue = e.currentTarget.dataset.val;
        this.dispatchEvent(new CustomEvent('change', { detail: { value: this._selectedValue }}));
    }

    doRemoveSelection() {
        this._selectedValue = null;
        setTimeout(() => { this.template.querySelector('.txt-search').focus() }, 0);
        this.dispatchEvent(new CustomEvent('change', { detail: { value: null }}));
    }

    doCreate() {
        this.dispatchEvent(new CustomEvent('addnew', { detail: { value: this._searchTerm }}));
    }

    @api reportValidity() {
        const valid = !this.required || this._selectedValue;
        if (!valid) {
            this._hasError = true;
        }
        return valid;
    }
}