# Recycle.ai

Problem: Recycling responsibly is hard! Not only do recycling guidelines vary drastically across cities affecting what products can or cannot be recycled in certain regions, public education surrounding product labeling and waste disposal is severly lacking. 

Solution: We are a group of UC Berkeley undergraduate students that created Recycle.ai to address these issues. Using computer vision, we've created an iOS app that accurately identifies recycling labels and informs our users whether their product is recyclable or not, based on their current location. This app aims to both encourage individuals to maker smarter waste disposal decisions and educate the general pubic about local recycling guidelines.

Please see below for instructions on accessing data and reproducing results.

# Data
Due to GitHub file size limits, the image data used to train all models can be found in our google drive at this link https://drive.google.com/drive/u/1/folders/1QmOEM3Dv56K2Nb0MMRIAc4LvA4wOXoH5?ths=true. 
- Images inside the "Classification Data" folder are organized by class (plastic types 1-7) and were used to train and validate our cnn classifcation model. 
- Images inside the "OD Data - Training" folder were used to train and validate our CreateML Object Detection model.
- Images inside the "OD Data - Test" folder were used to test our CreateML Object Detection model. 

Location data files can be found in the "location data" folder. 


# Running the iOS Application
All files needed to run the iOS application in Xcode can be found in the "recycleai2" folder. Please make sure that you have Xcode and cocoapods(https://cocoapods.org) installed before continuing to the following steps. 

1. run "pod init" to initialize a Podfile 
2. run "pod install" to install all dependencies
3. run "open RecycleAI_2.0.xcworkspace" to open the project in Xcode. 
4. Please add the .mlmodel files in addition to the .tsv files to the main file list in the Xcode project. These must be re-uploaded each time Xcode is completely quit or when first downloading the application from this repo. 
5. You should now be able to press the play button in Xcode to build and run the application on a simulator device. 

# Object Detection 
Our repo contains both attempts at building an object detection model. The "object detection- attempt1" folder contains our initial experimentation with object detection in python. The "object detection- attempt2" folder contains our final object detection .mlmodel file as well as a file named "annotations.json" which has the coordinates of the bounding boxes that were used to train our model. To train your own object detection model either drag and drop our object detection trainnig images and "annotations.json" file into the CreateML interface or following the instructions here ___ on how to create your own training bounding boxes. 

# Classification



