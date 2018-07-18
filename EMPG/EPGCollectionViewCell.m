
#import "EPGCollectionViewCell.h"

@implementation EPGCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.thumbnailView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.title];
    self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
  }
  return self;
}

-(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText {
  //self.backgroundColor = [UIColor blueColor];
  self.layer.borderWidth = 2.0f;
  self.layer.borderColor = [UIColor blackColor].CGColor;
  // NSLog(@"This is the new x: %f", self.frame.origin.x);
  [self.title setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,70,30)];
  self.title.text = @"title";
  [self.contentView addSubview:self.title];
  
 // [self.title setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,70,30)];
  
  
  // self.description.text = descriptionText;
}
-(void) setThumbnailView:(UIImageView *)thumbnailView{
  self.thumbnailView.image = thumbnailView;
}
@end
