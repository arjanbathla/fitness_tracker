[Firebase Firestore Database]{.underline}

This Lab sheet will explore how to setup firebase firestore database for data storage using documents and collections.

Firebase offers two cloud-based, client-accessible database solutions that support realtime data syncing:

-   **Cloud Firestore** is Firebase\'s newest database for mobile app development. It builds on the successes of the Realtime Database with a new, more intuitive data model. Cloud Firestore also features richer, faster queries and scales further than the Realtime Database.

-   **Realtime Database** is Firebase\'s original database. It\'s an efficient, low-latency solution for mobile apps that require synced states across clients in realtime.

In Cloud Firestore, the unit of storage is the document. A document is a lightweight record that contains fields, which map to values. Each document is identified by a name. Documents live in collections, which are simply containers for documents. For example, you could have a users collection to contain your various users, each represented by a document.

You may experience a few errors along the way but keep going to the end of the lab sheet before running your app.

1.  Visit console.firebase.google.com, sign in with a google account and create a new project.

2.  There will be some set up instructions when starting to set up your project, **follow them carefully**. You will be given a Google Services file to drag-and-drop into your project too.

3.  Navigate to build -\> Firestore database then click create database and start in test mode

4.  Create a new project in Xcode and name it FirebaseProject.

5.  When the new project has finished building, go to File -\> Add Package dependencies

6.  Enter the Firebase GitHub repository:

    a.  URL: <https://github.com/firebase/firebase-ios-sdk>

7.  Make sure you add the following packages to your project by changing 'none' to the first option 'Your Project'. Then click 'add package'

    a.  Firebase Analytics

    b.  Firebase Firestore

    c.  Firebase Database

**This will step registers that you will be using Firebase within your app**

**Step 1: Create a Firestore Service**

We need to create a new Swift class (FirestoreService) that handles fetching data from Firestore. This service is responsible for:

1.  It uses the Firestore SDK which we applied in step 6, to connect directly to your Firestore database.

2.  It provides a mechanism to retrieve the documents in the Firestore from a specific collection (In our case that is items).

3.  It converts Firestore documents into Swift objects that can then be translated easily in your SwiftUI views.

4.  As we are using ObservableObject allows SwiftUI views to be automatically updated when some new data appears into the database.

Once the FirestoreService file is created, copy and paste the following code in:

**import** Foundation

**import** FirebaseFirestore

**class** FirestoreService: ObservableObject {

\@Published **var** items: \[Item\] = \[\]

**private** **var** db = Firestore.firestore()

**func** fetchItems() {

db.collection(\"items\").getDocuments { (snapshot, error) **in**

**if** **let** error = error {

print(\"Error getting documents: \\(error.localizedDescription)\")

**return**

}

**guard** **let** documents = snapshot?.documents **else** {

print(\"No documents found in \'items\' collection.\")

**return**

}

**self**.items = documents.map { docSnapshot -\> Item **in**

**let** data = docSnapshot.data()

**let** name = data\[\"name\"\] **as**? String ?? \"Unnamed\"

**let** description = data\[\"description\"\] **as**? String ?? \"No description\"

**return** Item(id: docSnapshot.documentID, name: name, description: description)

}

// Print the fetched items for debugging

print(\"Fetched items: \\(**self**.items)\")

}

}

}

**Step 2: Define your data model.**

1.  Create a new file called 'Item.swift' in the project directory.

In this step, you will create a simple Swift struct (Item) that represents the data structure fetched from Firestore. This model:

1.  **Defines Properties**: It includes properties like id, name, and description that correspond to the fields in your Firestore documents.

2.  **Implements Identifiable**: By conforming to the Identifiable protocol, each Item has a unique id, which makes it easy to display in SwiftUI lists.

3.  **Holds Data**: The Item struct acts as a container for the data fetched from Firestore, allowing you to easily pass it to your SwiftUI views for display.

    1.  Copy and paste the following code into the newly created file:

import Foundation

struct Item: Identifiable, Codable {

\@DocumentID var id: String?

var name: String

var description: String

}

**Step 3: Create the SwiftUI view**

In this step you will need to navigate to ContentView.Swift which was automatically generated when opening Xcode.

This step presents your data on screen which is taken from the Firestore service file collected from the Firestore database via Firebase. In this tutorial, we have used a List within a navigation

1.  Copy and paste the following code:

**struct** ContentView: View {

\@StateObject **private** **var** firestoreService = FirestoreService()

**var** body: **some** View {

NavigationView {

List(firestoreService.items) { item **in**

VStack(alignment: .leading) {

Text(item.name)

.font(.headline)

Text(item.description)

.font(.subheadline)

}

}

.navigationTitle(\"Items\")

.onAppear {

firestoreService.fetchItems()

}

}

}

}

**Step 4: Initialise Firebase in your app**

1.  Navigate to 'YourProjectName.Swift' file and add the following code:

You first need import Firebase so that when you open your app it knows you will be using the Firebase dependency.

Second, add the lines after the struct to configure Firebase.

**Step 5: Add data into Firebase Console**

In your recently created Firestore database, add a collection names 'items' with documents containing 'name' and 'description', which should resemble something like this:



**Step 6: Run your app!**

Your app should look something like this:


