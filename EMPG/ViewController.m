#import "ViewController.h"
#import "EPGCollectionViewCell.h"
#import "TimeCell.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"


// Interface of the View Controller
@interface ViewController () <UICollectionViewDelegateFlowLayout>{
  UICollectionView *collectionView;
  UICollectionViewFlowLayout *flowLayout;
  NSArray *fakeDescrip;
  EPGRenderer *epg;
  NSString *timeCellIdentifier;
}

- (void) createEPG;
@end

// Implementation of the View Controller
@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];


  // Register class method

  NSString *const HourHeaderView = @"HourHeaderView";
  timeCellIdentifier = NSStringFromClass([TimeCell class]);
  // Create a view layout
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


  // Create an epg object
  [self createEPG];

  fakeDescrip = @[@"D1", @"D2", @"D3", @"D4"];

  // Set Data Source and Delegate and Cell ID
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:viewLayout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];
  [collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  [collectionView registerClass:[TimeCell class]
     forSupplementaryViewOfKind: HourHeaderView
            withReuseIdentifier: timeCellIdentifier];
  //[collectionView registerNib:[TimeCell class] forSupplementaryViewOfKind:HourHeaderView withReuseIdentifier:timeCellIdentifier];
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  collectionView.directionalLockEnabled = true;
  [self.view addSubview:collectionView];
}

#pragma mark --------- HEADER METHOD ---------
// Set a size for the header file first
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
  return CGSizeMake(60.0f, 60.0f);
}


#pragma mark ---------  CREATING THE CELL ---------
// Return how many rows within UI Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  NSInteger row = [epg.stations count];
  return row;
}


// Return how many columns within UI Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  NSInteger column = [epg.stations[section].airings count];
  return column;
}


// For each cell in the index path, put information inside the cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];

  // Set the title text and description
  StationRenderer* station =  epg.stations[indexPath.section];
  AiringRenderer* airing = station.airings[indexPath.item];
  cell.title.text =  airing.airingTitle;
  cell.descriptionText.text = @"hi";


  // Set up the cell
  // [cell setup:station[indexPath.item] withDescription:fakeDescrip[indexPath.item]];

  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
  TimeCell *timeCell = [collectionView dequeueReusableSupplementaryViewOfKind: @"HourHeaderView" withReuseIdentifier:timeCellIdentifier forIndexPath:indexPath];
  //timeCell.title.text = @"here2";
  return timeCell;
}

// Set the size of the cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
  return CGSizeMake(200, 100);
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


#pragma mark --------- CREATE THE EPG ---------
- (void) createEPG{

  // Timestamp generator;
  int timestamp = [[NSDate date] timeIntervalSince1970];
  int from = 900;
  int to = 36000;

  // Create a list of stations
  epg = [[EPGRenderer alloc]init];
  epg.stations = [[NSMutableArray alloc] init];
  NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d3 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d4 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *d5 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];

  // Create a nested array to hold all information
  NSArray *allTitles = [NSArray arrayWithObjects: d1, d2, d3, d4, d5, nil];


  // Create an array of stations for one epg s
  for (int i = 0; i < [stationTitle count]; i++){

    StationRenderer *station = [[StationRenderer alloc] init];
    station.airings = [[NSMutableArray alloc] init];

    // Create dummy variables for now
    NSArray *dummyTitle = allTitles[i];

    // Create an array of airings for each station
    for (int j = 0; j < [dummyTitle count]; j++){
      AiringRenderer *airing = [[AiringRenderer alloc] init];
      airing.airingTitle = dummyTitle[j];
      airing.airingStartTime = timestamp;
      airing.airingEndTime =  timestamp + (int)from + arc4random() % (to-from+1);
      [station.airings addObject:airing];
    }

    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}
@end

// Set padding between the cell
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//  return UIEdgeInsetsMake(30, 0, 20, 0);
//}
