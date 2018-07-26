#import "TimeCell.h"

@implementation TimeCell
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.title.textColor = [UIColor blackColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.title];
  }
  return self;
}

- (void) setup: (NSDate *) timeText{
  self.layer.borderWidth = 2.0f;
  self.layer.borderColor = [UIColor blackColor].CGColor;
  self.layer.backgroundColor = [UIColor whiteColor].CGColor;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat: @"HH:mm"];
  self.title.text = [formatter stringFromDate:timeText];
}

@end
