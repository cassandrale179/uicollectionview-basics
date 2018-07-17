#import "EPGRenderer.h"


int main(int argc, const char * argv[]){
 
  
  // Get current month and date
  NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"MM"];
  NSInteger month = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
  [dateFormatter setDateFormat:@"dd"];
  NSInteger day = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
  
  // A very sad way to create date time
  NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
  [dateComponents setYear:2018];
  [dateComponents setMonth:month];
  [dateComponents setDay:day];
  [dateComponents setHour:21];
  
  
  int timestamp = [[NSDate date] timeIntervalSince1970];
  NSLog(@"timestamp %d", timestamp);
  
  
  


  EPGRenderer *stationsArray = [[EPGRenderer alloc]init];

  // Create all airings on fox
//  StationRenderer *fox = [[StationRenderer alloc] init];
//  NSArray *foxTitle = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
//  double foxStartTime[] = {timestamp, timestamp + 23, timestamp + 34};
//  double foxEndTime[] = {timestamp+30, timestamp + 53, timestamp + 63};
//  NSLog(@"gahhh %@", fox.airings);
//
//
//  for (int i = 0; i < sizeof foxTitle; i++){
//    AiringRenderer *airing = [[AiringRenderer alloc] init];
//    airing.airingTitle = foxTitle[i];
//    airing.airingStartTime = foxStartTime[i];
//    airing.airingEndTime = foxEndTime[i];
//
//  }
//
//
//
//
//  AiringRenderer *movie1 = [[AiringRenderer alloc] init];
//  movie1.airingTitle = @"New Girl";
//  movie1.airingStartTime
  
}
  
  
  
 
