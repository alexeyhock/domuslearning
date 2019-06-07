trigger OrderItemTrigger on OrderItem (after insert) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            OrderPriceBookAssign.checkCorrectOrderItems(Trigger.newMap);
        }
    }

}