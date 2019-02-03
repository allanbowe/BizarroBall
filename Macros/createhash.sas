/* "createhash.sas" from the SAS Press book
      Data Management Solutions Using SAS Hash Table Operations:
      A Business Intelligence Case Study
*/

%macro createHash
       (lib = dw
       ,hashTable = hashTable
       ,metaData = template.Schema_Metadata
       );
 
 if 0 then set template.&hashTable;
 dcl hash _&hashTable(dataset:"&lib..&hashtable"
                     ,multidata:"Y"
                     ,ordered:"A");
 lr = 0;
 do while(lr=0);
    set &metadata end=lr;
    where upcase(hashTable) = "%upcase(&hashTable)";
    if is_a_key then _&hashTable..DefineKey(Column);
    _&hashTable..DefineData(Column);
 end;
 _&hashTable..DefineDone();
 
%mend createHash;
