#import <XCTest/XCTest.h>
#import "FakeViewController.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

@interface EPGCollectionViewLayoutTest : XCTestCase

@end

@implementation EPGCollectionViewLayoutTest

- (void)testStartingPositionOfAiringCells{
  //if the firstTime is before (more than 30 min) the airing cell
  //if the firstTime is more recent than the first airing cell startTime
  //if the start position is within 30 of the firstTime
  //if the startTime is the firstTime
}
-(void)testAiringCellWidthByDuration{
  //if the cell duration is equal to 30 min
  //if the cell duration is less than 30 min
  //if the cell duration is greater than 30 min
  //if the cell duration is greater than 30 min but the first Time is after the startTime
}
-(void)testSupplementaryView{
  
  // Set up methods to get a fake time array for testing purpose.
  FakeViewController *fakeViewController = [[FakeViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:fakeViewController];
  [fakeViewController viewDidLoad];
  NSMutableArray *fakeTimeArray = [fakeViewController valueForKey:@"_timeArray"];
  
  
  // Test if the time interval between the time array is 30 minutes.
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
  
  /*#import <XCTest/XCTest.h>
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
  
  //TODO: if the firstTime is before (more than 30 min) the airing cell
  
  //if the firstTime is more recent than the first airing cell startTime(ex. @"9:30-10:00", firstTime: "7:30")
  NSIndexPath *currentCellIndex = [NSIndexPath indexPathForItem:2 inSection:0];
   AiringRenderer *currentAiringStartTime = [viewLayout.dataSource layout:viewLayout startTimeForItemAtIndexPath:currentCellIndex];
  CGFloat startXPosition = [viewLayout startingXPositionForAiring:currentAiringStartTime withIndexPath:currentCellIndex];
  XCTAssertEqual(startXPosition, kChannelHeaderWidth+kHalfHourWidth*(4));
  //if the start position is within 30 of the firstTime
  //if the startTime is the firstTime
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
  XCTAssertEqual([viewLayout numOfHalfHourIntervals:currentAiringStartTime withEndTime:currentAiringEndTime], 3);
}
-(void)testSupplementaryView{
  
  // Set up methods to get a fake time array for testing purpose.
  FakeViewController *fakeViewController = [[FakeViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:fakeViewController];
  [fakeViewController setUpFake];
  NSMutableArray *fakeTimeArray = [fakeViewController valueForKey:@"_timeArray"];
  
  
  // Test if the time interval between the time array is 30 minutes.
  for (int i = 0; i < fakeTimeArray.count-1; i++){
    NSDate *firstTime = fakeTimeArray[i];
    NSDate *secondTime = fakeTimeArray[i+1];
    NSTimeInterval secondsBetween = [secondTime timeIntervalSinceDate:firstTime];
    int minutes = secondsBetween / 60;
    XCTAssertEqual(minutes, 30);
  }
  
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
*/
