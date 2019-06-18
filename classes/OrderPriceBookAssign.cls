public without sharing class OrderPriceBookAssign {

    public static Boolean isFirstTime = true;

    public static Map<Id, RecordType> recordTypesByIds = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType]);

    public static List<PriceBookName__mdt> priceBooksName = [SELECT Label FROM PriceBookName__mdt];

    public static Map<String, Pricebook2> priceBook2Map = new Map<String, Pricebook2>();

    public static Map<String, PricebookEntry> priceBookEntriesMap = new Map<String, PricebookEntry>();

    //public static Map<Id, PricebookEntry> priceBookEntriesMap2 = new Map<Id, PricebookEntry>([SELECT Id, Name, UnitPrice FROM PricebookEntry]);

    public static Map<Id, List<ProductPackageItem__c>> productPackageItemMap = new Map<Id, List<ProductPackageItem__c>>();




    //Fill Maps
    public static void buildPriceBook2Map() {
        for (Pricebook2 pb : [SELECT Id, Name, (SELECT Id, Name, UnitPrice FROM PricebookEntries) FROM Pricebook2]) {
            priceBook2Map.put(pb.Name, pb);
        }
    }

    public static void buildPriceBookEntriesMap() {
        for (PricebookEntry pbe : [SELECT Id, Name, UnitPrice FROM PricebookEntry]) {
            priceBookEntriesMap.put(pbe.Name, pbe);
        }
    }

    public static void buildProductPackageItemMap(List<Id> prodPackagesId) {
        for (ProductPackage__c pp: [SELECT id, Name, (SELECT Id, Name, Product__c FROM Product_Package_Items__r) FROM ProductPackage__c WHERE Id IN :prodPackagesId]) {
            productPackageItemMap.put(pp.Id, pp.Product_Package_Items__r);
        }
    }

    public static void assignPriceBookToOrder(List<Order> orders) {
        for (Order ord : orders) {
            ord.Pricebook2Id = getPriceBookId(recordTypesByIds.get(ord.RecordTypeId));
        }
    }

    public static Id getPriceBookId(RecordType orderRecordType) {
        buildPriceBook2Map();
        if(orderRecordType == null) return null;
        for (Integer i = 0; i < priceBooksName.size(); i++) {
            if (priceBooksName[i].Label.contains(orderRecordType.Name)) {
                return  priceBook2Map.get(priceBooksName[i].Label).Id;
            }
        }
        return null;
    }

    public static void checkCorrectOrderItems(Map<Id, OrderItem> mapOrderItem) {
        List<OrderItem> orderItems = getOrderItems(mapOrderItem.keySet());
        for (OrderItem orIt : orderItems) {
            if (recordTypesByIds.get(orIt.Order.RecordTypeId).Name == 'Trial' && orIt.UnitPrice > 0) {
                orIt.UnitPrice.addError('Price can\'t be more than 0 in trial order');
            }
        }
    }

    public static List<OrderItem> getOrderItems(Set<Id> orderItemsId) {
        return [SELECT Id, Order.Id, OrderItemNumber, UnitPrice, Product2.Name, Order.RecordTypeId FROM OrderItem WHERE Id IN :orderItemsId];
    }

    public static void addPackageProducts(List<Order> orders) {
        buildPriceBookEntriesMap();
        buildProductPackageItemMap(getListProductPackageIds(orders));
        System.debug('ppItems ==> ' + productPackageItemMap);
        List<OrderItem> oi = new List<OrderItem>();
        for (Order ord : orders) {
            List<ProductPackageItem__c> pp = productPackageItemMap.get(ord.ProductPackage__c);
            System.debug('pp ==> ' + pp);
            if (ord.ProductPackage__c != null && pp != null) {
                for(Integer i = 0; i < pp.size(); i++) {
                    PricebookEntry pbe = priceBookEntriesMap.get(pp[i].Name);
                    System.debug('pbe ==> ' + pbe);
                    OrderItem oItem = new OrderItem();
                    oItem.OrderId = ord.id;
                    oItem.Quantity = 1;
                    oItem.UnitPrice = pbe.UnitPrice;
                    oItem.PricebookEntryId = pbe.Id;
                    oi.add(oItem);
                }
            }
        }
        insert oi;
    }

    public static List<Id> getListProductPackageIds(List<Order> ords) {
        List<Id> listProductPackageId = new List<Id>();
        for (Order ord : ords) {
            listProductPackageId.add(ord.ProductPackage__c);
        }
        return listProductPackageId;
    }

}




