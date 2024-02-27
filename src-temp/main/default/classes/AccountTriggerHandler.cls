public with sharing class AccountTriggerHandler {
    
    public static void afterUpdate(Map<Id,Account> oldAccounts, List<Account> newAccounts) {

        Set<Id> accountIdsWithNewAddress = new Set<Id>();
       
        for (Account newAccount : newAccounts.values()) {

            Boolean addressHasChanged = oldAccounts.get(newAccount.Id).MailingAddress != newAccount.MailingAddress;

            if (addressHasChanged) {
                accountIdsWithNewAddress.add(nAcct.Id);
            }
        }

        if(!accountIdsWithNewAddress.isEmpty()) {

            List<Contact> relatedContacts = [SELECT Id, AccountId, MailingAddress FROM Contact WHERE AccountId IN :idsList];

            for(Contact contact : relatedContacts) {
                contact.MailingAddress = newAccounts.get(contact.AccountId).MailingAddress;
            }
            update relatedContacts;
        }
    }

}