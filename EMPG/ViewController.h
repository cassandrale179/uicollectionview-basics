#import <UIKit/UIKit.h>

/**
 * View controller class update the contents of the views in response changes in data
 */
@protocol EPGDataSource;
@interface ViewController : UIViewController <EPGDataSource, UICollectionViewDelegate,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout>
@end
