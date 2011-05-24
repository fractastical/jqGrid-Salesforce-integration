function jqGridInclude(modules)
{  
    var pathtojsfiles = ""; // need to be ajusted
    // set include to false if you do not want some modules to be included
    var filename;
    for(var i=0;i<modules.length; i++)
    {
        if(modules[i].include === true) {
        	
        	filename = pathtojsfiles+modules[i].incfile;
       		if(jQuery.browser.safari ) {
       			jQuery.ajax({url:filename,dataType:'script', async:false, cache: true});
       		} else {
				if (jQuery.browser.msie) {

				} else {
        			IncludeJavaScript(filename);
				}
			}
        }
    }
    function IncludeJavaScript(jsFile)
    {
        var oHead = document.getElementsByTagName('head')[0];
        var oScript = document.createElement('script');
        oScript.type = 'text/javascript';
        oScript.charset = 'utf-8';
        oScript.src = jsFile;
        oHead.appendChild(oScript);        
    };
};
		
    