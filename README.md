## Creating an Objective C Collection View Programmatically
This guide is to create an Objective C UICollectionView programmatically (without Storyboard or xib files). <br>
This is a log for future documentation purpose. 


### 1. Create an EPG object 
 An EPG is a menu is displayed that lists current and upcoming television programs on all available channels. The structure: 

    epg/
    ├── FOX                      
      ├── Airing1
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
        ├── description        
        ├── title   
      ├── Airing2  
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
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
   .... 
   
