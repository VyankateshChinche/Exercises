global with sharing class OSF_OpportunitySummarizeScheduler implements schedulable {
    global void execute(SchedulableContext sc) {
        OSF_OpportunitySummarizeBatchClass b = new OSF_OpportunitySummarizeBatchClass ();
        database.executebatch(b);
    } 
}