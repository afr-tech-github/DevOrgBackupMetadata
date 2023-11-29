import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './picklist-template.html';
import LookupTemplate from './lookup-template.html';

export default class customDatatablePicklist extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'objectName', 'fieldApiName', 'recordtypeId'],
        },
        lookup: {
            template: LookupTemplate,
            typeAttributes: ['uniqueId', 'object', 'icon', 'label', 'displayFields',
                            'displayFormat', 'placeholder', 'filters', 'valueId', 'fieldApiName',
                            'isDisplay']
        }
    };

    hasRendered = true;



}