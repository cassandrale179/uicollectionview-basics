#import <UIKit/UIKit.h>
/**
 * This class creates the cell for the hour header view 
 */
@interface TimeCell : UICollectionReusableView
/**
 * The title displayed in the time cell of hour header view
 */
@property (retain, nonatomic) IBOutlet UILabel *title;
/**
 * This set the label for the hour header view cell
 * @param timeText is the label for the hour header view (e.g 9:00 PM)
 */
-(void) setup: (NSString *) timeText;
@end
