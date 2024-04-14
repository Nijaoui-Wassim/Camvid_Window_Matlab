# Camvid_Window_Matlab
trying sliding window on Camvid using Matlab

# Steps to Run the MATLAB Code for Object Detection using FCN with CamVid Dataset

## Prerequisites
- Ensure you have MATLAB installed with the required add-ons and toolboxes for image processing and deep learning.
- You might need to install specific MATLAB toolboxes such as Deep Learning Toolbox, Computer Vision Toolbox, etc.

## Preparation
1. **Download the CamVid Dataset**:
   Run `downloadCamvid.m` to automatically download and extract the CamVid dataset. This script will set up the dataset in the appropriate directory for use with the MATLAB scripts.

2. **Set up MATLAB Path**:
   Add the CamVid dataset folder to your MATLAB path to ensure the scripts can access the data. This can typically be done within MATLAB:
   ```matlab
   addpath('CamVid');
   ```
   Replace `'CamVid'` with the actual path where the CamVid dataset is stored on your system. You might have to rerun the script if there are path issues.

## Running the Code
- **For Our Modified Approach**:
  Run `main_ours.m`. This script applies our modifications to the FCN architecture and processes the CamVid dataset using our approach.
  
- **For the Original FCN Approach**:
  Run `main_original.m`. This script processes the CamVid dataset using the original FCN approach without modifications.

## Additional Notes
- Make sure all required MATLAB toolboxes are installed and activated. You can check and install these from MATLAB Add-On Manager.
- If you encounter any issues with missing functions or errors related to missing toolboxes, please ensure all required toolboxes are installed and try again.
