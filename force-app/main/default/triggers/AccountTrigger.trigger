trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // The Domain handles the complexity. 
    new AccountDomain().run();
}