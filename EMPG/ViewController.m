
#import "ViewController.h"
#import "EPGCollectionViewCell.h"
#import "EPGCollectionViewLayout.h"

@interface ViewController (){
  UICollectionView *collectionView;
  NSArray *fakeTitles;
  NSArray *fakeDescrip;
}
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  fakeTitles = @[@"Title1", @"Title2", @"Title3"];
  fakeDescrip = @[@"D1", @"D2", @"D3"];
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];
  [collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  [self.view addSubview:collectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return fakeTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath ];
  
  // [cell.contentView addSubview:cell.title];
  [cell setup:fakeTitles[indexPath.item] withDescription:fakeDescrip[indexPath.item]];
  cell.title.textColor = [UIColor blackColor];
  cell.title.text = fakeTitles[indexPath.item];
  //[cell.layer]
//  [cell.title setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y,70,30)];
//  [cell.contentView addSubview:cell.title];
  NSLog(@"this is the title %f", cell.frame.origin.x);
  NSLog(@"this is the title %f", cell.frame.origin.x);
  
  
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
  return CGSizeMake(100, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
  return UIEdgeInsetsMake(30, 0, 20, 0);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
