# Camera Tutorial

The following resources allows you to create a simple camera app that takes the photo and presents the results back to the user on screen.

**1. Create a New Project**

1.  Open **Xcode** and create a new project.

2.  Choose **App** under iOS and click **Next**.

3.  Name the project, choose **Swift** as the language, and **SwiftUI** as the interface.

**2. Configure Info.plist**

1.  Open Info.plist.

2.  Add these keys:

    -   **Privacy - Camera Usage Description** (Explain why the app needs camera access).



**3. Create the Camera App in SwiftUI**

1.  Open ContentView.swift and replace the content with the following code:

import SwiftUI

import UIKit

struct ContentView: View {

\@State private var isShowingCamera = false

\@State private var capturedImage: UIImage?

var body: some View {

VStack {

if let image = capturedImage {

Image(uiImage: image)

.resizable()

.scaledToFit()

.frame(height: 300)

} else {

Text(\"No Image Captured\")

.font(.headline)

}

Button(\"Take Photo\") {

isShowingCamera = true

}

.padding()

.background(Color.blue)

.foregroundColor(.white)

.cornerRadius(8)

.sheet(isPresented: \$isShowingCamera) {

CameraView(capturedImage: \$capturedImage)

}

}

.padding()

}

}

struct CameraView: UIViewControllerRepresentable {

\@Binding var capturedImage: UIImage?

func makeUIViewController(context: Context) -\> UIImagePickerController {

let picker = UIImagePickerController()

picker.sourceType = .camera

picker.delegate = context.coordinator

return picker

}

func updateUIViewController(\_ uiViewController: UIImagePickerController, context: Context) { }

func makeCoordinator() -\> Coordinator {

Coordinator(self)

}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

let parent: CameraView

init(\_ parent: CameraView) {

self.parent = parent

}

func imagePickerController(\_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: \[UIImagePickerController.InfoKey : Any\]) {

if let image = info\[.originalImage\] as? UIImage {

parent.capturedImage = image

}

picker.dismiss(animated: true, completion: nil)

}

func imagePickerControllerDidCancel(\_ picker: UIImagePickerController) {

picker.dismiss(animated: true, completion: nil)

}

}

}

**Explanations:**

**Explanation for ContentView:**

-   **State Variables**: @State is used to create two state variables:

    -   isShowingCamera: Controls whether the camera interface is visible.

    -   capturedImage: Holds the image captured by the camera.

-   **VStack**: Used to arrange the UI elements vertically. The image or placeholder text is displayed at the top, followed by a button.

-   **Button**: Triggers the display of the camera when clicked by setting isShowingCamera to true.

-   **sheet**: A .sheet modifier is used to present the camera interface when isShowingCamera is true. It presents a new view (CameraView), passing the binding of the capturedImage so that the captured photo can be saved.

**Explanation for CameraView:**

-   **UIViewControllerRepresentable**: SwiftUI uses UIViewControllerRepresentable to integrate UIKit components (like UIImagePickerController) into SwiftUI. This protocol has two methods: makeUIViewController and updateUIViewController.

    -   makeUIViewController: This method creates the UIImagePickerController and sets its sourceType to .camera to open the camera.

    -   updateUIViewController: This method is not needed in this case but is required by the protocol, so it\'s left empty.

-   **Coordinator**: The Coordinator class is needed to act as a bridge between the UIKit UIImagePickerControllerand SwiftUI. It conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate to handle the camera\'s delegate methods:

    -   **didFinishPickingMediaWithInfo**: Called when the user takes a photo. It retrieves the image and sets the capturedImage variable.

    -   **imagePickerControllerDidCancel**: Called when the user cancels the camera. It dismisses the camera interface.

-   **\@Binding**: This allows data to be shared between ContentView and CameraView. The capturedImage is passed as a binding so that the photo captured in the camera can be reflected back in the main view.

**4. Change entry point to the app**

**import** SwiftUI

**\@main**

**struct** cameraprojectApp: App {

**var** body: **some** Scene {

WindowGroup {

ContentView()

}

}

}

**Explanation for cameraprojectapp:**

-   **\@main**: This annotation marks the entry point for the SwiftUI app. The app begins with the CameraApp struct.

-   **WindowGroup**: A container for the app\'s user interface. Inside, we define ContentView() as the root view of the app.
