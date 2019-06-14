public without sharing class OrderPriceBookAssign {

    public static Boolean isFirstTime = true;
    //public static RecordType TYPE_STANDARD = [SELECT Id, Name FROM RecordType WHERE Name = 'Standard' LIMIT 1];
    //public static RecordType TYPE_TRIAL = [SELECT Id, Name FROM RecordType WHERE Name = 'Trial' LIMIT 1];

    public static Map<Id, RecordType> recordTypesByIds = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType]);

    public static List<PriceBookName__mdt> priceBookNames = [SELECT Label FROM PriceBookName__mdt];
    public static Map<String, Pricebook2> priceBook2Map = new Map<String, Pricebook2>();

    public static void assignPriceBookToOrder(List<Order> orders) {
        for (Order ord : orders) {
            ord.Pricebook2Id = getPriceBookId(recordTypesByIds.get(ord.RecordTypeId));
        }
    }

    public static Id getPriceBookId(RecordType orderRecordType) {
        buildPriceBookMap();
        if(orderRecordType == null) return null;
        for (Integer i = 0; i < priceBookNames.size(); i++) {
            if (priceBookNames[i].Label.contains(orderRecordType.Name)) {
                return  priceBook2Map.get(priceBookNames[i].Label).Id;
            }
        }
        return null;
    }

    public static void checkCorrectOrderItems(Map<Id, OrderItem> mapOrderItem) {
        List<OrderItem> orderItems = getOrderItems(mapOrderItem.keySet());
        for (OrderItem orIt : orderItems) {
            System.debug(orIt.Order.RecordTypeId);
            if (recordTypesByIds.get(orIt.Order.RecordTypeId).Name == 'Trial' && orIt.UnitPrice > 0) {
                orIt.UnitPrice.addError('Price can\'t be more than 0 in trial order');
            }
        }
    }

    public static List<OrderItem> getOrderItems(Set<Id> orderItemsId) {
        return [SELECT Id, Order.Id, OrderItemNumber, UnitPrice, Product2.Name, Order.RecordTypeId FROM OrderItem WHERE Id IN :orderItemsId];
    }



     public static void buildPriceBookMap() {
         for (Pricebook2 pb : [SELECT Id, Name, (SELECT Id, Name, UnitPrice FROM PricebookEntries) FROM Pricebook2]) {
             priceBook2Map.put(pb.Name, pb);
         }
     }

     public static void addPackageProducts(List<Order> orders) {
         List<OrderItem> oi = new List<OrderItem>();
         for (Order ord : orders) {
             Pricebook2 prBook = priceBook2Map.get(getPriceBookEntryName(ord));
             if (ord.ProductPackage__c != null) {
                for(Integer i = 0; i < prBook.PricebookEntries.size(); i++) {
                    OrderItem oItem = new OrderItem();
                    oItem.OrderId = ord.id;
                    oItem.Quantity = 1;
                    oItem.UnitPrice = prBook.PricebookEntries[i].UnitPrice;
                    oItem.PricebookEntryId = prBook.PricebookEntries[i].Id;
                    oi.add(oItem);
                }
            }
         }
         insert oi;
    }

    public static String getPriceBookEntryName(Order ord) {
        String result = '';
        String str = recordTypesByIds.get(ord.RecordTypeId).Name;
        for (Integer i = 0; i < priceBookNames.size(); i++) {
            if (priceBookNames[i].Label.contains(str)) {
                result = priceBook2Map.get(priceBookNames[i].Label).Name;
            }
        }
        return result;

    }
}




