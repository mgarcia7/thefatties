# Senior Design Project Goal
Develop a computational algorithm that can characterize the growth of lipid droplets from time-lapse images of the tissue.

Ideally, our algorithm would be able to process 1 image in 10 seconds.

# Extract lipid droplets from the background
1. Create a binary image from a threshold value the has the regions of light intensity as white, and everything else black, remove non-circular objects *implemented in thresholding.m*
2. Lipid droplets are characterized by dark rings and light interiors, so use imfindcircles to find dark rings in the image *implemented in darkring.m*
3. Create a binary image just like in algorithm 1 --> create another binary image that has the regions of dark intensity as white, and everything else white --> somehow use the intersection of these images in order to get a binary image with only lipid droplets *needs to be implemented*
4. Same process as algorithm 1, but use intensity profiles to determine whether a lipid droplet is background or noise *needs to be implemented*

# Calculating per cell statistics
1. Use some sort of clustering algorithm to group lipid droplets into a cell
	- If we get fluorescent images along with phase images, then we can probably just use K-means
	- If not, we can experiment with Kruskal's algorithm, or hierarchical clustering
	- See which algorithms MATLAB already implements
2. Smooth out the image using a median filter with a large radius, and then use imfindcircles to define clusters of lipid droplets
3. Come up with some less computationally intensive ways to define cells

# Measuring Success
For now, use the F-score to compare different algorithms. We might want to look into other metrics though...




