/*******************************************************************************
* @Name         : OSF_OpportunitySummarizeScheduler
* @Description  : Schedule job for daily at 10:00 AM, once a week (Friday at 1:00 PM), once a month(Last Friday of the Month at 6:00 PM).
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
*                                                       
*******************************************************************************/
global with sharing class OSF_OpportunitySummarizeScheduler implements schedulable {
/*******************************************************************************
* @Name         : execute
* @Description  : Schedule Job
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
*******************************************************************************/
    global void execute(SchedulableContext sc) {
        OSF_OpportunitySummarizeBatchClass b = new OSF_OpportunitySummarizeBatchClass ();
        database.executebatch(b);
    } 
}