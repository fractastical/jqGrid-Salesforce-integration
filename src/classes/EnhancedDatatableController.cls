public with sharing class EnhancedDatatableController {

    public List<String> columns;
    public String jsonData      { get; set; }  
    public String colNamesJson  { get; set; }
    public String colModelJson  { get; set; }
    public String colRulesJson  { get; set; }
    public List<String> labels  { get; set; }  
    public List<String> widths  { get; set; }
    public List<String> types   { get; set; }    
	public List<String> editOptions { get; set; }


    public Boolean widthIsPercent { get; set; }  
    public Boolean heightIsPercent { get; set; }
    public String uid { get; set; }
    public String objectLabel { get; set; }

    //Attributes
    public String myRowNumber   { get; set; }
    public String myRowOptions  { get; set; }
    public String myWidth   { get; set; }
    public String myHeight  { get; set; }
    public String param     { get; set; }   
    public String objectName    { get; set; }
    public String filterString  { get; set; }
    public String columnString  { get; set; }
    public String requiredFieldName  { get; set; }
    public String requiredFieldValue  { get; set; }
    public Boolean multiselect     { get; set; }
    public Boolean editable     { get; set; }
    public String outerObjectId     { get; set; }
    public String alphabeticPaginateColumn { get; set; }
    public String alphabeticPaginateColumn2 { get; set; }
    public Boolean displaySearch { get; set; }
    public Boolean alphabeticPaginate { get; set; }
    public List<String> eOptions	{ get; set; }
    //public List<String> statuses	{ get; set; }
    public List<StatusWrapper> fullStatuses	{ get; set; }
    
    public List<String> alphabet { get; set;}
    
    public String getOnLoad()  
    {
    	  
			  
			
    	if(filterString == null)
    		filterString = '';
     
        if(editable == null)
            editable = false;

		if(multiselect == null)
			multiselect = false;


        if(myRowNumber == null || myRowNumber == '')
            myRowNumber = '10';  

        if(myRowOptions == null || myRowOptions == '')
            myRowOptions = '10,20,50';  
            
            
        if(myWidth != null )
        	myWidth = myWidth.replaceAll('px','').trim();       
        
        if(myWidth == null || myWidth == '')
        {
            widthIsPercent = true;
            myWidth = '100';
        }
        else if (myWidth.substring(myWidth.length() -  1, myWidth.length()) == '%')
        {
            widthIsPercent = true;
            myWidth = myWidth.substring(0, myWidth.length() -  1);  
        }
        else
            widthIsPercent = false;
              
        if(myHeight != null )
        	myHeight = myHeight.replaceAll('px','').trim();       
        if(myHeight == null || myHeight == '')
        {
            myHeight = '200';  
            heightIsPercent = false;
        }
        else if (myHeight.substring(myHeight.length() -  1, myHeight.length()) == '%')
        {
            heightIsPercent = true;
            myHeight = myHeight.substring(0, myHeight.length() -  1);
        }
        else
            heightIsPercent = false;
       
       if(objectName == 'CampaignMember')
       {
       		fullStatuses = new List<StatusWrapper>();
       		String query = 'select id, label from CampaignMemberStatus ' + filterString; 
       		List<SObject> sos = Database.query(query);
       		for(SObject so: sos)
       			fullStatuses.add(new StatusWrapper((String) so.get('label')));
       			
       		
       }
        
        alphabeticPaginateColumn2 = alphabeticPaginateColumn;  
        
        if(alphabeticPaginateColumn != null && alphabeticPaginateColumn != '')  
        { 
               alphabet = new list<String> 
                { 'A', 'B' , 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
                    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
                    'W', 'X', 'Y', 'Z'          
                 };
             alphabeticPaginate = true;  
             //The original alphabeticPaginateColumn could not be updated for some reason. 8(
			alphabeticPaginateColumn2 = alphabeticPaginateColumn2.trim().replaceAll('[.]','zzz');

        }
        else
            alphabeticPaginate = false;
        
        columns = new List<String>();


        //if(editable)
        //    columns.add('Actions');

        columnString = columnString.trim().replaceAll('[.]','zzz');  
         // Evil trick to get debugging info in managed package
         try {
         	List<Sobject> sos = Database.query('select id from contact where name = \'' + columnString + '\'');
         } catch (Exception e)
         {
         	
         }
         
         
         List<String> newColumns = new List<String>();
         
        if(editable)
            newColumns.add('id');   
        
        //if(requiredFieldName != null)
        //    newColumns.add(requiredFieldName);   

         List<String> evenNewerColumns = columnString.split(',');
         
         for(String c: evenNewerColumns)
             newColumns.add(c);


        for(Integer i=0; i< newColumns.size(); i++)  
            newColumns[i] = newColumns.get(i).trim();     

        for(String c : newColumns)
            columns.add(c);

            
        getLabelsAndWidthsfromFields(newColumns,objectName);
        
        if(editable) {
            List<String> newLabels = new List<String>();
           // newLabels.add('Actions');
            for(String l : labels)
                newLabels.add(l);
            labels = newLabels;        
        }  
        
        System.debug('nc:' + newColumns.size() + 'w:' + widths.size() + 't:' + types.size() + 'eo:' + editOptions.size());
          
        colNamesJson = JsonUtils.jsonify(labels); 
        colRulesJson = JsonUtils.genColumnSearchRules(newColumns);
        colModelJson = JsonUtils.genColumnModel(newColumns,widths,types,editOptions,outerObjectId,requiredFieldName, editable);

        jsonData = JsonUtils.getJsonFromObject(objectName, newColumns, filterString);  
        uid = objectName + 'datatable';
        
                
        return '';
    }
    
    public void getLabelsAndWidthsfromFields(List<String> fieldNames, String objectName)
    { 
          labels = new List<String>();                 
          widths = new List<String>();      
          types = new List<String>();                 
          editOptions = new List<String>();                 
 
          try {
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                SObjectType sot = gd.get(objectName);
                DescribeSObjectResult sor = sot.getDescribe();
                objectLabel = sor.getLabelPlural();
                Map<String, SObjectField> fields = sor.fields.getMap();
                List<SObjectField> fieldtokens = fields.values();
                for(String fn : fieldNames)
                {
                    SObjectField field;
                    List<String> fnParts = fn.split('zzz');  
                    if(fnParts.size() == 2)
                    {
                        String outerObjectName = fnParts.get(0);
                        if(outerObjectName.endsWith('__r'))
                            outerObjectName = outerObjectName.substring(0,outerObjectName.length() - 1) + 'c';
                        SObjectType sotOuter = gd.get(outerObjectName);
                        Map<String, SObjectField> outerFields = sotOuter.getDescribe().fields.getMap();
                        field = outerFields.get(fnParts.get(1));  
                          
                    }
                    else
                         field = fields.get(fn);
                         
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    String l = fieldDescribe.getLabel();
                    labels.add(l);
                    widths.add(String.valueOf(fieldDescribe.getLength() * 3));
                    String t = fieldDescribe.getType().name();    
                    System.debug('fl:' + fieldDescribe.getLabel() + ' ft:' + t);
                    types.add(JsonUtils.getDisplayTypefromSchemaType(t));
                    String eOption = ' ';
                    
                    if(l == 'Status' && objectName == 'CampaignMember') {  
                    	List<String> cs = new List<String>();                    	
						cs.add('label');
                    	eOption = JsonUtils.getEditOptionsFromReference('CampaignMemberStatus', cs, filterString);  
                    	
                    }
                    else if(t == 'REFERENCE') {
                    	List<String> cs = new List<String>();
                    	//Legacy. Status apparently doesn't appear as a reference. Oops.
                    	/*
                    	if(fieldDescribe.getReferenceTo().get(0).getDescribe().getName()  == 'CampaignMemberStatus')
                    	{
							 cs.add('label');
                    		 eOption = JsonUtils.getEditOptionsFromReference(fieldDescribe.getReferenceTo().get(0).getDescribe().getName(), cs, filterString);  

                    	} */  
							cs.add('name');							
							cs.add('id');							
							eOption = JsonUtils.getEditOptionsFromReference(fieldDescribe.getReferenceTo().get(0).getDescribe().getName(), cs, filterString);  

                    }
                    else if(t == 'PICKLIST')
                    {
			            Map<String, Schema.SObjectField> fieldsMap = sor.fields.getMap();
			            System.debug('fieldName:' + fieldDescribe.getName());
			            List<Schema.PicklistEntry> pickListValues = fieldsMap.get(fieldDescribe.getName()).getDescribe().getPickListValues();
			            System.debug('pv:' + pickListValues.size());
  
			            eOption = 'editoptions:{value:"';  
			            for(Schema.PicklistEntry pe : pickListValues)
			            {
			            	eOption += pe.getLabel() + ':' + pe.getValue() + ';'			            	;
			            }
                    	eOption = eOption.subString(0,eOption.length() - 1);
                    	eOption += '"}';  
                    	
                    }
                    editOptions.add(eOption);
                    	  
                    
                }
            }
            catch (Exception e)
            {
                System.debug('UNABLE TO GENERATE LABELS:' + e);
            }
                     
    }

   public class StatusWrapper
   {
 	  public  String status      { get; set; }
   	  public String abbrevStatus { get; set; }
   	  
   	  public StatusWrapper(String status) {
   	  	
			this.status = status;
			abbrevStatus = status.replaceAll('[^a-zA-Z0-9]','_'); 	
   	  }
   	
   }





}