## Creating an Objective C Collection View Programmatically
This guide is to create an Objective C UICollectionView programmatically (without Storyboard or xib files). <br>
This is a log for future documentation purpose. 


## Table of Contents 
**1. Create an EPG object**<br>
- A. Structure of an EPG <br>
- B. Implementation of an EPG in Objective C class <br>
- C. Method to create an EPG object <br>

**2. Creating UICollectionView** <br>
- A. Create the cell for the collectionview  <br>
- B. Create the flow layout for the collection view  <br>
- C. Add the cell and flow layout to the view controller  <br>
- D. Create supplementary view for the time and station cell  <br>
- E. Add supplementary view to the view controller  <br>
- F. Create supplementary view for the time indicator line  <br> 
- G. Making the CollectionView Scrollable in both directions  <br>
- H. Making the video thumbnail cell  <br> 


## Steps By Steps Instruction 
### 1. Create an EPG object 
 ##### A. Structure of an EPG object:
 An EPG is a menu is displayed that lists current and upcoming television programs on all available channels.  <br>
 The structure of an EPG will look like follow: 

    epg/
    ├── FOX                      
      ├── Airing1
        ├── start-time                      
        ├── end-time                                          
        ├── description        
        ├── title   
      ├── Airing2  
        ├── start-time                      
        ├── end-time                                           
        ├── description        
        ├── title                        
    ├── CNN    
      ├── Airing1
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
        ├── description        
        ├── title 
        ... 

#### B. The creationg of an EPG object (DataModel.h) files:    
   
 ```objective-c
// Each airing object is a TV show / movie 

@interface AiringRenderer : NSObject
@property (nonatomic, readwrite) NSString *airingTitle;;
@property (nonatomic, readwrite) NSDate *airingStartTime;
@property (nonatomic, readwrite) NSDate *airingEndTime;
@property (nonatomic, readwrite) NSString *airingDescription;
@end


// Each station contain an array of airings 
@interface StationRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray <AiringRenderer*> *airings;
@property (nonatomic, readwrite) NSString* stationName;
@property (nonatomic, readwrite) UIImage* stationLogo;
@end


// Each epg object contain an array of stations 
@interface EPGRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray<StationRenderer *> *stations;
@property (nonatomic, readwrite) long epgStartTime;
@property (nonatomic, readwrite) long epgEndTime;
@end
``` 

#### C. Implement a method to initialize / create an EPG object: 
We create a double for loop to fill the content of the station cell, then put each station cell within an EPG object, then fill the content of each airing renderer cell, then put it in the station renderer object. 
```objective-c
- (void) createEPG{

  // Timestamp generator;
  int timestamp = [[NSDate date] timeIntervalSince1970];
  int from = 900;
  int to = 7200;

  // Create a list of stations
  epg = [[EPGRenderer alloc]init];
  epg.stations = [[NSMutableArray alloc] init];
  NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", @"food", @"hgtv", @"showtime", @"premiere", @"disney",nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  .... 
  NSArray *d10 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];


  // Create an array of stations for one epg 
  for (int i = 0; i < [stationTitle count]; i++){

    StationRenderer *station = [[StationRenderer alloc] init];
    station.airings = [[NSMutableArray alloc] init];

    // Create dummy variables for now
    NSArray *dummyTitle = allTitles[i];

    // Create an array of airings for each station
    for (int j = 0; j < [dummyTitle count]; j++){
      AiringRenderer *airing = [[AiringRenderer alloc] init];
      airing.airingTitle = dummyTitle[j];
      airing.airingStartTime = [NSDate date];
      airing.airingEndTime = [NSDate dateWithTimeInterval:arc4random() % (to-from+1) sinceDate:airing.airingStartTime];
      [station.airings addObject:airing];
    }

    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}
```


### 2. Create An UICollectionView
#### A. Create the cell for the collectionview
**1. Create the actual custom Cell class **:
The basis of the UICollectionView will be the airing cells that show the various different showings playing at different times. 
To create the basis of these custom cells, first create a separate class inheriting from UICollectionViewCell. This is the class that will include the 
basic frame design for each airing cell with regards to background color, border width, text (title and description) etc. 
To be able to use the cell within the collectionView, in the ViewController, these the custom cell must be registered as a custom cell
```objective-c
[collectionView registerClass:[EPGCollectionViewCell class] forCellWithReuseIdentifier:@"epgCell"];
```
The cell identifier will be used later when the collectionView is trying to find what kind of cell it needs to display with the cellForItemAtIndexPath method.
**2. Use the custom Cell class in your CollectionView**:
To actually ensure that the custom cell is being displayed in the collectionView, the cellForItemAtIndexPath: method needs to call on the custom cell we just made:
```objective-c
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  EPGCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"epgCell" forIndexPath:indexPath];
  return cell;
}
```
The cell identifier must match the identifier used to register the cells above in the viewDidLoad method for the viewcontroller. 
**3. Customize each cell content **:
Since the ViewController the CollectionView is implemented in also inherits from the UICollectionViewDataSource, this is also the file where 
any content that needs to be added to the collectionView cells needs to be added.
```objective-c
[cell setup:epg.stations[indexPath.section].airings[indexPath.item-1].airingTitle withDescription:@"sampledescription"];
```
For organization purposes, a setup method was created in the custom Cell class that will take in the title and description text to 
modify each individual cell.

#### B. Create the flow layout for the collection view
**1. Show Cells on the Screen
In conjunction with the setting up of the bounds in prepareLayout (detailed in the scrollable section below), display only items that are currently on the visible screen frame. 
```objective-c
for(NSIndexPath *indexPath in cellAttrDict){
    UICollectionViewLayoutAttributes *attributes = [cellAttrDict objectForKey:indexPath];
    if(CGRectIntersectsRect(rect, attributes.frame)){
      [attributesInRect addObject:attributes];
    }
  }
```
**2. Inform the CollectionViewLayout what cells are at the current IndexPath
```objective-c
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  return [cellAttrDict objectForKey:indexPath];
}
```
#### C. Add the flow layout to the view controller (Emily) <br>
When the View first loads, create the custom ViewLayout Instance
```objective-c
 EPGCollectionViewLayout *viewLayout = [[EPGCollectionViewLayout alloc] init];
 ```
Connect it as the custom layout to the CollectionView
```objective-c
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
#### F. Create supplementary view for the time indicator line (Emily)
**1. Create a custom TimeIndicator Class 
This supplementary view will be inheriting from the UICollectionReusableView as a supplementary view that moves with the collectionView. 
Since we want the time Indicator to be a line of the current time, it is essentially going to be a 2px wide cell that is red.
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
**2. Specify Attributes for Time Indicator Cell(Line) in the Layouts
The size of the 2px wide cell will be specified as an attribute in the ViewLayouts layoutAttributesforSupplementaryViewOfKind. To determine the x-position of the current Time Indicator Line:
- let timeAtFront be the most recent time in a set time interval that the tv guide shows
- distance of the currentTimeIndicatorLine will be proportional to the length of time between the current time and the timeAtFront
- multiply by a standard cell width(ex. if the set time interval is 30 min, then maybe the standard cell width for 30 min is 400px) to get the relative x position of the timeIndicatorLine on the collectionView
To make this line span the entire collectionView across all of the channels, let its starting y be near the top of the screen and the ending y position be at the bottom of the collectionView
```objective-c
else if([kind isEqualToString:timeIndicatorKind]){
    CGFloat cellStandardWidth = 400;
    NSDate *timeAtFront = [NSDate date];
    CGFloat currentTimeMarker = [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront]/(60*30.)*cellStandardWidth;
    CGFloat topOfIndicator = 20;
    attributes.frame = CGRectMake(currentTimeMarker, topOfIndicator, 2, contentSize.height);
  }
```
**3. Register the TimeIndicatorCell Line in the ViewController
```objective-c
[collectionView registerClass:[TimeIndicatorCell class]
     forSupplementaryViewOfKind:timeIndicatorKind
            withReuseIdentifier:timeIndicatorIdentifier];
```
** 4. Ensure it is called properly in the viewForSupplementaryElementOfKind method
```
objective-c
else if([kind isEqualToString:timeIndicatorKind]){
    TimeIndicatorCell *timeIndicatorCell = [collectionView dequeueReusableSupplementaryViewOfKind:timeIndicatorKind withReuseIdentifier:timeIndicatorIdentifier forIndexPath:indexPath];
    return timeIndicatorCell;
  }
```
#### G. Making the CollectionView Scrollable in both directions (Emily)
**1. In the CollectionViewLayout prepareLayout method calculate the frame of each cell
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
**2. Set the content size of the CollectionView
By making the contentSize of the CollectionView equal to the height and width of the entire collectionview, I'm able to allow the collectionview to be scrolled in both directions vs just one direction (because the collectionview width and height are bigger than the visible screen width and height respectively). Add the following to the end of the prepareLayout method after creating the frame for each cell.
```objective-c
CGFloat contentWidth = xMax;
      CGFloat contentHeight = [self.collectionView numberOfSections]*(CELL_HEIGHT+borderPadding)+yPadding;
      contentSize = CGSizeMake(contentWidth, contentHeight);
```
Return the larger contentSize we calculated to override the collectionViewContentSize
```objective-c
- (CGSize)collectionViewContentSize{
  return contentSize;
}
```
** 3. Force the prepareLayout method to be called for each screen rotation
Recalculate the bounds of the attribute frames for each cell depending on the new screen orientation. 
```objective-c
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
  return YES;
}
```
Returning yes to this method ensures that prepareLayout will be called everytime the device is rotated
** 4. Enable scrolling only in ONE direction AT A TIME
Set bidirectionallock to true to ensure that the collectionview can only be scrolled vertically OR horizontally (so that the view can't be scrolled diagonally)
``` objective-c
collectionView.directionalLockEnabled = true;
```
#### H. Making the video thumbnail cell
**1. Modify the Attribute Frame of each cell to accommodate the video cell
Since the video cell will always be the first cell column in the TV guide, allocate a space for the video cell in prepareLayout -- when creating the bounds for all the airing cells -- everytime the indexpath.item is 0. 
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
 ** 2. Modify the cellForIndexAtItemPath in the ViewController to accommodate the video cell 
 The video cell will always be at indexpath.item==0

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
