#import "ViewController.h"
#import "EPGCollectionViewCell.h"
#import "TimeCell.h"
#import "TimeIndicatorCell.h"
#import "StationCell.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

// Interface of the View Controller
@interface ViewController () <UICollectionViewDelegateFlowLayout>{
  UICollectionView *collectionView;
  UICollectionViewFlowLayout *flowLayout;
  NSMutableArray *_timeArray;
  EPGRenderer *epg;
  
  // Identifier and view kind constants
  NSString *timeCellIdentifier;
  NSString *timeIndicatorIdentifier;
  NSString *stationCellIdentifier;
  NSString *timeIndicatorKind;
  NSString *timeCellKind;
  NSString *stationCellKind;
  
}
@end

// Implementation of the View Controller
@implementation ViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  
  // Create an epg object
  epg = [DataModel createEPG];
  _timeArray = [DataModel calculateEPGTime:epg timeInterval:kAiringIntervalMinutes];
  
  // Set Data Source and Delegate and Cell ID
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:viewLayout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];
  
  // Register Class Method goes here
  [collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  [collectionView registerClass:[TimeCell class]
     forSupplementaryViewOfKind: timeCellKind
            withReuseIdentifier: timeCellIdentifier];
  [collectionView registerClass: [StationCell class]
     forSupplementaryViewOfKind: stationCellKind
            withReuseIdentifier: stationCellIdentifier];
  [collectionView registerClass:[TimeIndicatorCell class]
     forSupplementaryViewOfKind:timeIndicatorKind
            withReuseIdentifier:timeIndicatorIdentifier];
  
  // Set background color and disable scrolling diagonally
  self.view = collectionView;
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  collectionView.directionalLockEnabled = true;
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
-(NSInteger *)epgTimeArrayCountForLayout:(EPGCollectionViewLayout *)epgLayout{
  return _timeArray.count;
}

- (NSInteger)epgStationCountForLayout:(EPGCollectionViewLayout *)epgLayout{
  return epg.stations.count;
}

-(NSInteger *)layoutBinarySearchForTime:(EPGCollectionViewLayout *)epgLayout forItemAtIndexPath:(NSIndexPath *)indexPath{
  
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


#pragma mark METHODS FOR SUPPLEMENTARY VIEW
// Dequeue method for time cell, time line cell, and station cell
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
  if ([kind isEqualToString:timeCellKind]){
    TimeCell *timeCell = [collectionView dequeueReusableSupplementaryViewOfKind: timeCellKind withReuseIdentifier:timeCellIdentifier forIndexPath:indexPath];
    [timeCell setup: [_timeArray objectAtIndex: indexPath.item]];
    return timeCell;
  }
  else if ([kind isEqualToString:stationCellKind]){
    StationCell *stationCell  = [collectionView dequeueReusableSupplementaryViewOfKind: stationCellKind withReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];
    [stationCell setup: epg.stations[indexPath.section].stationName];
    return stationCell;
  }
  else if([kind isEqualToString:timeIndicatorKind]){
    TimeIndicatorCell *timeIndicatorCell = [collectionView dequeueReusableSupplementaryViewOfKind:timeIndicatorKind withReuseIdentifier:timeIndicatorIdentifier forIndexPath:indexPath];
    return timeIndicatorCell;
  }
  return 0;
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
