# thefatties
MAB &amp; MAG &lt;3 

Plan of attack for 2D image analysis:
- use MATLAB to separate out lipid droplets from background (aka the hard part)
- pass MATLAB array to ImageJ array
- use ImageJ to analyze particles

# Now that we have a kinda working program, here are our plans to improve it:
- Try different threshold values (starting w/ greythresh), remove the non-circular components, and then merge all of them together in the end?
- Somehow use the fact that lipid droplets have a white center and a darker outer outline so that you can classify them
- Try different threshold values (w/ greythresh as the start) and iterate until the quantity (# droplets/# blobs) is at its max? assuming that this quantity has a gaussian like distribution aka there is only 1 peak somewhere
- Figure out a way other than greythresh to figure out a good threshold
- Go through the image and assess whether each position is a lipid droplet based on it's surrounding cells. The current filters do this by just putting the median value of the neighboring cells into the cell, but maybe we can come up with a better way?