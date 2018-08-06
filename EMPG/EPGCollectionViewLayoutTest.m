#import <XCTest/XCTest.h>
#import "FakeViewController.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

@interface EPGCollectionViewLayoutTest : XCTestCase

@end

@implementation EPGCollectionViewLayoutTest
//constants from layout
static const CGFloat kHalfHourWidth = 400;
static const CGFloat kChannelHeaderWidth = 100;   // width of each channel cell
static const CGFloat kThumbnailSize = 0.5;        // size of the video thumbnail
static const CGFloat xPadding = kThumbnailSize*kHalfHourWidth;


- (void)testStartingPositionOfAiringCells{
  //Set up the data model
  FakeViewController *viewController = [[FakeViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:viewController];
  [viewController setUpFake];
  [viewLayout prepareLayout];
  
  //TODO: if the firstTime is before (more than 30 min) the airing cell
  
  //if the start position is within 30 of the firstTime (ex. @"7:40-9:45", firstTime: "7:30")
  NSIndexPath *currentCellIndex = [NSIndexPath indexPathForItem:1 inSection:1];
  AiringRenderer *currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:currentCellIndex];
  CGFloat startXPosition = [viewLayout startingXPositionForAiring:currentAiringStartTime withIndexPath:currentCellIndex];
  XCTAssertEqualWithAccuracy(startXPosition, kChannelHeaderWidth+kThumbnailSize*kHalfHourWidth+(kHalfHourWidth/3), 1);
  
  //if the startTime is the firstTime (ex. @"7:30-9:30", firstTime: "7:30")
  currentCellIndex = [NSIndexPath indexPathForItem:1 inSection:0];
  currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:currentCellIndex];
  startXPosition = [viewLayout startingXPositionForAiring:currentAiringStartTime withIndexPath:currentCellIndex];
  XCTAssertEqualWithAccuracy(startXPosition, kChannelHeaderWidth+kThumbnailSize*kHalfHourWidth, 1);
}
-(void)testAiringCellWidthByDuration{
  //Set up the data model
  FakeViewController *viewController = [[FakeViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:viewController];
  [viewController setUpFake];
  
  //if the cell duration is equal to 30 min (ex. @"9:30-10:00")
  AiringRenderer *currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
  AiringRenderer *currentAiringEndTime = [viewLayout.dataSource layout:viewLayout EndTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
  XCTAssertEqual([viewLayout numOfHalfHourIntervals:currentAiringStartTime withEndTime:currentAiringEndTime], 1);
  
  //if the cell duration is less than 30 min (ex. @"10:15-10:30")
  currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
  currentAiringEndTime = [viewLayout.dataSource layout:viewLayout EndTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
  XCTAssertEqual([viewLayout numOfHalfHourIntervals:currentAiringStartTime withEndTime:currentAiringEndTime], 0.5);
  
  //if the cell duration is greater than 30 min (ex. @"7:30-9:30")
  currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  currentAiringEndTime = [viewLayout.dataSource layout:viewLayout EndTimeForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
  XCTAssertEqual([viewLayout numOfHalfHourIntervals:currentAiringStartTime withEndTime:currentAiringEndTime], 4);
  
  //if the cell duration is greater than 30 min but the Airing start time is before the first Time
 // XCTAssertEqual([viewLayout numOfHalfHourIntervals:currentAiringStartTime withEndTime:currentAiringEndTime], );
}
-(void)testSupplementaryView{

  // Set up methods to get a fake time array for testing purpose.
  FakeViewController *fakeViewController = [[FakeViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:fakeViewController];
  [fakeViewController setUpFake];
  [viewLayout prepareLayout];
  NSMutableArray *fakeTimeArray = [fakeViewController valueForKey:@"_timeArray"];
  
  // Make sure time array is not null
  XCTAssertFalse(fakeTimeArray == nil, @"The array should not be null");

  //Test if the time interval between the time array is 30 minutes.
  for (int i = 0; i < fakeTimeArray.count-1; i++){
    NSDate *firstTime = fakeTimeArray[i];
    NSDate *secondTime = fakeTimeArray[i+1];
    NSTimeInterval secondsBetween = [secondTime timeIntervalSinceDate:firstTime];
    int minutes = secondsBetween / 60;
    XCTAssertEqual(minutes, 30);
  }

  // Test if there are correct number of header time cells
  NSDate *firstTime = fakeTimeArray[0];
  NSDate *lastTime = [fakeTimeArray lastObject];
  NSTimeInterval secondsBetween = [lastTime timeIntervalSinceDate:firstTime];
  int totalTimeIntervals = (secondsBetween / 60) / 30 + 1;
  XCTAssertEqual([fakeTimeArray count], totalTimeIntervals);
  
  
  // Test if the formatting start time is accurate
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"MM/dd/yyyy HH:mm";
  NSString *str1 = @"3/15/2012 18:13";
  NSString *str2 = @"3/15/2012 10:53";
  NSDate *date1 = [formatter dateFromString:str1];
  NSDate *date2 = [formatter dateFromString:str2];
  NSDate *fdate1 = [DataModel formatTime:date1];
  NSDate *fdate2 = [DataModel formatTime:date2];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components1 = [calendar components:(NSCalendarUnitMinute) fromDate:fdate1];
  NSDateComponents *components2 = [calendar components:(NSCalendarUnitMinute) fromDate:fdate2];
  NSInteger minute1 = [components1 minute];
  NSInteger minute2 = [components2 minute];
  XCTAssertEqual(minute1, 0);
  XCTAssertEqual(minute2, 30);

  
  // Test if the header time cell y-coordinate position is above airing cells
  NSMutableDictionary *fakeHourAttributes = [viewLayout valueForKey:@"_hourAttributes"];
  NSLog(@"fake hour attribuet %@", fakeHourAttributes);
  
  
  



  //  Test if the station time cell x-coordinate is to the left of airing cells

}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
