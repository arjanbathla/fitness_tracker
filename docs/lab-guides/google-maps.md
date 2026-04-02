**[Lab 7: Google Maps and GPS]{.underline}**

In this lab (and future labs), you will require a Google account to access Google Services. You can either use one you already have; it makes no difference to your account. However, if you would prefer, you can make a new Google account for lab / university purposes.

**[Pre-requisite: Getting an API key for your Xcode Project.]{.underline}**

To use Google Map services, we will require an API key. Google will automatically assume you are a company trying to use their services, not a university student! They have made it much more challenging over the years to obtain an API key without entering banking information, which we certainly do not want you to do or will ever ask you to do as a student. We have a method of gathering an API key outlined below without entering any banking information:

1.  Create an Xcode Project.

2.  Open a web browser and go to <https://cloud.google.com> and sign into your Google account.

3.  Press "Console" in the top right corner.

4.  Press the "Project" dropdown in the top left corner and select "New Project" on the screen that pops up.

5.  Inside the "Project Name" box, enter a project name that lines up with your Xcode Projects name. The "Organisation" box you can leave as it is. Press "Create".

6.  It will take a few moments for your project to be created. Once it has been created, select your project from the same dropdown in the top left corner used in step 4. Once selected, press "Dashboard".

7.  On your screen, you will see a range of different services you can enable We want to the API services in this lab, so find and press the "Go to APIs Overview" button.

8.  On the left, press the "Credentials" button. Followed by the "Create Credentials" button, and then the "API key" button.

9.  Success! You now have an API key you can use in your Xcode Projects. Do not share your API key with anyone, keep it to yourself. Next, we need to use the API key inside an Xcode project. Keep this window open or take a copy of your API key and store it somewhere (it can be retrieved later, if you prefer).

10. Back on the left, now press the "Library" button, followed by the "Maps SDK for iOS" button. Click the "Enable" button, this will navigate you to a set up payment back, but if you should be able to go back without entering any details and the API should be enabled.

**[Google Maps]{.underline}**

Inside your Xcode project, we are going to use the Google Maps services. You should have already created an Xcode project in the API key instructions.

**Important:**

You should already have your API key from the previous section of the lab. Do not follow the link to get an API key as Google will ask for your banking information. Please use the shown method in the lab sheet to obtain an API key

**Method 1: Using Swift Package Manager (SPM)**

1.  In order to add Google Maps SDK via Swift Package Manager, select File -\> Add Packages... (or in some cases Add Package Dependencies). In the search bar, enter <https://github.com/googlemaps/google-maps-ios-utils> and select Add Package.



**Method 2: Manual Integration**

1.  Download the following Google Maps SDKs for iOS from [here](https://developers.google.com/maps/documentation/ios-sdk/config#manual-installation).



2.  Extract the files.

3.  Drag and drop the downloaded framework files (e.g., GoogleMaps.framework and any other dependencies) into your Xcode project. Make sure to check \"Copy items if needed\". Click Finish.

    a.  Copy the GoogleMaps.bundle from the **GoogleMapsResources** you downloaded into your Xcode project\'s top level directory.



4.  Select your project from the Project Navigator, and choose your application\'s target.

5.  Open the **Build Phases** tab for your application\'s target. Within **Link Binary with Libraries**, add the following frameworks and libraries:

-   Accelerate.framework

-   Contacts.framework

-   CoreData.framework

-   CoreGraphics.framework

-   CoreImage.framework

-   CoreLocation.framework

-   CoreTelephony.framework

-   CoreText.framework

-   GLKit.framework

-   ImageIO.framework

-   libc++.tbd

-   libz.tbd

-   Metal.framework

-   QuartzCore.framework

-   SystemConfiguration.framework

-   UIKit.framework



**Continue below after the Google Maps SDK installation.**

1.  In your AppDelegate (or in your main SwiftUI app file), import Google Maps and configure the API key.



2.  In your ContentView, create a UIViewRepresentable to integrate the Google Maps view.



3.  Your Maps application should be ready to launch! Try launching it and you should see a map load of USA with a pointer located on San Francisco:



**Obtaining exact location from the user**

This short tutorial will allow you to obtain the users location in terms of latitude and longitudinal values. This part does assume that you have finished the first tutorial above, as we will be using the same GoogleMaps API key and packages.

**Configure Info.plist for Location Services**

1.  **Open Info.plist**:

    -   In the Project Navigator, find and open the Info.plist file.





2.  **Add Location Usage Keys**:

    -   Right-click (or Control-click) in an empty area and select **Add Row**.

    -   Add the following keys:

        -   **Key**: NSLocationWhenInUseUsageDescription

            -   **Type**: String

            -   **Value**: \"This app needs access to your location to show nearby points of interest.\"



-   **Key**: NSLocationAlwaysUsageDescription

    -   **Type**: String

    -   **Value**: \"This app needs access to your location even when the app is in the background.\"



**Create the LocationManager Class**

1.  **Add a New Swift File**:

    -   Right-click on your project folder and select **New File**.

    -   Choose **Swift File** and name it LocationManager.swift.

2.  **Implement LocationManager**:

    -   Copy and paste the following code into LocationManager.swift:



**See code to copy into this file below as well as comments regarding how this piece of code works.**

import Foundation

import CoreLocation

import Combine

Foundation: Provides basic classes and functionalities for the app.

CoreLocation: Enables location-based services.

Combine: Used for handling asynchronous events, particularly useful for observing changes (like location updates).

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

private var locationManager: CLLocationManager

\@Published var currentLocation: CLLocation?

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

• **NSObject**: The base class from which most Objective-C classes inherit, allowing integration with Cocoa frameworks.

• **CLLocationManagerDelegate**: A protocol that allows the class to respond to location manager updates.

• **ObservableObject**: A protocol that allows SwiftUI views to observe this object for changes (like location updates).

locationManager: An instance of CLLocationManager, which manages location-related activities.

currentLocation: A published property that holds the user\'s current location. The @Published attribute allows SwiftUI views to automatically update when this value changes.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

override init() {

locationManager = CLLocationManager()

super.init()

locationManager.delegate = self

locationManager.requestWhenInUseAuthorization() // Request permission

locationManager.startUpdatingLocation() // Start updating location initially

}

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Initializes the locationManager.

Sets the delegate to self, meaning this class will handle location updates.

Requests permission to access the user\'s location while the app is in use.

Starts updating the user\'s location immediately upon initialization.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

// Method to start updating location (optional, but useful for control)

func startUpdatingLocation() {

locationManager.startUpdatingLocation()

}

func locationManager(\_ manager: CLLocationManager, didUpdateLocations locations: \[CLLocation\]) {

guard let location = locations.last else { return }

currentLocation = location // Update the current location

print(\"Location: \\(location.coordinate.latitude), \\(location.coordinate.longitude)\")

}

This method is called when the location manager receives new location data.

It checks if there are new locations and retrieves the last one.

Updates the currentLocation property and prints the coordinates.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

func locationManager(\_ manager: CLLocationManager, didFailWithError error: Error) {

print(\"Failed to find user\'s location: \\(error.localizedDescription)\")

}

}

This method is called if the location manager fails to retrieve the location.

It logs the error message for debugging purposes.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

**Update ContentView to Show Location**

1.  **Open ContentView.swift:**

    -   **In the Project Navigator, find and open ContentView.swift.**

2.  **Update the Code:**

    -   **Replace the existing code with the following:**



**You should end up with the emulator looking something like this:**

**Remember to agree to permissions for location which should prompt you on loading the application.**


