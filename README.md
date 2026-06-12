# Kinematic Motion Tracking Pipeline (MATLAB)

An automated video processing pipeline designed to track human upper-limb kinematics from a single-camera video stream without using physical markers.

## Key Features
* **Feature Extraction:** Uses color-channel subtraction and morphological filtering (`imclose`) to segment the arm and eliminate background noise.
* **Coordinate Mapping:** Utilizes blob analysis (`regionprops`) to calculate spatial centroids for joint tracking.
* **Dynamic Labeling:** Implements a spatial sorting algorithm to automatically map coordinate points to the 'Shoulder', 'Elbow', and 'Wrist' frame-by-frame.

## How to Run
1. Open MATLAB and ensure the Computer Vision Toolbox is installed.
2. Place your source video file in the project directory.
3. Update the `inputFile` and `outputFile` paths in the script.
4. Run the script to process the video and generate the annotated tracking output.
