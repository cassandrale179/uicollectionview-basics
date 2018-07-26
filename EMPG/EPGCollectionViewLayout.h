
#import <UIKit/UIKit.h>

@interface EPGCollectionViewLayout : UICollectionViewFlowLayout
extern CGFloat const kVerticalPadding = 50;
extern CGFloat const kBorderPadding = 30;
- (NSArray *)indexPathsOfChannelHeaderViews;
@end
