public class JSC_EmailToCallCenter
{   
  @AuraEnabled(Cacheable=true)
  public static void sendEmail(String jsonStringEmailbody)
  {
      List<String> callCenterEmailId = new List<String>();
      String subject = '';
      String emailbody='';
      Map<String,Object> emailDataMap = new Map<String,Object >();
        
    try
    {
      
        if(String.isNotBlank(jsonStringEmailbody)){
           emailDataMap =  (Map<String,Object >)JSON.deserializeUntyped (jsonStringEmailbody);
        }
 
        JSC_EmailFieldInfoService service = (JSC_EmailFieldInfoService)
          JSC_Application.Service.newInstance(JSC_EmailFieldInfoService.class);
 
       List<JSC_GenesysEmailTemplate__mdt> emailFields = service.getEmailFieldInfo();
        
      if(!emailDataMap.isEmpty() && !emailFields.isEmpty()){
            for(JSC_GenesysEmailTemplate__mdt emailField : emailFields){
              String v1 = '= <<< <br/> ';
                if(emailField.Sequence__c == 0){
                  subject = emailField.Value__c;
                }else if(emailField.Sequence__c == -1){
                  callCenterEmailId = new String[] {emailField.Value__c};
                }else if(emailDataMap.containsKey(emailField.MasterLabel)){
                   emailbody = emailbody + '>>>' + emailField.Value__c +'=' + emailDataMap.get(emailField.MasterLabel) + v1;
                }else if(emailField.Sequence__c != 0 && emailField.Sequence__c != -1){
                   emailbody = emailbody + '>>>' +emailField.Value__c+v1;  
                }
            }
        }
 
      
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setToAddresses(callCenterEmailId);
       mail.setSubject(subject);
       mail.setHtmlBody(emailbody);
        
       fflib_ISObjectUnitOfWork  uow = JSC_Application.UnitOfWork.newInstance();
       uow.registerEmail(mail);
       uow.commitWork();
        
    }
    catch(Exception e)
    {
      throw new AuraHandledException(e.getMessage());
    }
  }
  
 }
