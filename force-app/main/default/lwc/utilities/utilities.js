/* eslint-disable @lwc/lwc/no-async-operation */
let uidCounter = 0;

const cookieUtils = {
    setCookie: function (cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    },
    getCookie: function (cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return null;
    }
}
const objUtils = {
    flattenObject: function (obj, pathPrefix) {
        let temp = {};
        Object.keys(obj).forEach(field => {
            let path = pathPrefix ? (pathPrefix + '.' + field) : field;
            temp[path] = obj[field];
            if (this.isLiteralObj(obj[field])) {
                Object.assign(temp, this.flattenObject(obj[field], path));
            }
        });
        return temp;
    },
    flattenObjects: function (records, fields) {
        if (!this.isArray(records) || records.length === 0 || !this.isArray(fields) || fields.length === 0) {
            return null;
        }
        fields = fields.map(field => ({ mapTo: field, mapFrom: field ? field.split('.') : field }));
        return records.map(obj => {
            let flattened = {};
            fields.forEach(f => {
                flattened[f.mapTo] = this.getValue(obj, f.mapFrom);
            });
            return flattened;
        });
    },
    getValue(obj, path) {
        let temp = obj;
        path.forEach(key => { if (temp) { temp = temp[key]; } });
        return temp;
    },
    isArray(obj) {
        return obj && typeof obj === 'object' && obj.constructor === Array;
    },
    isLiteralObj(a) {
        return (!!a) && (a.constructor === Object)
    },
    getSaveError(error) {
        //get only 1st error
        error = Array.isArray(error.body) ? error.body[0] : error.body;
        if ((error.message.indexOf('{') !== 0 && error.message.indexOf('[') !== 0) || error.message === '[]') {
            return error.message;
        }
        error = JSON.parse(error.message);
        error = Array.isArray(error) ? error[0] : error;
       
        let dup = 'duplicateRule';
        if (dup in error) {
            return {
                statusCode: "DUPLICATES_DETECTED",
                message: "Duplicates found",
                records: error.matchResults[0].matchRecords.map(rec => ({
                    fields: rec.fieldDiffs.filter(fd => fd.difference === 'Same').map(fd => fd.name)
                }))
            };
        }
        return error;
    },
    getErrorMessage(error) {
        return Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : typeof error.body.message === 'string' ? error.body.message : 'Unknown error';
    }
}

const stringUtils = {
    escapeComma: function (val) {
        if (val && val.indexOf(',') > -1) {
            if (val.indexOf('"') > -1) {
                val = val.replace(/"/g, '""');
            }
            return '"' + val + '"';
        }
        return val;
    },
    booleanToString(obj) {
        Object.keys(obj).forEach(x => {
            if (objUtils.isLiteralObj(obj[x])) {
                this.booleanToString(obj[x]);
            }
            else if (typeof obj[x] === 'boolean') {
                obj[x] = obj[x].toString();
            }
        });
    },
    stringToBoolean(obj) {
        Object.keys(obj).forEach(x => {
            if (objUtils.isLiteralObj(obj[x])) {
                this.stringToBoolean(obj[x]);
            }
            else {
                obj[x] = obj[x] === "true" ? true : obj[x] === "false" ? false : obj[x];
            }
        });
    },
    stripHtml: function (text, length) {
        text = text.replace(/<[^>]*>/g, ' ');
        text = text.replace(/^(\s|\r\n|\n|\r)/,' ');
        text = text.replace(/(\r\n|\n|\r)/g,' ');
        if (length && length > 0) {
            text = text.substring(0, length);
            text = text.substring(0, text.lastIndexOf(' '));
        }
        return text;
    },
    getUid: function () { return uidCounter++; }
}

const navUtils = {
    getCurrentPage() {
        return window.location.pathname.substring(window.location.pathname.lastIndexOf('/s/') + 3, window.location.pathname.length);
    },
    getCommunityPageRef() {
        return { type: "community", attributes: 'memberPortal' };
    },
    //example - https://orgURL/memberPortal/s/
    getCommunityUrl() {
        let pathSplit = (window.location.pathname).split("/");
        return window.location.origin + '/' + pathSplit[1] + '/' + pathSplit[2] + '/';
    }
}

const blobUtils = {
    saveFile: function (blob, filename) {
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
}

const csvUtils = {
    getString: function ({ columnLabels, columnFields, records }) {
        return [columnLabels.map(label => stringUtils.escapeComma(label)).toString()].concat(records.map(item => columnFields.map(field => stringUtils.escapeComma(item[field])).toString())).join('\n');
    },
    download: function ({ columnLabels, columnFields, records, fileName }) {
        let csv = this.getString({ columnLabels, columnFields, records });
        let blob = new Blob([csv], { type: 'application/octet-stream' });
        blobUtils.saveFile(blob, fileName);
    }
}

const searchUtils = {
    search(searchFrom, searchTerm, searchInFields) {
        if (!searchFrom || !searchTerm) {
            return null;
        }
        searchTerm = searchTerm.trim().toLowerCase();
        if (objUtils.isArray(searchFrom)) {
            return searchFrom.filter(x => this.search(x, searchTerm, searchInFields));
        }
        else if (objUtils.isLiteralObj(searchFrom)) {
            const fields = searchInFields || Object.keys(searchFrom);
            for (let x of fields) {
                if (this.search(searchFrom[x], searchTerm, searchInFields)) {
                    return true;
                }
            }
            return false;
        }
        searchFrom = searchFrom.toString().toLowerCase();
        return searchFrom.indexOf(searchTerm) > -1 || new RegExp("^" + searchTerm.split("*").join(".*") + "$").test(searchFrom);
    }
}

const regexUtils = {
    formatInput(e, regexFormat, regexReplace) {
        var v = e.currentTarget.value;
        var keyID = e.code;
        var input = v;

        if (keyID !== 'Backspace') {
            if (e.currentTarget.name === 'phone' && v.length > 10 && !v.includes(')') && !v.includes('(')) {
                //trim characters
                v = v.substring(0, v.length - 2);
            }
            if (e.currentTarget.name === 'MobilePhone' && v.length >= 11 && v.indexOf(' ') === -1) {
                //trim characters
                let diff = v.length - 10;
                v = v.substring(0, v.length - diff) + ' ';

            }
            input = input.replace(/\D/g, '');
            input = input.replace(regexFormat, regexReplace);
        }
        return input;

    }
}


const validationUtils = {
    validateFields: function (cmp, options) {
        options = options || {};
        let scrollToError = options.scrollToError == null ? true : options.scrollToError;
        let selector = options.selector == null ? '.input' : options.selector;

        let scrolledToError = false;
        return [...cmp.template.querySelectorAll(selector)].reduce((isValidSoFar, item) => {
            var fieldValid = item.reportValidity();
            if (!fieldValid && scrollToError && !scrolledToError) {
                item.scrollIntoView();
                item.focus();
                scrolledToError = true;
            }
            return isValidSoFar && fieldValid;
        }, true);
    },
    validateField: function (cmp) {
        const valid = cmp.reportValidity();
        if (!valid) {
            cmp.scrollIntoView();
            cmp.focus();
        }
        return valid;
    },
    setCustomValidity: function (cmp, msg, focus) {
        cmp.setCustomValidity(msg);
        cmp.reportValidity();
        if (focus) {
            cmp.focus();
        }
    }
}

const calloutUtils = {
    get: function (url) {
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", url);
            xhr.onload = () => resolve(xhr.responseText);
            xhr.onerror = () => reject(xhr.statusText);
            xhr.send();
        });
    }
}

const dateUtils = {
    getToday : function() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();

        today = yyyy + '-' + mm + '-' + dd;
		return today;
	}
}


export { stringUtils, blobUtils, csvUtils, objUtils, searchUtils, navUtils, cookieUtils, validationUtils, regexUtils, calloutUtils,dateUtils }