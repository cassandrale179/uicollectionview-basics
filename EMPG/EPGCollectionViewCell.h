
#import <UIKit/UIKit.h>

@interface EPGCollectionViewCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *descriptionText;
-(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText;
-(void) setThumbnailView:(UIImageView *)thumbnailView;
@end
