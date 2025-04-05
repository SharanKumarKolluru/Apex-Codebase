/* 
Reusable & Metadata-Driven Field Mapping in Apex!

One of the most repetitive tasks in Salesforce API integrations is mapping fields from an API callout to Salesforce objects. 
Traditionally, we have to hardcode each field mapping in Apex, making it difficult to maintain and modify.

To solve this, I built a reusable field mapping function that leverages Salesforce Metadata to store the mapping between source and target fields. 

This approach makes API integrations:
✅ Fully Reusable – No need to rewrite mapping logic for each integration
✅ Metadata-Driven – Admins can update mappings without code changes
✅ Scalable & Maintainable – Reduces hardcoding and improves flexibility

🔹 How It Works?
The function dynamically determines the field type, applies the correct conversion, and updates the record. 
If custom logic is required (e.g., handling Lookup or Master-Detail relationships), a developer can step in and extend the logic.

Most of my use cases require custom code for relationship fields, but the rest can be mapped seamlessly using this scalable, admin-friendly approach.
By making field mapping reusable, flexible, and admin-configurable, we can reduce development effort and speed up API integrations. 🚀
*/
public static void populateValue(SObject sObjectRecord, String value, String objectName, String field) {
    if (String.isBlank(value)) return; // No processing needed
 
    try {
        SObjectType sObjType = ((SObject) Type.forName('Schema.' + objectName).newInstance()).getSObjectType();
        DescribeFieldResult fieldDescribe = sObjType.getDescribe().fields.getMap().get(field).getDescribe();
 
        if (!fieldDescribe.isUpdateable()) {
            System.debug('Field ' + field + ' is not editable.');
            return;
        }
 
        value = value.trim();
        String fieldType = fieldDescribe.getType().name().toLowerCase();
 
        // Mapping field types to conversion functions
        Map<String, Object> typeConversionMap = new Map<String, Object>{
            'datetime' => (Object) DateTime.valueOf(value),
            'date' => (Object) Date.valueOf(value),
            'currency' => (Object) Decimal.valueOf(value),
            'double' => (Object) Decimal.valueOf(value),
            'checkbox' => (Object) Boolean.valueOf(value),
            'boolean' => (Object) Boolean.valueOf(value)
        };
 
        // Apply conversion if type is in the map, otherwise store as String
        sObjectRecord.put(field, typeConversionMap.containsKey(fieldType) ? typeConversionMap.get(fieldType) : value);
    } catch (Exception e) {
        System.debug('Error in populateValue: Field =' + field + ', Value=' + value + ', Error=' + e.getMessage());
    }
}
 
