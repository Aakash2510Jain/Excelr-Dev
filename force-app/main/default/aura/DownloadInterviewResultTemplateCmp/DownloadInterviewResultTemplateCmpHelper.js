({
    convertArrayToCSV : function(component, metaDataRecord, sObjectList){
        debugger;
        if (sObjectList == null || sObjectList.length == 0) {
            return null;  
        } 
                
        var columnEnd = ',';
        var lineEnd =  '\n';
        
        // Get the CSV header from the list.
        /*var keys = new Set();
        sObjectList.forEach(function(record){
            Object.keys(record).forEach(function(key){
                
                if(key!="Id")
                    keys.add(key);
            });
        });  
        
        keys = Array.from(keys); */
        
        var keys = ['Application_Id', 'Student_Email','Apti_Marks','Apti_Result','GD_Result','PI_Result'];

        var csvString = '';
        csvString += keys.join(columnEnd);
        csvString += lineEnd;
        for(var i=0; i < sObjectList.length; i++){
            var counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey];
                // add , after every value except the first.
                if(counter > 0){
                    csvString += columnEnd;
                }
                // If the column is undefined, leave it as blank in the CSV file.
                var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                csvString += '"'+ value +'"';
                counter++;
            }
            csvString += lineEnd;
        }
        return csvString;
        
        
        /*var csvStringResult, counter, keys, columnDivider, lineDivider;

        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        keys = ['Application Id', 'Student Email','Aptitude Marks','Aptitude Result','GD Result', 'PI Result'];
        
        /*var keys = new Set();
        sObjectList.forEach(function(record){
            Object.keys(record).forEach(function(key){
                if(key!="Id")
                    keys.add(key);
            });
        });        /
        //keys = Array.from(keys);
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;

        
        for(var i=0; i < sObjectList.length; i++){
            var counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey];
                // add , after every value except the first.
                if(counter > 0){
                    csvStringResult += columnEnd;
                }
                // If the column is undefined, leave it as blank in the CSV file.
                var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                csvStringResult += '"'+ value +'"';
                counter++;
            }
            csvString += lineEnd;
        }
        return csvStringResult;
        

        // this labels use in CSV file header  
        
        
        /*for(var i=0; i <= metaDataRecord.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  

              // add , [comma] after every String value,. [except first]
                  if(counter >= 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ metaDataRecord[i][skey]+'"'; 
               
               counter++;

            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close /
       
       // return the CSV formate String 
        return csvStringResult;   */     
        
    }
})