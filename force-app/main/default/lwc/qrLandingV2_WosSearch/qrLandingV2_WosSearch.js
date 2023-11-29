/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { validationUtils } from 'c/utilities';

export default class QrLandingV2_WosSearch extends LightningElement {
    @api get workerId()     { return this._workerId }   set workerId(val)   { this._workerId = val }
    @api get locatorId()    { return this._locatorId }  set locatorId(val)  { this._locatorId = val }
    @api get wosType()      { return this._wosType }    set wosType(val)    { this._wosType = val || 'all' }

    @track _workerId;
    @track _locatorId;
    @track _wosType;
    _wosTypeOpts = [
        { label: 'All', value: 'all'},
        { label: 'Receiving', value: 'receiving'},
        { label: 'Value added service', value: 'vas'},
        { label: 'Put away', value: 'putaway'},
        { label: 'Picking', value: 'picking'},
        { label: 'Dispatch', value: 'dispatch'},
    ];

    handleInputChange(e) {
        this[e.target.dataset.name] = e.detail.value;
    }

    handleSearch() {
        if (!validationUtils.validateFields(this)) {
            return;
        }
        this.dispatchEvent(new CustomEvent('search', { detail: {
            workerId: this._workerId,
            locatorId: this._locatorId,
            wosType: this._wosType,
        }}));
    }
}