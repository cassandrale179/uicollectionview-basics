#import "FakeViewController.h"
#import "EPGCollectionViewCell.h"
#import "TimeCell.h"
#import "TimeIndicatorCell.h"
#import "StationCell.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

// Interface of Fake View Controller
@interface FakeViewController(){
  UICollectionView *collectionView;
  NSMutableArray *_timeArray;
  EPGRenderer *epg;
  EPGRenderer *epg2;

  // Identifier and view kind constants
  NSString *timeCellIdentifier;
  NSString *timeIndicatorIdentifier;
  NSString *stationCellIdentifier;
  NSString *timeIndicatorKind;
  NSString *timeCellKind;
  NSString *stationCellKind;
}
@end

// Implementation of Fake View Controller
@implementation FakeViewController
- (void)setUpFake {

  // Intialize view kind here
  timeIndicatorKind = @"TimeIndicatorView";
  timeCellKind = @"HourHeaderView";
  stationCellKind = @"ChannelHeaderView";

  // Initialize class identifier
  timeIndicatorIdentifier = NSStringFromClass([timeIndicatorKind class]);
  timeCellIdentifier = NSStringFromClass([TimeCell class]);
  stationCellIdentifier = NSStringFromClass([StationCell class]);

  // Create a view layout
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:self];
  epg = [self createEPG];
  _timeArray = [DataModel calculateEPGTime:epg timeInterval:kAiringIntervalMinutes];
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"HH:mm:ss"];
  NSDate *startTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  //connect the collectionView with the layout
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:viewLayout];
  [viewLayout prepareLayout];
}

#pragma mark EPGDataSourceDelegate

-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath{
  //item-1 to account for the first video cell
  return epg.stations[indexPath.section].airings[indexPath.item-1].airingStartTime;
}
-(NSDate *)layoutStartTimeForEPG:(EPGCollectionViewLayout *)epgLayout{
  return _timeArray[0];
}
-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout EndTimeForItemAtIndexPath:(NSIndexPath *)indexPath{

  //item-1 to account for the first video cell
  return epg.stations[indexPath.section].airings[indexPath.item-1].airingEndTime;
}
-(NSUInteger)epgTimeArrayCountForLayout:(EPGCollectionViewLayout *)epgLayout{
  return _timeArray.count;
}

- (NSInteger)epgStationCountForLayout:(EPGCollectionViewLayout *)epgLayout{
  return epg.stations.count;
}

-(NSInteger)layoutBinarySearchForTime:(EPGCollectionViewLayout *)epgLayout forItemAtIndexPath:(NSIndexPath *)indexPath{

  // Subtract 1 to account for the thumbnail cell at item index 0.
  NSDate *currentAiringStartTime = epg.stations[indexPath.section].airings[indexPath.item-1].airingStartTime;

  // For first airing cell in case the show started before the first time in the time header cells.
  NSDate *closerStartTime = _timeArray[0];
  if ([closerStartTime earlierDate:currentAiringStartTime]) {
    closerStartTime = currentAiringStartTime;
  }
  NSInteger closestTimeIndex =
  [_timeArray indexOfObject:closerStartTime
              inSortedRange:NSMakeRange(0, _timeArray.count)
                    options:NSBinarySearchingInsertionIndex
            usingComparator:^NSComparisonResult(NSDate *time1, NSDate *time2) {
              return [time1 compare:time2];
            }];
  closestTimeIndex -= 1;
  return closestTimeIndex;
}

-(NSTimeInterval)layoutTimeIntervalBeforeAiring:(EPGCollectionViewLayout *)epgLayout withClosestTimeIndex:(NSInteger)closestTimeIndex withAiringStartTime:(NSDate *)startTime{
  return [startTime timeIntervalSinceDate:_timeArray[closestTimeIndex]];
}

#pragma mark UICollectionDataSource

// Return how many rows within UI Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  NSInteger row = [epg.stations count];
  return row;
}


// Return how many columns within UI Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  NSInteger column = [epg.stations[section].airings count];
  //add one to accomodate the first video thumbnail cell
  return column+1;
}


// For each cell in the index path, put information inside the cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];
  //set the content of each cell
  if(indexPath.item!=0){
    [cell setup:epg.stations[indexPath.section].airings[indexPath.item-1].airingTitle withDescription:@"sampledescription"];
  }else{
    [cell setup:@"video" withDescription:@"sampledescription"];
  }
  return cell;
}

// Create fake data that satisfy our test cases
-(EPGRenderer *)createEPG {
  EPGRenderer *epg = [[EPGRenderer alloc] init];

  // Create a list of stations
  NSMutableArray *epgStations = [[NSMutableArray alloc] init];
  NSArray *stationTitle =
  [NSArray arrayWithObjects:@"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", @"food", @"hgtv",
   @"showtime", @"premiere", @"disney", nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects:@"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *times1 = [NSArray arrayWithObjects:@"7:30-9:30", @"9:30-10:00", @"10:15-10:30", nil];
  NSArray *d2 = [NSArray arrayWithObjects:@"East TN South vs Furman", @"Postgame",
                 @"The Late Show with Stephen Colbert", nil];
  NSArray *times2 = [NSArray arrayWithObjects:@"9:00-9:45", @"9:45-10:00", @"10:00-12:00", nil];
  NSArray *d3 =
  [NSArray arrayWithObjects:@"The Gong Show", @"ShortShow", @"Battle of Network Stars", nil];
  NSArray *times3 = [NSArray arrayWithObjects:@"9:00-9:55", @"9:55-10:00", @"10:00-12:00", nil];
  NSArray *d4 =
  [NSArray arrayWithObjects:@"Scandal", @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *times4 = [NSArray arrayWithObjects:@"9:00-9:30", @"9:30-12:00", nil];
  NSArray *d5 = [NSArray arrayWithObjects:@"The Kind Of Queens", @"Two And A Half Man",
                 @"Howdie Mandel All-Star Comedy Gala", nil];
  NSArray *times5 = [NSArray arrayWithObjects:@"9:00-9:30", @"9:30-10:00", @"10:00-12:00", nil];
  NSArray *d6 = [NSArray arrayWithObjects:@"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *times6 = [NSArray arrayWithObjects:@"9:00-9:15", @"9:30-10:00", @"10:00-12:00", nil];
  NSArray *d7 = [NSArray arrayWithObjects:@"East TN South vs Furman", @"Postgame",
                 @"The Late Show with Stephen Colbert", nil];
  NSArray *times7 = [NSArray arrayWithObjects:@"9:00-9:45", @"9:45-10:00", @"10:00-12:00", nil];
  NSArray *d8 =
  [NSArray arrayWithObjects:@"The Gong Show", @"ShortShow", @"Battle of Network Stars", nil];
  NSArray *times8 = [NSArray arrayWithObjects:@"9:00-9:55", @"9:55-10:00", @"10:00-12:00", nil];
  NSArray *d9 =
  [NSArray arrayWithObjects:@"Scandal", @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *times9 = [NSArray arrayWithObjects:@"9:00-9:30", @"9:30-12:00", nil];
  NSArray *d10 = [NSArray arrayWithObjects:@"The Kind Of Queens", @"Two And A Half Man",
                  @"Howdie Mandel All-Star Comedy Gala", nil];
  NSArray *times10 = [NSArray arrayWithObjects:@"9:00-9:30", @"9:30-10:00", @"10:00-12:00", nil];

  // Create a nested array to hold all information
  NSArray *allTitles = [NSArray arrayWithObjects:d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, nil];
  NSArray *allTimes = [NSArray arrayWithObjects:times1, times2, times3, times4, times5, times6,
                       times7, times8, times9, times10, nil];

  // Create an array of stations for one epg s
  for (int i = 0; i < [stationTitle count]; i++) {
    StationRenderer *station = [[StationRenderer alloc] init];
    NSMutableArray *stationAirings = [[NSMutableArray alloc] init];

    // Create dummy variables for now
    NSArray *currentTitle = allTitles[i];
    NSArray *currentTime = allTimes[i];
    // Create an array of airings for each station
    for (int j = 0; j < [currentTitle count]; j++) {
      AiringRenderer *airing = [[AiringRenderer alloc] init];
      [airing setAiringTitle:currentTitle[j]];
      [airing addTimes:currentTime[j] forAiring:airing];
      [stationAirings addObject:airing];
    }
    [station setStationName:stationTitle[i]];
    [station setAirings:stationAirings];
    [epgStations addObject:station];
  }
  [epg setStations:epgStations];
  return epg;
}

@end
