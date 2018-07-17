
#import "ViewController.h"

@interface ViewController (){
  UICollectionView *collectionView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
  [collectionView setDataSource:self];
  [collectionView setDelegate: self];
  [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
  [collectionView setBackgroundColor:[UIColor whiteColor]];
  [self.view addSubview:collectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath ];
  cell.backgroundColor = [UIColor blueColor];
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
