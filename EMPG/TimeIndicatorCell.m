#import "TimeIndicatorCell.h"

@implementation TimeIndicatorCell

// Draw a frame for the red line 
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor redColor];
  }
  return self;
}
@end
