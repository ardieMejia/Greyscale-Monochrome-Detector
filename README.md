
# Table of Contents

1.  [A Powershell & ImageMagick script that sorts and divides image files into 2 folders. One for colored, and one for monochrome.](#orgaf67e86)
    1.  [The way an image is determined to be colored or monochrome, is by a single "weighted" value.](#org6605e57)
    2.  [This value is a weighted average of several functions.Each function produces a single for each image. Some functions are simple, others involve several processing. We first came up with many ideas, but were needed a solution, so we filtered it down to several below:](#org55e38dc)
        1.  [Get-AverageHexDiff:](#org9738179)
        2.  [Get-LinesCountWeight](#org2a641a8)
        3.  [Get-GrayRatio](#org28837c6)
2.  [Before each image goes through all those methods, the following filtering is done](#org7a52833)
    1.  [Prepare-Files: This reduces the file size, as the originals are simply too big](#orga83a070)
    2.  [Start-WhiteRemoval: Replaces all white with a mid-gray (because of (a1), below, after references)](#org495a257)
    3.  [2 methods that sit after that awkwardly, to make the very slow processing faster.](#org600610a)
    4.  [a method that reduces further the text files into unique colors.](#org879f5bd)
3.  [TODO:](#orgb59be5b)
    1.  [It needs another method to contribute to the weighting:](#org6e3916f)
        1.  [calculates maximum differences between RGB values (Eg: RGB(100, 50, 20) means a diff max of 50 between R & G)](#org9a85e77)
        2.  [but all this maximum differences, it is averages, producing a single value for each image](#org9dbc608)
        3.  [this method needs to ignore the gray (already an output of existing method)](#org3d19b13)
    2.  [rename each folder better](#org0eb3c21)
    3.  [There is a TODO called simplify<sub>todo</sub>, which are 2 lines meant speed up processing, as the lines produced and time were simply too much. Maybe merged into another function (also preparation methods)](#orga994e7d)
    4.  [remove folder and temp-text files entirely and do everything cache, however this would make the code difficult to modify afterwards, so this can be a separate "compilation" process](#orgd89cb0b)
4.  [References:](#org5a69740)
    1.  [https://usage.imagemagick.org/quantize/](#org9d47fa9)
5.  [(a1) As a personal note to those unfamiliar why all this is necessary for something as simple as telling the difference between colored and monochrome images. Most computers in general, when dealing image files, "cant tell the difference sharply contrasted grayscale, and a sharply contrasted colored image, to a computer it all looks the same".](#org6bfddcf)


<a id="orgaf67e86"></a>

# A Powershell & ImageMagick script that sorts and divides image files into 2 folders. One for colored, and one for monochrome.


<a id="org6605e57"></a>

## The way an image is determined to be colored or monochrome, is by a single "weighted" value.


<a id="org55e38dc"></a>

## This value is a weighted average of several functions.Each function produces a single for each image. Some functions are simple, others involve several processing. We first came up with many ideas, but were needed a solution, so we filtered it down to several below:


<a id="org9738179"></a>

### Get-AverageHexDiff:

1.  using the the hex values from /temptxt<sub>hexes</sub> files, randomy select a pair of hexes, and calculate difference. This difference is then averaged


<a id="org2a641a8"></a>

### Get-LinesCountWeight

1.  since the text files are values of image files with color reduced. "Color Quantization" . The lines counted indicate how "colorful" it is, though it isnt perfect as grayscale always messes up the calculation.


<a id="org28837c6"></a>

### Get-GrayRatio

1.  Percentage of grayscale over colored (by checking the differences between R,G & B)


<a id="org7a52833"></a>

# Before each image goes through all those methods, the following filtering is done


<a id="orga83a070"></a>

## Prepare-Files: This reduces the file size, as the originals are simply too big


<a id="org495a257"></a>

## Start-WhiteRemoval: Replaces all white with a mid-gray (because of (a1), below, after references)


<a id="org600610a"></a>

## 2 methods that sit after that awkwardly, to make the very slow processing faster.


<a id="org879f5bd"></a>

## a method that reduces further the text files into unique colors.


<a id="orgb59be5b"></a>

# TODO:


<a id="org6e3916f"></a>

## It needs another method to contribute to the weighting:


<a id="org9a85e77"></a>

### calculates maximum differences between RGB values (Eg: RGB(100, 50, 20) means a diff max of 50 between R & G)


<a id="org9dbc608"></a>

### but all this maximum differences, it is averages, producing a single value for each image


<a id="org3d19b13"></a>

### this method needs to ignore the gray (already an output of existing method)


<a id="org0eb3c21"></a>

## rename each folder better


<a id="orga994e7d"></a>

## There is a TODO called simplify<sub>todo</sub>, which are 2 lines meant speed up processing, as the lines produced and time were simply too much. Maybe merged into another function (also preparation methods)


<a id="orgd89cb0b"></a>

## remove folder and temp-text files entirely and do everything cache, however this would make the code difficult to modify afterwards, so this can be a separate "compilation" process


<a id="org5a69740"></a>

# References:


<a id="org9d47fa9"></a>

## <https://usage.imagemagick.org/quantize/>


<a id="org6bfddcf"></a>

# (a1) As a personal note to those unfamiliar why all this is necessary for something as simple as telling the difference between colored and monochrome images. Most computers in general, when dealing image files, "cant tell the difference sharply contrasted grayscale, and a sharply contrasted colored image, to a computer it all looks the same".

