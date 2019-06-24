trigger OrderItemTrigger on OrderItem (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        OrderPriceBookAssign.checkCorrectOrderItems(Trigger.newMap);
    }

}