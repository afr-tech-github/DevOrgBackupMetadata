({
	doGetAddress: function (c, e, h) {
		if (!h.isInputValid(c)) {
			return;
		}
		h.invokeActionAsync(c, h, 'c.getAddress', {
				inputLong: c.get('v.inputLong'),
				inputLat: c.get('v.inputLat'),
			})
			.then(function(result) {
				try {
					var res = JSON.parse(result);

					if (res.status != 'OK') {
						console.log(res);
						if (res.status == 'ZERO_RESULTS') {
							alert('No match found.');
						}
						else if (res.error_message != null) {
							alert(res.error_message);
						}
						return;
					}

					c.set('v.listAddresses', res.results.map(function (item) {
						return item.formatted_address;
					}));
				}
				catch (ex) {
					console.error(ex);
					alert(ex);
				}
			})
			.catch(function(ex) {
				console.error(ex);
				alert(ex);
			});
	}
})