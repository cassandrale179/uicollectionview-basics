## Creating an Objective C Collection View Programmatically
This guide is to create an Objective C UICollectionView programmatically (without Storyboard or xib files). <br>
This is a log for future documentation purpose. 


## Table of Contents 
#### A. Create the cell for the collectionview
**1. Create the actual custom Cell class**:
- Airing cells display different showings playing at different times. <br> 
- To create custom cells, first create a separate class inheriting from UICollectionViewCell. 
- This class includes the  basic frame design for each airing cell with regards to background color, border width, text (title and description) etc. 
- To use this cell within the collectionView, in the ViewController, registered it as a custom cell
```objective-c
[collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
```
**2. Use the custom Cell class in your CollectionView**:
- CollectionView uses cell identifier to find cell type to display using cellForItemAtIndexPath method. 
- CellForItemAtIndexPath: returns the visible cell object at the specified index path. 
- The cell identifier must match identifier used for register in viewDidLoad (ViewController)  
```objective-c
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];
  return cell;
}
```
**3. Customize each cell content**:
- ViewController inherits from the UICollectionViewDataSource, so add any content for collectionView cells here. 
- Setup method in custom cell class will take in the title and description text to modify each individual cell. 
```objective-c
[cell setup:epg.stations[indexPath.section].airings[indexPath.item-1].airingTitle withDescription:@"sampledescription"];
```
#### B. Create the flow layout for the collection view
**1. Show Cells on the Screen** 
In conjunction with the setting up of the bounds in prepareLayout (detailed in the scrollable section below), display only items that are currently on the visible screen frame. 
```objective-c
for(NSIndexPath *indexPath in cellAttrDict){
    UICollectionViewLayoutAttributes *attributes = [cellAttrDict objectForKey:indexPath];
    if(CGRectIntersectsRect(rect, attributes.frame)){
      [attributesInRect addObject:attributes];
    }
  }
```
**2. Inform the CollectionViewLayout what cells are at the current IndexPath** 
```objective-c
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  return [cellAttrDict objectForKey:indexPath];
}
```
#### C. Add the flow layout to the view controller <br>
When the View first loads, create the custom ViewLayout Instance and connect it to CollectionView: 
```objective-c
 EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
  collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:viewLayout];
```
#### D. Create supplementary view for the time and station cell  
There will be 3 types of cell (the airing cell, the time cell, and the station cell) 
- For station cell (StationCell.h) and time cell (TimeCell.h) create a class and method files associated with it 
- E.g, implementation for the station cell: 
```objective-c
if (self) {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    self.descriptionText.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.thumbnailView];
  }
  
  // Setup method 
  -(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText {
  self.layer.borderWidth = 2.0f;
  self.title.text = titleText;
  self.title.frame = CGRectMake(10, 10, self.layer.frame.size.width-(2*xPadding), 30);
}
``` 

**Modify the flow layout to cusotmize the cell (EPGCollectionViewLayout.m):** <br>
- Create the index path for the station / time cell (e.g in this case, we are creating 9 cells for time): 
```objective-c
- (NSArray *)indexPathsOfHourHeaderViewsInRect:(CGRect)rect
{
  NSInteger minHourIndex = 0;
  NSInteger maxHourIndex = 9;
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minHourIndex; idx <= maxHourIndex; idx++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}
```

- Draw the coordinate and position of each cell: <br> 
For the hour cell, we want the left boundary of the entire cell header to start after the thumbnail, so the frame will be first shift by the width of the station cell column, then the thumbnail cell size (paddingSize). The y coordinate is 0 because we want the cell header to be at the top. 

```objective-c
if ([kind isEqualToString:@"HourHeaderView"]) {
    CGFloat widthPerHalfHour = CELL_WIDTH;
    CGFloat paddingSize = ThumbnailSize*CELL_WIDTH;
    attributes.frame = CGRectMake(ChannelHeaderWidth + paddingSize + (widthPerHalfHour * indexPath.item), 0, widthPerHalfHour, HourHeaderHeight);
  }
```


- Within the method layoutAttributesForElementsInRect, create 2 supplementary views for time/station: 
```objective-c
  NSArray *hourHeaderViewIndexPaths = [self indexPathsOfHourHeaderViewsInRect:rect];
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"HourHeaderView" atIndexPath:indexPath];
    [attributesInRect addObject:attributes];
  }
``` 


- For station cell, we want to make it stick to the left when we are scrolling horizontally:
```objective-c
    CGPoint const contentOffset = self.collectionView.contentOffset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
      CGPoint origin = attributes.frame.origin;
      origin.x = contentOffset.x;       // change the x-coordinate of the cell to the x-coordinnate of the view 
      attributes.zIndex = 1024;
      attributes.frame = (CGRect){
        .origin = origin,
        .size = attributes.frame.size
      };
    }
```

#### E. Add the supplementary view in the View Controller 
- Create some constants in which the view kind is what specified in the EPGCollectionViewLayOut.m and the identifier is the name of the class we have created (e.g TimeCell.h): 
```objective-c
timeCellIdentifier = NSStringFromClass([TimeCell class]);
timeCellKind = @"HourHeaderView"; 
```

 - Register the class for the cell:
 ``` objective-c
 [collectionView registerClass:[TimeCell class] forSupplementaryViewOfKind: timeCellKind
           withReuseIdentifier: timeCellIdentifier];
  ``` 
  
  - Implement dequeue method:
  ``` objective-c
  - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
      if ([kind isEqualToString:timeCellKind]){
    TimeCell *timeCell = [collectionView dequeueReusableSupplementaryViewOfKind: timeCellKind
      withReuseIdentifier:timeCellIdentifier forIndexPath:indexPath];
    [timeCell setup: [NSString stringWithFormat:@"%ld:00 PM", indexPath.item]];
    return timeCell;
  }
 ```
#### F. Create supplementary view for the Time Indicator line  
**1. Create a custom TimeIndicator Class**  
- This supplementary view will inherit from UICollectionReusableView and scroll with the collectionView (airing cells). 
- It is one 2px wide cell that is red (the size will be allocated in the ViewLayout as the attribute frame).
``` objective-c
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor redColor];
  }
  return self;
}
```
**2. Specify Attributes for Time Indicator Cell(Line) in the Layouts** 
- The size of the 2px wide cell will be specified as an attribute in the ViewLayouts layoutAttributesforSupplementaryViewOfKind. 
- To determine the x-position of the current Time Indicator Line:
  - Let timeAtFront = the most recent time in a set time interval that the tv guide shows
  - Distance of the currentTimeIndicatorLine will be proportional to the length of time between the current time and the timeAtFront
   - Multiply by a standard cell width (ex. if time interval is 30 min, then standard cell width is 400px) to get the relative x position of the timeIndicatorLine on the collectionView
   - To span the line across collectionView across all of the channels: let its starting y-position be the top of the screen and ending y-position be at the bottom of the collectionView. 
```objective-c
else if([kind isEqualToString:timeIndicatorKind]){
    CGFloat cellStandardWidth = 400;
    NSDate *timeAtFront = [NSDate date];
    CGFloat currentTimeMarker = [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront]/(60*30.)*cellStandardWidth;
    CGFloat topOfIndicator = 20;
    attributes.frame = CGRectMake(currentTimeMarker, topOfIndicator, 2, contentSize.height);
  }
```
**3. Register the TimeIndicatorCell Line in the ViewController** 
```objective-c
[collectionView registerClass:[TimeIndicatorCell class]
     forSupplementaryViewOfKind:timeIndicatorKind
            withReuseIdentifier:timeIndicatorIdentifier];
```
**4. Ensure it is properly called in the viewForSupplementaryElementOfKind method** 
```objective-c
else if([kind isEqualToString:timeIndicatorKind]){
    TimeIndicatorCell *timeIndicatorCell = [collectionView dequeueReusableSupplementaryViewOfKind:timeIndicatorKind withReuseIdentifier:timeIndicatorIdentifier forIndexPath:indexPath];
    return timeIndicatorCell;
  }
```
#### G. Making the CollectionView Scrollable in both directions (Emily)
**1. In the CollectionViewLayout prepareLayout method calculate the frame of each cell** 
```objective-c
for(int section = 0; section<self.collectionView.numberOfSections; section++){
      if([self.collectionView numberOfItemsInSection:section] > 0){
        CGFloat xPos = ChannelHeaderWidth;
        CGFloat yPos = yPadding+section*CELL_HEIGHT+borderPadding*section;

        // Calculate the frame of each airing
        for (int item = 0; item<[self.collectionView numberOfItemsInSection:section]; item++){
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          CGFloat multFactor;
          UICollectionViewLayoutAttributes *attr;

          
            multFactor= [epg.stations[section].airings[item-1].airingEndTime timeIntervalSinceDate:epg.stations[section].airings[item-1].airingStartTime]/(timeInterval * 60.);
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
         
          attr.frame = CGRectMake(xPos, yPos, multFactor*CELL_WIDTH, CELL_HEIGHT);
          xPos += multFactor*CELL_WIDTH;
          [cellAttrDict setValue:attr forKey:cellIndex];
        }
        xMax = MAX(xMax, xPos);
      }

```
**2. Set the content size of the CollectionView**
- Make the contentSize of the CollectionView equal to the height and width of entire collectionView
- This enables scrolling in both direction since the CollectionView's width and height are bigger than the visible screen's  width and height respectively
- Modify the contentSize at the end of the prepareLayout method: 
```objective-c
CGFloat contentWidth = xMax;
      CGFloat contentHeight = [self.collectionView numberOfSections]*(CELL_HEIGHT+borderPadding)+yPadding;
      contentSize = CGSizeMake(contentWidth, contentHeight);
```
- Return the calculated content size in the collectionViewContentSize method in viewLayout:
```objective-c
 - (CGSize)collectionViewContentSize{
  return contentSize;
} 
```
**3. Force the prepareLayout method to be called for each screen rotation** 
- Recalculate the bounds of the attribute frames for each cell depending on the new screen orientation. 
- Returning yes to this method ensures that prepareLayout will be called everytime the device is rotated
```objective-c
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
  return YES;
}
```

**4. Enable scrolling only in ONE direction AT A TIME**: 
Set bidirectionallock in the viewcontroller to true to so that the view can't be scrolled diagonally: 
``` objective-c
collectionView.directionalLockEnabled = true;
```
#### H. Making the video thumbnail cell
**1. Modify the Attribute Frame of each cell to accommodate the video cell**: 
- Since the video cell will always be the first cell column in the TV guide, allocate a space for the video cell in prepareLayout -- when creating the bounds for all the airing cells -- everytime the indexpath.item is 0. 
```objective-c
for (int item = 0; item<[self.collectionView numberOfItemsInSection:section]; item++){
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          CGFloat multFactor;
          UICollectionViewLayoutAttributes *attr;

          // If the cell is not a thumbnail
          if(item!=0){
            multFactor= [epg.stations[section].airings[item-1].airingEndTime timeIntervalSinceDate:epg.stations[section].airings[item-1].airingStartTime]/(timeInterval * 60.);
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }else{
            //some random constant for the size of the thumbnail
            multFactor = ThumbnailSize;
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }

          attr.frame = CGRectMake(xPos, yPos, multFactor*CELL_WIDTH, CELL_HEIGHT);
          xPos += multFactor*CELL_WIDTH;
          [cellAttrDict setValue:attr forKey:cellIndex];
        }
        xMax = MAX(xMax, xPos);
      }
 ```
 **2. Modify the cellForIndexAtItemPath in the ViewController to accommodate the video cell** 
 - The video cell will always be at indexpath.item==0

 ```objective-c
 - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];

  //set the content of each cell
  if(indexPath.item!=0){
    [cell setup:epg.stations[indexPath.section].airings[indexPath.item-1].airingTitle withDescription:@"sampledescription"];
  }else{
    [cell setup:@"video" withDescription:@"sampledescription"];
  }
  return cell;
}
```


## Resources
- **Create an UI Collection View**: https://www.objc.io/issues/3-views/collection-view-layouts/
