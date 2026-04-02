# Lab 9 - Firebase Authentication

Objective: In this lab, you will learn how to implement Firebase Authentication in a Swift app using email and password.

## 1. Set Up Firebase Project

1\. Visit <https://console.firebase.google.com> and sign in with your Google account.

2\. Create a new project and add an iOS app to it.



3\. Enter your app's Apple bundle ID when prompted.



To find out the apps bundle ID, return to Xcode



4\. Download the \'GoogleService-info.plist\' file and save it for later use.

## 2. Enable Email/Password Authentication

1\. In Firebase Console, navigate to Build → Authentication and click \'Get Started\'.



2\. Go to the \'Sign-in Method\' tab and enable \'Email/Password\'.



3\. Add a test email and password for use in this lab.

## 3. Create Xcode Project and Add Firebase SDK

1\. Create a new SwiftUI project in Xcode. (In the example below, I have named this 'FirebaseLogin'

2\. Go to File → Add Package Dependency.

3\. Paste https://github.com/firebase/firebase-ios-sdk into the search bar.

4\. Select Firebase Authentication and complete the installation.



## 4. Configure Firebase in Xcode

1\. Drag and drop the \'GoogleService-info.plist\' file into your Xcode project.



2\. Ensure it is added to the correct target.

3\. In your main app file (e.g., testingappApp.swift), add the following:

**This file is the main entry point to your app. You may notice the 'struct' having a different name here -- depending on what you called your project. I have named mine 'testingapp'.**

> 

## 5. Build Authentication UI with SwiftUI

1\. In ContentView.swift, import FirebaseAuth:

> import FirebaseAuth

2\. Declare state variables for email and password inside the ContentView:

> \@State var email = \"\"\
> \@State var password = \"\"

3\. Create the UI using NavigationStack and VStack:

> NavigationStack {\
> VStack {\
> TextField(\"Email\", text: \$email)\
> SecureField(\"Password\", text: \$password)\
> Button(action: {\
> login()\
> }) {\
> Text(\"Sign in\")\
> }\
> }\
> }

## 6. Implement Firebase Authentication Logic

Add the following function outside the body view:

> func login() {\
> Auth.auth().signIn(withEmail: email, password: password) { result, error in\
> if error != nil {\
> print(error?.localizedDescription ?? \"\")\
> } else {\
> print(\"success\")\
> }\
> }\
> }

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  ---------------------------------------------------------------------------------------------------------------------------------------------- ------------------------------------------------------------------------------------

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 7. Navigate on Successful Login

1\. Add a new state variable:

> \@State private var isLoggedIn = false

2\. 2. Navigate to the function 'login' which we created earlier.

a\. Currently if a user has logged in successfully and credentials match what is stored in Firebase, we just print out 'Success'. Add in 'isLoggedIn = true', so that it resembles this:



3\. Next, we need to add the navigation process to the main VStack we created earlier so that when the login process is successful the user is taken to the next page.

a\. Wrap the VStack with a 'NavigationStack' which will allow you to use the navigation options.

b\. Now create a new view/ page and call this 'pagetwo'



c\. After the padding() parameter, you need to create a navigation destination with a method which presents the new page.

i\. Add the following: .fullScreenCover(isPresented: \$isLoggedIn) {pagetwo()}



In this step we check the isLoggedIn variable and if true, we move the user to the second page which in this example I have called 'pagetwo()'.

As a result, you should end up with the following:



8\. Challenge: Improve the UI

The login screen and success page are currently plain. Try the following enhancements:

-   \- Add a welcome message after login.

-   \- Style the login screen using colors, fonts, and spacing.

-   \- Add error handling for incorrect credentials.

-   \- Include a loading indicator during authentication.
