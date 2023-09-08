trigger TriggerOnPB on Pricebook2 (before insert, before update, after update) {
    system.debug('debug log generated');
}