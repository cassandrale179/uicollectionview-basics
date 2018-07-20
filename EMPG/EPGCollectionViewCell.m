
#import "EPGCollectionViewCell.h"

@implementation EPGCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.title.textColor = [UIColor blackColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.descriptionText = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 30)];
    self.descriptionText.textColor = [UIColor blackColor];
    self.descriptionText.textAlignment = NSTextAlignmentCenter;
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.thumbnailView];
    
    [self.contentView addSubview:self.descriptionText];
    //self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
  }
  return self;
}

-(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText {
  //self.backgroundColor = [UIColor blueColor];
  //NSLog(@"This is the width: %f", self.layer.frame.size.width);
  //  self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
  //  self.title.textColor = [UIColor blackColor];
  //  self.title.textAlignment = NSTextAlignmentCenter;
  self.layer.borderWidth = 2.0f;
  self.layer.borderColor = [UIColor blackColor].CGColor;
  self.title.text = titleText;
  self.descriptionText.text = descriptionText;
  //NSLog(@"This is the new x: %f with title: %@", self.frame.origin.x, self.title.text);
  //[self.contentView addSubview:self.title];
  
  // [self.title setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,70,30)];
  
  
  // self.description.text = descriptionText;
}
-(void) setThumbnailView:(UIImageView *)thumbnailView{
  self.thumbnailView.image = thumbnailView;
}
@end
