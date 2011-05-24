public class JsonUtils {
    
    // Sample output:
    // editoptions:{value:"FE:FedEx;IN:InTime;TN:TNT;AR:ARAMEX"}},

    
     public static String getEditOptionsFromReference(String objectName, List<String> columns, String filterString)
     {
     	
     	String editOptions = 'editoptions:{value:"';
     	
        if(filterString == null)  
            filterString = '';
  
            try {
                
                //System.debug('getJsonifiedObjectRecords for:' + objectName);
                  
                String queryString = 'Select ';
                  
                for(String c: columns) 
                    queryString += c + ',';
                
                queryString = queryString.substring(0,queryString.length() - 1);
                queryString += ' from ' + objectName + ' ' + filterString;
                queryString += ' limit 15';
                
                //System.debug('QUERYSTRING:' + objectName);
                List<sObject> sos = Database.query(queryString);
                //Map<String, Schema.SObjectField> columns = sos.getSObjectType().getDescribe().fields.getMap();
                Integer count = 0;                     
                //editOptions += '[';    
                for (sObject so : sos) {  
                        //editOptions += ' { ';
                          for(String column : columns)
                          {   
                          			count++;
                                     try   
                                     {
                                        String cellVal = String.valueOf( so.get(column));  
                                        if(columns.size() == 1)  
	                                        editOptions += ''+String.escapeSingleQuotes(cellVal)+':'+String.escapeSingleQuotes(cellVal)+';';                                           
                                        if(columns.size() == 2 && ( Math.mod(count, 2) == 1) ) 
	                                        editOptions += ''+String.escapeSingleQuotes(cellVal)+':';            
                                        if(columns.size() == 2 && ( Math.mod(count, 2) == 0) )   
	                                        editOptions += ''+String.escapeSingleQuotes(cellVal)+';';            
                                     }          
                                     catch(Exception ex) 
                                     {
                                        System.debug(ex);
                                     }
                         }
                         //editOptions = editOptions.substring(0, editOptions.length() - 1);
                         //editOptions = editOptions + '},';  
                         
                }
        
                editOptions = editOptions.subString(0,editOptions.length() - 1);
                
            }
            catch(Exception e)
            {   
                System.debug('Bad query in Jsonify Call ' + e);         
            }

        editOptions += '"}';
        
        System.debug('editOptions:' + editOptions);
        

        return editOptions;
   }
        
    
    
    
    public static String getJsonFromObject(String objectName, List<String> columns, String filterString)
     {
        if(filterString == null)  
            filterString = '';
  
            String jsonData = '[ ';
            try {
                
                //System.debug('getJsonifiedObjectRecords for:' + objectName);
                  
                String queryString = 'Select ';
                  
                for(String c: columns) 
                    queryString += c.ReplaceAll('zzz','.') + ',';
                
                queryString = queryString.substring(0,queryString.length() - 1);
                queryString += ' from ' + objectName + ' ' + filterString;
                queryString += ' limit 10000';
                
                //System.debug('QUERYSTRING:' + objectName);
                List<sObject> sos = Database.query(queryString);
                //Map<String, Schema.SObjectField> columns = sos.getSObjectType().getDescribe().fields.getMap();
                                      
                //jsonData += '[';    
                for (sObject so : sos) {  
                        jsonData += ' { ';
                          for(String column : columns)
                          {   
                                     try   
                                     {  
                                        String cellval = '';  
                                        List<String> cParts = column.split('zzz');  
                                        if(cParts.size() == 2)
                                        {
                                            String outerObjectName = cParts.get(0);
                                            
                                            if(outerObjectName.endsWith('__r'))
                                              outerObjectName = outerObjectName.substring(0,outerObjectName.length() - 1) + 'c';

                                            cellval = (String) so.getSObject(outerObjectName).get(cParts.get(1));
                                            
                                        }
                                        else
                                        {
                                            cellVal = String.valueOf( so.get(column));
                                        }
                                        jsonData += '"'+column+'" : "'+String.escapeSingleQuotes(cellVal)+'",'; 


                                          
                                     }      
                                     catch(Exception ex) 
                                     {
                                     	
                                        System.debug(ex);
                                     }
                         }
                         jsonData = jsonData.substring(0, jsonData.length() - 1);
                         jsonData = jsonData + '},';  
                         
                }
        
                jsonData = jsonData.subString(0,jsonData.length() - 1);
                
            }
            catch(Exception e)
            {   
                System.debug('Bad query in Jsonify Call ' + e);         
            }

        jsonData += ']';
        
        System.debug('jsonData:' + jsonData);

        return jsonData;
   }
        
        
   public static String jsonify(List<String> records)
        {
            String json = '[ ';
            for(String r : records) {
                r = r.trim();
                json += '\'' + r + '\',';
            }
            
            json = json.substring(0,json.length() - 1);
            json += ']';
            return json;
        }

/*
    public static String genColumnModel(List<String> columns, Boolean editable) {
        
        String model = '[ ';
        if(editable)
            model += '{name:\'act\',index:\'act\', width:75,sortable:false},';
        for(String c: columns)
            model += '{ name: \'' + c + '\', index: \'' + c + '\', width: 300 },';  
        model = model.substring(0, model.length() - 1);
        model += ']';
        return model;
    }  */
    
   // Example: [ {"field":"FirstName","op":oper,"data":arg},{"field":"LastName","op":oper,"data":arg},{"field":"Phone","op":oper,"data":arg} ]

    public static String genColumnSearchRules(List<String> columns) {
        
        String rule = '[ ';
        for(Integer i=0; i<columns.size(); i++)
        {
        	if(columns[i] != 'id')   
	            rule += '{ "field": "' + columns[i] + '", "op": oper, "data" : arg },' ;
              
        }
        rule = rule.substring(0, rule.length() - 1);
        rule += ']';
        return rule;
    }
    
    // lists must have same size
    public static String genColumnModel(List<String> columns, List<String> widths, List<String> types, List<String> editOptions, String outerObjectId, String requiredFieldName, Boolean editable) {
          
        String model = '[ ';  
        //if(editable)
        //    model += '{name:\'act\',index:\'act\', width:75,sortable:false},';
        
        for(Integer i=0; i<columns.size(); i++)
        {
            model += '{ name: \'' + columns[i] + '\', index: \'' + columns[i] + '\', width: ' + widths[i];
            if(columns[i] == 'id' || columns[i] == outerObjectId || columns[i] == requiredFieldName)
				model += ', hidden:true ';
			// This workaround comes from this page: http://blog.palelocust.com/?p=52
			// How to 
            else if(editable)   
            {
            	List<String> cParts = columns[i].split('zzz');  
	            model += ', editable:true';
                if(cParts.size() != 2)  {  

	                model += ', edittype:"' + types[i] + '",';
	                if(editOptions[i] != '')
		                model += editOptions[i];
                }

            }
			if(columns[i] == outerObjectId || columns[i] == requiredFieldName)	
				model += ', editable:true, editoptions: { defaultValue: \'' + ' ' + '\' } ' ;

	        //    edittype:"checkbox",editoptions:
	            
             model += '},';  
            
        }
        model = model.substring(0, model.length() - 1);
        model += ']';
        return model;
    }

      public static String getDisplayTypeFromSchemaType(String schemaType)
     {
     	if(schemaType == 'ID') return 'id';  
     	if(schemaType == 'EMAIL') return 'text';
		if(schemaType == 'URL') return 'text';
		if(schemaType == 'BOOLEAN') return 'checkbox';
		if(schemaType == 'DATE') return 'text';
		if(schemaType == 'DATETIME') return 'text';
		if(schemaType == 'CURRENCY') return 'text';
		if(schemaType == 'STRING') return 'text';
		if(schemaType == 'DOUBLE') return 'text';		
		if(schemaType == 'PERCENT') return 'text';
		if(schemaType == 'TEXTAREA') return 'textarea';
		if(schemaType == 'PHONE') return 'text';
		if(schemaType == 'PICKLIST') return 'select';
		if(schemaType == 'MULTIPICKLIST') return 'text';
		if(schemaType == 'REFERENCE') return 'select';    
     	
     	return null;	  
     }
    
    


}