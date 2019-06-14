trigger OrderTrigger on Order (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        OrderPriceBookAssign.assignPriceBookToOrder(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        if (OrderPriceBookAssign.isFirstTime) {
            OrderPriceBookAssign.isFirstTime = false;
            OrderPriceBookAssign.addPackageProducts(Trigger.new);
        }
    }
}

//    list<Orderitem> lineitems = new list<Orderitem>();
//    for (Order o : trigger.new){
//        if(o.Service_Type__c == 'Postpaid')
//        {
//            Orderitem oitem = new Orderitem();
//            oitem.OrderId = o.id;
//            oitem.Quantity = 1;
//            oitem.UnitPrice = 200;
//            oitem.PricebookEntryId = ?????
//                    lineitems.add(oitem);
//        }
//        insert lineitems;
//    }

}