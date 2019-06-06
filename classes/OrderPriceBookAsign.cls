public with sharing class OrderPriceBookAsign {

//    Schema
//    public static final Map<Id,Schema.RecordTypeInfo> TYPE_PRIVATE = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosById();

    public static RecordType TYPE_PRIVATE = [SELECT Id, Name FROM RecordType WHERE Name = 'Private' LIMIT 1];
    public static RecordType TYPE_TRIAL = [SELECT Id, Name FROM RecordType WHERE Name = 'Trial' LIMIT 1];

    public static void HandlerBeforeInsert(List<Order> orders) {
        Map<String ,Id> pb2 = new Map<String, Id>();
        for(Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
            pb2.put(pb.Name, pb.Id);
        }

        for(Order ord : orders) {
            if(ord.RecordTypeId == TYPE_PRIVATE.Id) {
                //CS
                ord.Pricebook2Id = pb2.get('Standard Price Book');
            }
            if(ord.RecordTypeId == TYPE_TRIAL.Id) {
                ord.Pricebook2Id = pb2.get('Trial Price');
            }
        }
    }

    //items
    public static void HandlerBeforeUpdate(List<Order> orders) {
        for(Order ord : orders) {
            if(ord.TotalAmount > 0) {
                ord.addError('Price can\'t be more than 0 in trial order');
            }
        }
    }

}