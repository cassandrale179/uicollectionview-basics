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
  EPGRenderer *epg;
  NSString *timeCellIdentifier;
  NSString *timeIndicatorIdentifier;
  NSString *timeIndicatorKind;
  NSString *stationCellIdentifier;
}
- (void) createEPG;
@end

// Implementation of the View Controller
@implementation ViewController

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  // Register class method
  timeIndicatorKind = @"TimeIndicatorView";
  NSString *const HourHeaderView = @"HourHeaderView";
  timeIndicatorIdentifier = NSStringFromClass([timeIndicatorKind class]);
  timeCellIdentifier = NSStringFromClass([TimeCell class]);
  stationCellIdentifier = NSStringFromClass([StationCell class]);

  // Create a view layout
  EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Create an epg object
  [self createEPG];

  // Set Data Source and Delegate and Cell ID
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:viewLayout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];


  // Register Class Method goes here
  [collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  

  [collectionView registerClass:[TimeCell class]
     forSupplementaryViewOfKind: @"HourHeaderView"
            withReuseIdentifier: timeCellIdentifier];
  [collectionView registerClass: [StationCell class]
   forSupplementaryViewOfKind: @"ChannelHeaderView"
            withReuseIdentifier: stationCellIdentifier];
  [collectionView registerClass:[TimeIndicatorCell class] 
      forSupplementaryViewOfKind:timeIndicatorKind 
      withReuseIdentifier:timeIndicatorIdentifier];
  


  // Set background color and disable scrolling diagonally
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


#pragma mark ---------  METHODS FOR SUPPLEMENTARY VIEW ---------
// Dequeue method for time cell
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{

  if ([kind isEqualToString:@"HourHeaderView"]){
    TimeCell *timeCell = [collectionView dequeueReusableSupplementaryViewOfKind: @"HourHeaderView" withReuseIdentifier:timeCellIdentifier forIndexPath:indexPath];
    return timeCell;

  }
  else if ([kind isEqualToString:@"ChannelHeaderView"]){
    StationCell *stationCell  = [collectionView dequeueReusableSupplementaryViewOfKind: @"ChannelHeaderView" withReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];
    return stationCell;
  }
  else if([kind isEqualToString:timeIndicatorKind]){
    TimeIndicatorCell *timeIndicatorCell = [collectionView dequeueReusableSupplementaryViewOfKind:timeIndicatorKind withReuseIdentifier:timeIndicatorIdentifier forIndexPath:indexPath];
    return timeIndicatorCell;
  }
  return 0;

}


#pragma mark --------- CREATE THE EPG ---------
- (void) createEPG{

  // Timestamp generator;
  int timestamp = [[NSDate date] timeIntervalSince1970];
  int from = 900;
  int to = 7200;

  // Create a list of stations
  epg = [[EPGRenderer alloc]init];
  epg.stations = [[NSMutableArray alloc] init];
  NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", @"food", @"hgtv", @"showtime", @"premiere", @"disney",nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d3 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d4 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *d5 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];
  NSArray *d6 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d7 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d8 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d9 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas Charlie Brown", nil];
  NSArray *d10 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];

  // Create a nested array to hold all information
  NSArray *allTitles = [NSArray arrayWithObjects: d1, d2, d3, d4, d5,d6, d7, d8, d9, d10, nil];


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
      NSLocale* currentLocale = [NSLocale currentLocale];
      airing.airingStartTime = [NSDate date];
      airing.airingEndTime = [NSDate dateWithTimeInterval:arc4random() % (to-from+1) sinceDate:airing.airingStartTime];
      [station.airings addObject:airing];
    }

    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
