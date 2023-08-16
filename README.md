
# Foursquare search

iOS Project implemented with Clean Layered Architecture and VIPER to search for a few venues around your current location with a radius filter.

## Layers
* **Domain Layer** = Entities + Extensions + Interfaces ( Protocols )
* **Data Layer** = API (Network) + Location
* **Presentation Layer (VIPER)** = ViewModels ( Presenters ) + Views + Interactors + Coordinators ( Routers )

### Project overview
* The project is well split in folders based on their layer, making it easy to migrate to a modules based architecture and keeping the file structure clean and easy to discover. 
* Using Combine to gather input, make requests and update UI.
* The project uses UIKit, but it's current state makes it easy to migrate to SwiftUI if needed.
* Architecture of choice was VIPER due to it's nature of splitting responsibilities better for projects that needs scaling.
* Dependency Inversion was used to enable easy mocking for writting unit tests.
* There is no 3rd party library integrated

### API Request Docs
https://location.foursquare.com/developer/reference/v2-venues-search

### Views
This repository uses xibs.

## How to use app
Open the application, approve the location permission and venues around yourself will already load on the screen. Move the radius slider to adjust the distance of the search.

### Requirements
* Xcode Version 14+  Swift 5.6+

## Next steps
* Using API V2 ( to upgrade to V3 )
* Images
* Sort options
* Localization
* Caching - results + location - for fast load
* Loading states
* Better error handling
* Separate class for data source
* A slider that grows exponentially ( something like a fibbonaci sequence ) - for accuracy
* A Dependency Container to pass to next Coordinators

Improvement:
View controller should not know about the venues, only when it is ready to update the tableView.