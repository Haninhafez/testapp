class TimeHelper {

   String getCurrentTime(DateTime? timenow) {
     DateTime time = timenow ?? DateTime.now();
   if(time.hour >=0 && time.hour < 12){
     return "Good Morning";
   }
   else if(time.hour >=12 && time.hour < 18){
     return "Good Afternoon";
   }
   else{
     return "Good Evening";
   }
  }
}