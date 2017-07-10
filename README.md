# MachineLearningSample-ObjC
A simple iOS app to demonstrate Machine Learning capabilities using Core ML and Vision framework.


Requirements:

1. iOS 11 for all features
2. Xcode 9
3. Download the Inceptionv3.mlmodel file from the below url and put it inside the Resource folder.

On Showcase:

1. Machine Learning sample (image recognition).
2. Face recognition using Vision Framework.
3. Text recognition using Vision Framework.

Usage:

Run the app and select an image from gallery or camera. App uses Inceptionv3.mlmodel (https://docs-assets.developer.apple.com/coreml/models/Inceptionv3.mlmodel)
to process image. Detect the whole face using 
<b>VNDetectFaceRectanglesRequest</b>.

To detect specific facial landmarks like face contour, eyes, eyebrow, nose, lips with outer lips and others, use:
<b>VNDetectFaceLandmarksRequest</b>

Screenshots:

As you can see the model is not exactly 100% correct and still has miles to cover!

![Alt text](/Screenshots/1.png?raw=true "")
![Alt text](/Screenshots/2.png?raw=true "")
![Alt text](/Screenshots/3.png?raw=true "")
![Alt text](/Screenshots/ss4.png?raw=true "")
![Alt text](/Screenshots/ss5.png?raw=true "")

