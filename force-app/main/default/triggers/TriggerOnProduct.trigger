trigger TriggerOnProduct on Product2 (before insert, before update, after update) {
    system.debug('debug log generated');
}