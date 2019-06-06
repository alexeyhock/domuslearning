trigger OrderTrigger on Order (before insert, before update) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            OrderPriceBookAsign.HandlerBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            OrderPriceBookAsign.HandlerBeforeUpdate(Trigger.new);
        }
    }

}