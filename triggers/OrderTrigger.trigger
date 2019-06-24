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