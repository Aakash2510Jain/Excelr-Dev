trigger TriggerOnPBE on PricebookEntryChangeEvent (after insert) {
    system.debug('debug log generated');
}