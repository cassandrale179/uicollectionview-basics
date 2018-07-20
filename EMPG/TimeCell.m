#import "TimeCell.h"

@implementation TimeCell
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.title.textColor = [UIColor blackColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.text = @"here";
    [self addSubview:self.title];
  }
  return self;
}

- (void) setup: (NSString *) titleText{
  self.layer.borderWidth = 2.0f;
  self.layer.borderColor = [UIColor blackColor].CGColor;
  self.title.text = @"here1";
}

@end
