
# Foursquare search

iOS Project implemented with Clean Layered Architecture and VIPER to search for a few venues around your current location with a radius filter.

## Layers
* **Domain Layer** = Entities + Extensions + Interfaces ( Protocols )
* **Data Layer** = Services: Network + Location
* **Presentation Layer (MVVM-C)** = ViewModels + Views + ViewBuilder + Coordinator

### Project overview
* Using MVVM architecture with a Coordinator for navigation
* Using SwiftUI and Combine to gather and display data
* ViewModel is fully tested
* Using Dependency injection and DIContainer to keep all dependencies and lazy load them
* Secured API keys in a plist ( at the moment is not added to .gitignore )

### API Request Docs
https://location.foursquare.com/developer/reference/v2-venues-search


## How to use app
Open the application, approve the location permission and venues around yourself will already load on the screen. 
Move the radius slider to adjust the distance of the search.

### Requirements
* Xcode Version 14+  Swift 5.6+

## Next steps
* Images
* Sort options
* Localization
* Loading states
* Upgrade to API V3 ( currently using V2 )
* Caching - results + location - for fast load
* A slider that grows exponentially ( something like a fibbonaci sequence ) - for accuracy
