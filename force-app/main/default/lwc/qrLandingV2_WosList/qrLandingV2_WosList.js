/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getTasks from '@salesforce/apex/WMS_QrService.getTasks';

export default class QrLandingV2_WosList extends LightningElement {
    handleGoBack() {
        this.dispatchEvent(new CustomEvent('back', { detail: { value: 'wosList' }}));
    }

    @api workerId;
    @api locatorId;
    @api wosType;

    @track _listAllTasks = [
        { label: 'Receiving', value: 'receiving'},
        { label: 'VAS'      , value: 'valueaddedservice'},
        { label: 'Put away' , value: 'putaway'},
        { label: 'Picking'  , value: 'picking'},
        { label: 'Dispatch' , value: 'dispatch'},
    ];

    connectedCallback() {
        getTasks({ workerId: this.workerId, locatorId: this.locatorId })
            .then(data => {
                this._listAllTasks.forEach(task => {
                    task.filterWo = task.filterPo = task.filterSo = task.records = task.filteredRecords = null;
                    let records = data.filter(x => x.RecordType.DeveloperName.toLowerCase().indexOf(task.value) > -1);
                    if (records.length === 0) {
                        return;
                    }
                    task.hasRecords = true;
                    task.records = task.filteredRecords = records;

                    task.listWo = [{ label: 'All', value: null}].concat(task.records.reduce(function (arr, item) { 
                        arr.push({ label: item.clofor_com_cfs__WorkOrder__r.Name, value: item.clofor_com_cfs__WorkOrder__c });
                        return arr;
                    }, []).sort(function (x, y) { return x > y ? 1 : x === y ? 0 : -1}));

                    task.listPo = [{ label: 'All', value: null}].concat(task.records.reduce(function (arr, item) { 
                        if (item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__r) {
                            arr.push({ label: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__r.Name, value: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__c });
                        }
                        return arr;
                    }, []).sort(function (x, y) { return x > y ? 1 : x === y ? 0 : -1}));

                    task.listSo = [{ label: 'All', value: null}].concat(task.records.reduce(function (arr, item) { 
                        if (item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__r) {
                            arr.push({ label: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__r.Name, value: item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderID__c });
                        }
                        return arr;
                    }, []).sort(function (x, y) { return x > y ? 1 : x === y ? 0 : -1}));

                    task.listWoDisabled = task.listWo.length === 1;
                    task.listPoDisabled = task.listPo.length === 1;
                    task.listSoDisabled = task.listSo.length === 1;
                });
                this._listAllTasks = [...this._listAllTasks];
            })
            .catch(error => this.dispatchEvent(new ShowToastEvent({ title: error.body.message, message: error.body.stackTrace, variant: 'error' })))
    }

    get _wosList() {
        const filtered = this._listAllTasks.find(x => x.value === this.wosType);
        if (filtered) {
            return [filtered];
        }
        return this._listAllTasks.filter(x => x.hasRecords);
    }

    handleWosFilter(e) {
        var serviceName = e.target.name;
        var serviceGroup = this._listAllTasks.find(item => item.value === serviceName);
        serviceGroup[e.target.dataset.filter] = e.detail.value;

		serviceGroup.filteredRecords = serviceGroup.records.filter(function (item) {
			return (serviceGroup.filterWo == null || item.clofor_com_cfs__WorkOrder__c === serviceGroup.filterWo)
				&& (serviceGroup.filterPo == null || item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__PurchasingOrderID__c === serviceGroup.filterPo)
				&& (serviceGroup.filterSo == null || item.clofor_com_cfs__WorkOrder__r.clofor_com_cfs__SalesOrderId__c === serviceGroup.filterSo);
        });
        
        this._listAllTasks = this._listAllTasks.slice(0);
    }

    handleSelectService(e) {
        this.dispatchEvent(new CustomEvent('select', { detail: { value: e.currentTarget.dataset.recordid }}));
    }
}