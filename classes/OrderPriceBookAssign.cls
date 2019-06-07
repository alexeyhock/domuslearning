public with sharing class OrderPriceBookAssign {

    public static RecordType TYPE_STANDARD = [SELECT Id, Name FROM RecordType WHERE Name = 'Standard' LIMIT 1];
    public static RecordType TYPE_TRIAL = [SELECT Id, Name FROM RecordType WHERE Name = 'Trial' LIMIT 1];
    public static List<PriceBookName__mdt> pbName = [SELECT Label FROM PriceBookName__mdt];
    public static Map<String, Id> priceBook2 = new Map<String, Id>();

    public static void assignPriceBookToOrder(List<Order> orders) {
        for (Order ord : orders) {
            if (ord.RecordTypeId == TYPE_STANDARD.Id) {
                ord.Pricebook2Id = getPriceBookId(TYPE_STANDARD);
            }
            if (ord.RecordTypeId == TYPE_TRIAL.Id) {
                ord.Pricebook2Id = getPriceBookId(TYPE_TRIAL);
            }
        }
    }

    public static Id getPriceBookId(RecordType orderRecordType) {
        buildPriceBookMap();
        if(orderRecordType == null) return null;
        System.debug(pbName.size());
        for (Integer i = 0; i < pbName.size(); i++) {
            if(pbName[i].Label.contains(orderRecordType.Name) == true) {
                return  priceBook2.get(pbName[i].Label);
            }
        }
        return null;
    }

    public static void checkCorrectOrderItems(Map<Id, OrderItem> mapOrderItem) {
        List<OrderItem> orderItems = getOrderItems(mapOrderItem.keySet());
        for (OrderItem orIt : orderItems) {
            if (orIt.Order.RecordTypeId == TYPE_TRIAL.Id && orIt.UnitPrice > 0) {
                orIt.addError('Price can\'t be more than 0 in trial order');
            }
        }
    }

    public static List<OrderItem> getOrderItems(Set<Id> orderItemsId) {
        return [SELECT Id, Order.Id, OrderItemNumber, UnitPrice, Product2.Name, Order.RecordTypeId FROM OrderItem WHERE Id IN :orderItemsId];
    }



     public static void buildPriceBookMap() {
         for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
             priceBook2.put(pb.Name, pb.Id);
         }
     }

}
