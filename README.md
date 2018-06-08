# Fly_Tracking
Author: Yunus Kinkhabwala, 2018

# Overview
Please find here code to both record and track the positions of fruit flies. Several novel approaches to tracking the individual positions of large dense crowds of walking fruit flies are developed here, largely to deal with finding individuals and tracking their identities when they touch and form connected clusters. Each folder contains different functions and scripts, but for those to work, the subfunctions folder must be added to the Matlab path.

# System Requirements



## Hardware Requirements


This software requires only a standard computer. This software was tested on a computer with the following specifications:


RAM: 8+ GB  

CPU: 2+ cores, 2.7 GHz/core




## Software Requirements

#

All code is written in Matlab and tested on MatLab version R2017b. Code used for recording from cameras requires the add-on of the Image Acquisition toolbox. 

## OS Requirements



The package has been tested on the following systems:


Linux: 
Mac OSX:  

Windows: Windows 10 Pro

# Analyze video FBI
	FBI refers to a method described by Ramdya to track the identities of two distinct components of flies by using fluorescent markers. I have implemented this method in combination with my other algorithms. This is still under development.

# Analyze video fitfly
	Code within this folder uses a method I call "fitfly" to separate the individuals within a group using an input of a video of flies. A maximum fly size is established, and then the individuals are found by convolving a fitfly, which is just an average of what all the individual flies look like, across the groups. 

# Coarse Graining Positions
	When a video is analyzed, individual positions are extracted, but since we are interested in local densities, as described in our paper "The Density-Functional Fluctuation Theory of Crowds", we must divide up 2D environments into equal shape areas. Thus I have written code to split up an arbitrary 2D shape into approximately equal bins whose shape typically become distorted hexagons. The output of these function is a variable called "bins" which assigns each pixel with a label for a bin, thus by running "imagesc(bins)" one can see how the different bins are labelled. Also in this folder is code for taking the positions and the bins variable and retrieving the densities in each frame of the video.

# Realtime analysis
	In order to quickly collect data from fly experiments, I implemented the "fitfly" tracking algorithm to work in realtime. The cost of using this analysis is that the images are not saved and the acquisition of each image must wait for the analysis of the previous image to complete. This then may bias oversampling of images that are easier to analyze, typically ones with fewer clusters, so that later downsampling is required. 

#


