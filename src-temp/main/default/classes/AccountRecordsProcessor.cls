public with sharing class AccountRecordsProcessor {
    
    public static void processAfterModification(Map<Id, Account> nAccts, Map<Id, Account> oAccts) {

        Set<Id> idsList = new Set<Id>();
       
        for (Account nAcct : nAccts.values()) {
            Account oAcct = oAccts.get(nAcct.Id);

            if (nAcct.MailingAddress != oAcct.MailingAddress) {
                idsList.add(nAcct.Id);
            }
        }

        if(!idsList.isEmpty()) {
            List<Contact> cons = [SELECT Id, AccountId, MailingAddress FROM Contact WHERE AccountId IN :idsList];
            for(Contact con : cons) {
                con.MailingAddress = nAccts.get(con.AccountId).MailingAddress;
            }
            update cons;
        }
    }

}