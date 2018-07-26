#import "DataModel.h"
@implementation EPGRenderer
@synthesize stations = _stations;
- (void)setStations:(NSMutableArray<StationRenderer *> *)stationsArray {
  _stations = stationsArray;
}
@end

@implementation StationRenderer
@synthesize airings = _airings;
@synthesize stationName = _stationName;
- (void)setAirings:(NSMutableArray<StationRenderer *> *)airingsArray {
  _airings = airingsArray;
}
- (void)setStationName:(NSString *)stationNameValue {
  _stationName = stationNameValue;
}
@end

// Implementation for Airing Renderer
@implementation AiringRenderer
@synthesize airingTitle = _airingTitle;
@synthesize airingStartTime = _airingStartTime;
@synthesize airingEndTime = _airingEndTime;
- (void)setAiringTitle:(NSString *)titleValue {
  _airingTitle = titleValue;
}
- (void)setAiringStartTime:(NSDate *)startTimeValue {
  _airingStartTime = startTimeValue;
}
- (void)setAiringEndTime:(NSDate *)endTimeValue {
  _airingEndTime = endTimeValue;
}
@end

@implementation DataModel
// Create the sample data to be used in deciding the size for the layout methods
+ (EPGRenderer *)createEPG {
  EPGRenderer *epg = [[EPGRenderer alloc] init];
  // Timestamp generator
  int from = 900;
  int to = 7200;

  // Create a list of stations
  //  epg.stations = [[NSMutableArray alloc] init];
  NSMutableArray *epgStations = [[NSMutableArray alloc] init];
  NSArray *stationTitle =
      [NSArray arrayWithObjects:@"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", @"food", @"hgtv",
                                @"showtime", @"premiere", @"disney", nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects:@"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects:@"East TN South vs Furman", @"Postgame",
                                          @"The Late Show with Stephen Colbert", nil];
  NSArray *d3 = [NSArray arrayWithObjects:@"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d4 = [NSArray arrayWithObjects:@"I Want A Dog For Christmas, Charlie Brown",
                                          @"episode 2", @"episode 3", nil];
  NSArray *d5 =
      [NSArray arrayWithObjects:@"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];
  NSArray *d6 = [NSArray arrayWithObjects:@"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d7 = [NSArray arrayWithObjects:@"East TN South vs Furman", @"Postgame",
                                          @"The Late Show with Stephen Colbert", nil];
  NSArray *d8 = [NSArray arrayWithObjects:@"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d9 = [NSArray arrayWithObjects:@"I Want A Dog For Christmas, Charlie Brown",
                                          @"episode 2", @"episode 3", nil];
  NSArray *d10 =
      [NSArray arrayWithObjects:@"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];

  // Create a nested array to hold all information
  NSArray *allTitles = [NSArray arrayWithObjects:d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, nil];

  // Create an array of stations for one epg s
  for (int i = 0; i < [stationTitle count]; i++) {
    StationRenderer *station = [[StationRenderer alloc] init];
    NSMutableArray *stationAirings = [[NSMutableArray alloc] init];

    // Create dummy variables for now
    NSArray *currentTitle = allTitles[i];

    // Create an array of airings for each station
    for (int j = 0; j < [currentTitle count]; j++) {
      AiringRenderer *airing = [[AiringRenderer alloc] init];
      [airing setAiringTitle:currentTitle[j]];
      [airing setAiringStartTime:[NSDate date]];
      [airing setAiringEndTime:[NSDate dateWithTimeInterval:(arc4random() % (to - from + 1))
                                                  sinceDate:airing.airingStartTime]];
      [stationAirings addObject:airing];
    }
    [station setStationName:stationTitle[i]];
    [station setAirings:stationAirings];
    [epgStations addObject:station];
  }
  [epg setStations:epgStations];
  return epg;
}

// Dynamic calculate start and end time of the UICollectionView
+ (NSMutableArray *)calculateEPGTime:(EPGRenderer *)epgObject{
  NSMutableArray *timeArray = [[NSMutableArray alloc] init];
  
  // Create an array of all airings
  NSMutableArray *allAirings = [[NSMutableArray alloc] init];
  for (StationRenderer* station in epgObject.stations){
    for (AiringRenderer *airing in station.airings){
      [allAirings addObject:airing];
    }
  }
  
  // Sort all airing array to find start time and end time
  NSSortDescriptor *startTimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"airingStartTime" ascending:YES];
  NSSortDescriptor *endTimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"airingEndTime" ascending:NO];
  NSArray *sortedStartTimeArray = [allAirings sortedArrayUsingDescriptors:@[startTimeDescriptor]];
  NSArray *sortedEndTimeArray = [allAirings sortedArrayUsingDescriptors:@[endTimeDescriptor]];
  NSDate *epgStartTime = ((AiringRenderer*)[sortedStartTimeArray objectAtIndex:0]).airingStartTime;
  NSDate *epgEndTime = ((AiringRenderer *)[sortedEndTimeArray objectAtIndex:0]).airingEndTime;
  NSDate *formatStartTime = [self formatTime: epgStartTime];
  NSDate *formatEndTime = [self formatTime:epgEndTime];
  
  // Build an array of time intervals
  NSDate *interval = formatStartTime;
  while (interval < formatEndTime){
    interval = [interval dateByAddingTimeInterval:1800];
    [timeArray addObject:interval];
  }
  return timeArray;
}


// Formatted start time and end time
+ (NSDate *)formatTime:(NSDate *)dateToFormat{
  NSDateFormatter *formatter = [NSDateFormatter new];
  [formatter setDateFormat:@"mm"];
  NSString *timeString = [formatter stringFromDate:dateToFormat];
  int minutes = [timeString intValue];
  if (minutes < 30){
    minutes = 0;
  }
  else{
    minutes = 30;
  }
  
  // Modify the NSDate component
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *comps = [calendar components:(
    NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
    fromDate:dateToFormat];
  comps.minute = minutes;
  NSDate *newDate = [calendar dateFromComponents:comps];
  return newDate;
}
@end
