
// FOUND AT http://stackoverflow.com/questions/901115/get-query-string-values-in-javascript
var urlParams = {};
(function () {
	var match,
		pl     = /\+/g,  // Regex for replacing addition symbol with a space
		search = /([^&=]+)=?([^&]*)/g,
		decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
		query  = window.location.search.substring(1);

	while (match = search.exec(query))
	   urlParams[decode(match[1])] = decode(match[2]);
})();

// XXXXX
function setSelectedValues(idSelect, values){

	var select = document.getElementById(idSelect);
	if(values.length == 0){
		return;
	}
	if(typeof select == 'undefined'){
		return;
	}
	var options = select.options;
	
	for(var i=0; i<options.length; i++){
		
		//alert($.inArray(options[i].value, values)+" VALUES:"+values+" VALUE:"+options[i].value);
		if($.inArray(options[i].value, values) > -1){
			options[i].selected = true;
		}
	}
}

function setSelectedValue(idSelect, value){

	var select = document.getElementById(idSelect);
	
	if(value ==""){
		return;
	}
	
	if(typeof select == 'undefined'){
		return;
	}
	
	var options = select.options;
	
	for(var i=0; i<options.length; i++){
		if(options[i].value == value){
			options[i].selected = true;
			return;
		}
	}
}