public with sharing class FileUtilities {

    @AuraEnabled
    public static String createFile(String base64Data, String fileName,String relatedRecordId){

    

        try {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = EncodingUtil.base64Decode(d64);
            contentVersion.Title = fName;
            contentVersion.PathOnClient = fName;
            insert contentVersion;

            contentVersion = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersion.Id
                WITH USER_MODE
            ];

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = rId;
            contentDocumentLink.ShareType = 'V';
            insert contentDocumentLink;

            return contentDocumentLink.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating file: ' + e);
        }
    }

    public static void createChildCase(Id parentCaseId){

        Case parentCase = [SELECT Id, Subject, CaseNumber, AccountId, ContactId FROM Case WHERE Id = :parentCaseId];
        List<Asset> assets = [SELECT Product2Id FROM Asset WHERE Case__c = :parentCaseId];

        Case childCase = new Case();
        childCase.Subject = 'Follow up from ' + parentCase.CaseNumber;
        childCase.AccountId = parentCase.AccountId;
        childCase.ContactId = parentCase.ContactId;
        childCase.ParentId = parentCaseId;
        childCase.Origin = 'Phone';
        childCase.Status = 'New';
   
        insert childCase;   

        List<Asset> newAssets = new List<Asset>();
        for (Asset asset : assets) {
            Asset newAsset = new Asset();
            newAsset.Product2Id = asset.Product2Id;
            newAsset.Case__c = childCase.Id;
            newAssets.add(newAsset);
        }
   
        insert newAssets;    
        
    }

    public static void createChildCase(Id parentCaseId){

        Case caseWithAssets = CaseSelector.getCaseWithAssets(parentCaseId);

        Case childCase = cloneCase(caseWithAssets);
        insert childCase;

        List<Asset> newAssets = new List<Asset>();
        for (Asset asset : caseWithAssets.Assets) {
            Asset newAsset = cloneAsset(asset, childCase.Id);
            newAssets.add(newAsset);
        }

        insert newAssets;
    }

    public static void createUpsellOpportunity(Id originalOpptyId){

        Opportunity originalOppty = getOpptyDetails(originalOpptyId);

        Opportunity upsellOppty = copyOpptyDetails(originalOppty);

        try {
            insert upsellOppty;
        } catch (Exception e) {
            Logger.log('Upsell Opportunity Creation Error', e.getMessage());
        }

        List<OpportunityLineItem> originalOpptyLineItems = getOpptyLineItems(originalOpptyId);

        List<OpportunityLineItem> upsellOpptyLineItems = new List<OpportunityLineItem>();

        for (OpportunityLineItem oli : originalOpptyLineItems) {
            OpportunityLineItem newOli = copyLineItemDetails(oli);
            upsellOpptyLineItems.add(newOli);
        }

        try {
            insert upsellOpptyLineItems;
        } catch (Exception e) {
            Logger.log('Opportunity Linte Item Creation Error', e.getMessage());
        }
        
    }

    @IsTest
    static void testCloneCase() {

        Case originalCase = new Case();
        originalCase.Subject = 'Test Case';
        originalCase.AccountId = DataFactory.createAccount().Id;
        originalCase.ContactId = DataFactory.createContact().Id;
        originalCase.Origin = 'Phone';
        originalCase.Status = 'New';
        insert originalCase;

        Test.startTest();
        Case childCase = cloneCase(originalCase.Id);
        Test.stopTest();

        System.Assert.areEqual(originalCase.Subject, childCase.Subject+ ' Follow up');
        System.Assert.areEqual(originalCase.AccountId, childCase.AccountId);
        System.Assert.areEqual(originalCase.ContactId, childCase.ContactId);
        System.Assert.areEqual(originalCase.Origin, 'Phone');
        System.Assert.areEqual(originalCase.Status, 'New');
        System.Assert.areEqual(originalCase.Id, childCase.ParentId);


    }


}