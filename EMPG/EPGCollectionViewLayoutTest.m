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
