trigger OrderTrigger on Order (before insert) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            OrderPriceBookAssign.assignPriceBookToOrder(Trigger.new);
        }
    }

}