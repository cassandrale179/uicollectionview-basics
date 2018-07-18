
#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
  @autoreleasepool {

    //timestamp
    int timestamp = [[NSDate date] timeIntervalSince1970];

    // Create a list of stations
    EPGRenderer *epg = [[EPGRenderer alloc]init];
    epg.stations = [[NSMutableArray alloc] init];
    NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", nil];


    // Create two dimensional array to fil out the information
    NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
    NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
    NSArray *d3 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
    NSArray *d4 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
    NSArray *d5 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];


    // Create an array of stations for one epg s
    for (int i = 0; i < [stationTitle count]; i++){

        StationRenderer *station = [[StationRenderer alloc] init];
        station.airings = [[NSMutableArray alloc] init];

        // Create dummy variables for now
        NSArray *dummyTitle = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
        double dummyStartTime[] = {timestamp, timestamp + 23, timestamp + 34};
        double dummyEndTime[] = {timestamp+30, timestamp + 53, timestamp + 63};

        // Create an array of airings for each station
        for (int j = 0; j < [dummyTitle count]; j++){
          AiringRenderer *airing = [[AiringRenderer alloc] init];
          airing.airingTitle = dummyTitle[j];
          airing.airingStartTime = dummyStartTime[j];
          airing.airingEndTime = dummyEndTime[j];
          [station.airings addObject:airing];
        }

        station.stationName = stationTitle[i];
        [epg.stations addObject:station];
      }

      NSLog(@"epg %@", epg);
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
