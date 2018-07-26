#import <UIKit/UIKit.h>

@interface TimeCell : UICollectionReusableView
@property (retain, nonatomic) IBOutlet UILabel *title;
-(void) setup: (NSString *) timeText;
@end
