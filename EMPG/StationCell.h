#import <UIKit/UIKit.h>
/**
 * A UICollectionReusableView representing a tv station.
 */
@interface StationCell : UICollectionReusableView
@property(retain, nonatomic) IBOutlet UILabel *title;
/**
 * The title displayed in the station cell.
 */
- (void)setup:(NSString *)titleText;
@end
