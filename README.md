

# A Powershell & ImageMagick script that sorts and divides image files into 2 folders. One for colored, and one for monochrome.


### How the script works

1.  The way an image is determined to be colored or monochrome, is by a single "weighted" value.

2.  This value is a weighted average of several functions.Each function produces a single for each image. Some functions are simple, others involve several processing. We first came up with many ideas, but were needed a solution, so we filtered it down to several below:


### Get-AverageHexDiff:

1.  using the the hex values from /temptxt<sub>hexes</sub> files, randomy select a pair of hexes, and calculate difference. This difference is then averaged


### Get-LinesCountWeight

1.  since the text files are values of image files with color reduced. "Color Quantization" . The lines counted indicate how "colorful" it is, though it isnt perfect as grayscale always messes up the calculation.


### Get-GrayRatio

1.  Percentage of grayscale over colored (by checking the differences between R,G & B)


## Before each image goes through all those methods, the following filtering is done


### Prepare-Files:

1.  This reduces the file size, as the originals are simply too big


### Start-WhiteRemoval:

1.  Replaces all white with a mid-gray (because of (a1), below, after references)


### Others:

1.  2 methods that sit after that awkwardly, to make the very slow processing faster.

2.  a method that reduces further the text files into unique colors.


## TODO:


### It needs another method to contribute to the weighting:

1.  calculates maximum differences between RGB values (Eg: RGB(100, 50, 20) means a diff max of 50 between R & G)

2.  but all this maximum differences, it is averages, producing a single value for each image

3.  this method needs to ignore the gray (already an output of existing method)


### Rename each folder better


### There is a TODO called simplify<sub>todo</sub>:

1.  which are 2 lines meant speed up processing, as the lines produced and time were simply too much. Maybe merged into another function (also preparation methods)


### remove folder and temp-text files entirely and do everything cache, however this would make the code difficult to modify afterwards, so this can be a separate "compilation" process


## References:


### <https://usage.imagemagick.org/quantize/>

> 
> 
> (a1) As a personal note to those unfamiliar why all this is necessary for something as simple as telling the difference between colored and monochrome images. Most computers in general, when dealing image files, "cant tell the difference sharply contrasted grayscale, and a sharply contrasted colored image, to a computer it all looks the same".

