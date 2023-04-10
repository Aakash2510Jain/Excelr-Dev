public without sharing class ChatBot_CreateLeads {
   /* @InvocableMethod(label='Create Lead')
    public static List<string> getProductlist(List<TranscriptInput> transcripts){
        
        system.debug('transcripts--'+transcripts);
        List<string> transcriptIdList = New List<string>();
        string transcriptId;
        string productName;
        for(TranscriptInput transcript:transcripts){
            transcriptIdList.add(string.valueOf(transcript.routableID));
            transcriptId = string.valueOf(transcript.routableID);
            productName = string.valueOf(transcript.selectedCourse);
        }
        system.debug('transcriptId--'+transcriptId);
        system.debug('productName--'+productName);
        list<LiveChatTranscript> chatTrscriptList = [select name,id,First_Name__c,Last_Name__c,Email__c from LiveChatTranscript where Id IN:transcriptIdList];
        system.debug('chatTrscriptList---'+chatTrscriptList);
        List<Lead> leadsToInsert = New List<Lead>();
        for(LiveChatTranscript chatTrscript:chatTrscriptList){
            Lead lead = New Lead(FirstName=chatTrscript.First_Name__c,LastName=chatTrscript.Last_Name__c,Email=chatTrscript.Email__c,Status='Open',Company='None',Enquired_Course__c=productName);
            leadsToInsert.add(lead);
        }
        system.debug('leadsToInsert--'+leadsToInsert);
        if(leadsToInsert.size() > 0)
        	insert leadsToInsert;
        Return New List<string>{string.valueOf(lead.Name)};
    }  
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
        @InvocableVariable(required=true)
        public string selectedCourse;
    }*/
}