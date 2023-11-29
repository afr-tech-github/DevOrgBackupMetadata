import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import assets from '@salesforce/resourceUrl/CLOFOR';

export default class QrLandingV2 extends LightningElement {
    //navigation properties
    @track _page = 'wosSearch';
    //process properties
    @track _workerId;
    @track _locatorId;
    @track _wosType;
    @track _wosId;

    get _pageWosSearch() { return this._page === 'wosSearch'; }
    get _pageWosList() { return this._page === 'wosList'; }
    get _pageQrScan() { return this._page === 'qrScan'; }
    get _hasBtnBack() { return this._page !== 'wosSearch'; }

    connectedCallback() {
        loadStyle(this, assets + '/CLOFOR/assets/styles/qr-reader.css');
    }

    handleWosSearch(e) {
        this._workerId = e.detail.workerId;
        this._locatorId = e.detail.locatorId;
        this._wosType = e.detail.wosType;
        this._page = 'wosList';
    }

    handleWosSelect(e) {
        this._wosId = e.detail.value;
        this._page = 'qrScan';
    }

    handleGoHome() {
        this._page = 'wosSearch';
    }

    handleGoBack() {
        if (this._page === 'wosList') {
            this._page = 'wosSearch';
        } else if (this._page === 'qrScan') {
            this._page = 'wosList';
        }
    }
}