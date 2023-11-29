/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from 'lwc';

export default class Cmp_modal extends LightningElement {
    @track title;
    @track subtitle;
    @track message;
    @track ps;
    @track mpModalShow = false;
    @track labelCancel = 'Cancel';
    @track labelConfirm = 'Confirm';
    @track modalType = 'confirm';
    @track showClose = true;
    @track variant = 'info';
    
    params;
    closeOnConfirm;//auto close modal on confirm, override this for callback that do validation/processing and may need user input before closing the modal
    confirmCallback;
    cancelCallback;

    get showCancel() { return this.modalType === 'confirm'; }
    get showTopScroll() { return this.hasScroll && this._scrollPosition > 0; }
    get showBottomScroll() { return this.hasScroll && this._scrollPosition < 100; }

    @track hasScroll = false;
    renderedCallback() {
        const element = this.template.querySelector('.modal-content');
        this.hasScroll = element && element.scrollHeight !== element.clientHeight;
    }
    @track _scrollPosition = 0;
    onScroll(e) {
        const winScroll = e.currentTarget.scrollTop;
        const height = e.currentTarget.scrollHeight - e.currentTarget.clientHeight;
        this._scrollPosition = (winScroll / height) * 100;
    }
    
    autoConfirm(event) {
        if (event.keyCode===13) {
            this.handleConfirm();
        }
    }
    handleConfirm() {
        if (this.confirmCallback) {
            this.confirmCallback(this.params);
        }
        if (this.closeOnConfirm) {
            this.mpModalShow = false;
        }
    }
    //on cancel, call callback or dispatch cancel event
    handleCancel() {
        this.mpModalShow = false;
        if (this.cancelCallback) {
            this.cancelCallback(this.params);
        }
    }

    handleClose() {
        if (this.showCancel) {
            this.handleCancel();
        }
        else {
            this.handleConfirm();
        }
    }

    @api
    show(config) {
        this.title = config.title;
        this.subtitle = config.subtitle;
        this.message = config.message;
        this.ps = config.ps;
        this.params = config.params;
        this.variant = config.variant || 'info';
        this.confirmCallback = config.onConfirm;
        this.cancelCallback = config.onCancel;
        this.labelConfirm = config.labelConfirm || 'Confirm';
        this.labelCancel = config.labelCancel || 'Cancel';
        this.modalType = config.modalType || 'confirm';
        this.mpModalShow = true;
        this.showClose = config.showClose === false ? false : true;
        this.closeOnConfirm = config.closeOnConfirm == null ? true : config.closeOnConfirm;
    }

    @api hide() { this.mpModalShow = false; }

    @api
    showConfirm(config) {
        config.modalType = 'confirm';
        this.show(config);
    }
    
    @api
    showAlert(config) {
        config.modalType = 'alert';
        this.show(config);
    }

    @api
    showMessage(config) {
        config.modalType = 'message';
        this.show(config);
    }
}