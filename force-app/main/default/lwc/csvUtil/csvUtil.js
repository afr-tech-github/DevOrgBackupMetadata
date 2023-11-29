/* eslint-disable @lwc/lwc/no-async-operation */
    
const escapeComma = function (val) {
    if (val && val.indexOf(',') > -1) {
        if (val.indexOf('"') > -1) {
            val = val.replace(/"/g, '""');
        }
        return '"' + val + '"';
    }
    return val;
}
    
const saveFile = function(blob, filename) {
    if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, filename);
    } else {
        const a = document.createElement('a');
        document.body.appendChild(a);
        const url = window.URL.createObjectURL(blob);
        a.href = url;
        a.download = filename;
        a.click();
        setTimeout(function () {
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        }, 0)
    }
}

const download = function (columnLabels, columnFields, records, fileName) {
    let csv = [columnLabels.map(label => escapeComma(label)).toString()].concat(records.map(item => columnFields.map(field => escapeComma(item[field])).toString())).join('\n');
    let blob = new Blob([csv], {type: 'application/octet-stream'});
    saveFile(blob, fileName);
}

export { download, escapeComma, saveFile}