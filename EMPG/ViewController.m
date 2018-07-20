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
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  collectionView.directionalLockEnabled = true;
  [self.view addSubview:collectionView];
  //time indicator layer
  CAShapeLayer *currentTimeIndicator = [self drawCurrentTime];
  [self.view.layer addSublayer:currentTimeIndicator];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
  TimeCell *timeCell = [collectionView dequeueReusableSupplementaryViewOfKind: @"HourHeaderView" withReuseIdentifier:timeCellIdentifier forIndexPath:indexPath];
  return timeCell;
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark --------- TimeIndicatorLine ---------

-(CAShapeLayer *) drawCurrentTime{
  UIBezierPath *path = [UIBezierPath bezierPath];
  NSDate *timeAtFront = [NSDate date];
  
  // will in future replace [timeAtFront dateByAddingTimeInterval:1500] w [NSDate date] for currentTime
  // divide by seconds*timeIntervalInMinutes
  CGFloat cellStandardWidth = 400;
  CGFloat currentTimeMarker = [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront]/(60*30.)*cellStandardWidth;
  CGFloat topOfIndicator = 20;
  [path moveToPoint:CGPointMake(currentTimeMarker, topOfIndicator)];
  [path addLineToPoint:CGPointMake(currentTimeMarker, self.view.layer.frame.size.height)];
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.path = [path CGPath];
  shapeLayer.strokeColor = [[UIColor redColor] CGColor];
  shapeLayer.lineWidth = 3.0;
  shapeLayer.fillColor = [[UIColor clearColor] CGColor];
  return shapeLayer;
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
@end
