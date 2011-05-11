var Edition = function() {

}

Edition.prototype.download = function(success, fail, issueName) {
    return PhoneGap.exec("Edition.download", GetFunctionName(success), GetFunctionName(fail), issueName);
};

PhoneGap.addConstructor(function()
{
	if(!window.plugins)
	{
		window.plugins = {};
	}
	window.plugins.edition = new Edition();
});