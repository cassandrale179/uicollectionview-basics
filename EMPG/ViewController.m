
#import "ViewController.h"
#import "EPGCollectionViewCell.h"
#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

@interface ViewController (){
  UICollectionView *collectionView;
  NSArray *fakeDescrip;
  NSArray *allTitles;
  NSInteger sectionCount;
}
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  sectionCount = 0;
  //[self.view setBackgroundColor:[UIColor whiteColor]];
  //self.view.backgroundColor = [UIColor whiteColor];


  // Do any additional setup after loading the view, typically from a nib.
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Set titles and description for the movies

  // Create a list of stations
  EPGRenderer *epg = [[EPGRenderer alloc]init];
  epg.stations = [[NSMutableArray alloc] init];
  NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", nil];

  // Create a list of arrays to fil out the information
  NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d3 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d4 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *d5 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];
  allTitles = [NSArray arrayWithObjects: d1, d2, d3, d4, d5, nil];

  fakeDescrip = @[@"D1", @"D2", @"D3", @"D4"];

  // Set Data Source and Delegate and Cell ID
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];
  [collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  [self.view addSubview:collectionView];
}

// Return how many rows within UI Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  NSInteger row = allTitles.count;
  return row;
}


// Return how many collumns within UI Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  NSInteger column = [allTitles[section] count];
  return column;
}


// For each cell in the index path, put information inside the cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];

   // Set the title text and description
  NSArray *station = allTitles[indexPath.section];
  cell.title.text = station[indexPath.item];
  cell.descriptionText.text = @"hi";

  // Set up the cell
  [cell setup:station[indexPath.item] withDescription:fakeDescrip[indexPath.item]];

  return cell;
}


// Set the size of the cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
  return CGSizeMake(200, 100);
}


// Set padding between the cell
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
  return UIEdgeInsetsMake(30, 0, 20, 0);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end

//  NSLog(@"the title itself %@, the title put on %@", fakeTitles[indexPath.item], cell.title.text);
//  NSLog(@"In the View: new x: %f with title: %@", cell.title.frame.origin.x, cell.title.text);
//[cell.layer]
//  [cell.title setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y,70,30)];
//  [cell.contentView addSubview:cell.title];
//NSLog(@"this is the title %f", cell.frame.origin.x);
//  NSLog(@"this is the title %f", cell.frame.origin.x);

  // Set the title text and description
  //  cell.title.text = fakeTitles[indexPath.item];
  //  cell.descriptionText.text = fakeDescrip[indexPath.item];
