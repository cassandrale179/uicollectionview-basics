#import <UIKit/UIKit.h>

@interface StationCell : UICollectionReusableView
@property (retain, nonatomic) IBOutlet UILabel *title;
-(void) setup: (NSString *) titleText;
@end
