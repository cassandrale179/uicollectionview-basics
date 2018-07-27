#import <UIKit/UIKit.h>

/**
 * This class inherits from UICollectionViewCell to style the airing cell.
 */
@interface EPGCollectionViewCell : UICollectionViewCell

/**
 * The thumbnail view for the image of the first airing cell.
 */
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailView;

/**
 * The title within the airing cell.
 */
@property (retain, nonatomic) IBOutlet UILabel *title;

/**
 * The description text within the airing cell.
 */
@property (retain, nonatomic) IBOutlet UILabel *descriptionText;

/**
 * This set up the airing cell title and description text.
 *
 * @param titleText is text title of airing cell
 * @param descriptionText is the text title of the airing cell
 */
-(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText;

/**
 * This set up the thumb nail view for the image of the first airing cell.
 *
 * @param thumbnailView is the image to be displayed
 */
-(void) setThumbnailView:(UIImageView *)thumbnailView;

@end
