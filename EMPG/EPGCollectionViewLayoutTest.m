#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "EPGCollectionViewLayout.h"

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
  //
  ViewController *viewController = [[ViewController alloc] init];
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  [viewLayout initWithDelegate:viewController];
  NSLog(@"Datasource %@", viewLayout.dataSource); 
  
  
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
