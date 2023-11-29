/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import startTask from '@salesforce/apex/WMS_QrService.startTask';
import processCargoV2 from '@salesforce/apex/WMS_QrService.processCargoV2';
import finalizeTask from '@salesforce/apex/WMS_QrService.finalizeTask';

export default class QrLandingV2_QrScan extends LightningElement {
    handleGoBack() {
        this.dispatchEvent(new CustomEvent('back', { detail: { value: 'qrScan' }}));
    }

    @api wosId;
    @api workerId;
    @api locatorId;

    @track _isLoading = true;
    @track _locatorPutAwayId;
    @track _wos = {};

    @track _productId;
    @track _cargoId;

    get _showSubmit() { return this._productId && this._cargoId }

    connectedCallback() {
        startTask({ wosId: this.wosId })
            .then(data => { this._wos = data; this._isLoading = false; })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ message: ex.body.message, variant: 'error' })));
    }

    handleInputChange(e) {
        this[e.target.dataset.name] = e.detail.value;
        if (e.target.dataset.name === '_productId' && e.detail.value) {
            this.template.querySelector('c-qr-landing-v2_-scan-cargoes').focus();
        }
        if (e.target.dataset.name === '_cargoId' && e.detail.value) {
            if (!this._productId) {
                this._productId = e.detail.productId;
            }
            //TODO get cargo info
        }
    }

    handleProcessCargo() {
        const cmp = this.template.querySelector('c-qr-landing-v2_-cargo-fields');
        if (!cmp.reportValidity()) {
            return;
        }

        this._isLoading = true;
        processCargoV2({ cargo: cmp.cargo, wosLineItem: cmp.wosLine })
            .then(() => { 
                this.dispatchEvent(new ShowToastEvent({ message: 'Cargo processed.', variant: 'success', mode: 'pester' }));
                this._isLoading = false;
                this._productId = null;
                this._cargoId = null;

                this.template.querySelector('c-qr-landing-v2_-scan-cargoes').connectedCallback()
                this.connectedCallback();
            })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ title: ex.body.message, message: ex.body.stackTrace, variant: 'error', mode: 'sticky' })));
    }

    handleFinalize() {
        this._isLoading = true;
        finalizeTask({ recordId: this.wosId })
            .then(() => { 
                this._isLoading = false;
                this.dispatchEvent(new ShowToastEvent({ message: `${this._wos.Name} finalized.`, variant: 'success', mode: 'pester' }));
                this.dispatchEvent(new CustomEvent('back', { detail: { value: 'qrScan' }}));
            })
            .catch(ex => this.dispatchEvent(new ShowToastEvent({ title: ex.body.message, message: ex.body.stackTrace, variant: 'error', mode: 'sticky' })));
    }
}