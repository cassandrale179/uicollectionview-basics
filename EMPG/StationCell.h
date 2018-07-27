#import <UIKit/UIKit.h>

/**
 * A UICollectionReusableView representing a tv station.
 */
@interface StationCell : UICollectionReusableView

/**
 * The title displayed in the station cell
 */
@property(retain, nonatomic) IBOutlet UILabel *title;

/**
 * This set up the title displayed in the station cell.
 *
 * @param titleText is the name of the channel network 
 */
- (void)setup:(NSString *)titleText;
@end
