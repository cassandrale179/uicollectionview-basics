#import <UIKit/UIKit.h>

/**
 * View controller class update the contents of the views in response changes in data
 */
@protocol EPGDataSourceDelegate;
@interface ViewController : UIViewController <EPGDataSourceDelegate, UICollectionViewDelegate,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout>
@end
