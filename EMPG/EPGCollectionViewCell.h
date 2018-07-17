
#import <UIKit/UIKit.h>

@interface EPGCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *description;
-(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText;
-(void) setThumbnailView:(UIImageView *)thumbnailView;
@end
