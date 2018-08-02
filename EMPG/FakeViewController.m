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
}


@end
