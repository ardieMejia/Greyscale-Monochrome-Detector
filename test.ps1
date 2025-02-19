




# $count =  Get-Content ./hello.txt | Measure-Object -Line



# $lines = "percentage is "+$count.Lines
# Write-Output $lines






# =====  downsccale  all  image into a temp directory
# ===== we assume all files have unique names. We can
# =====  change this if we need it

# rm ./temp/*
rm ./temp_scaled/*
rm ./temptxt/*
rm ./temptxt_val/*
rm ./temp_nowhite/*
rm ./temp_reduce/*
rm ./temptxt_hexes/*
rm ./tempfinal_val/*
rm ./input/*



$_listItems = Get-ChildItem -Path ./originals


# Prepare files by converting into manageable size
function   Prepare-Files(){
    param(
        [Parameter(Position=0)]
        [string]$filename
    )
    $temp = ./my_magick/magick.exe ./originals/$($filename) -resize x1400 ./input/$($filename) | Out-String
}

# Also preparing files by replacing white with a mid-gray (mid between black and white)
# this is to avoid "over-weighting" the final value 
function Start-WhiteRemoval(){
    param(
        [Parameter(Position=0)]
        [string]$filename
    )
    # if you remove the colorspace, some images will not respond properly to color replacement  (grayspace color doesnt respond correctly)
    $temp = ./my_magick/magick.exe ./input/$($filename) -colorspace sRGB -fuzz 10% -fill "#808080" -opaque white ./temp_nowhite/$($filename) | Out-String    
}


function Get-AverageHexDiff(){    
    param(
	[Parameter(Position=0)]
        [string]$filename,
        [Parameter(Position=1)]
	[array]$hexes
    )
    $sum_count = 0
    for($i=0; $i -lt $hexes.count/2; $i++){

	# randomly get 2 hex values from the list, where this list is a single text file of reduced hex values of an image
	$rand_num1 = Get-Random -Minimum -1 -Maximum $hexes.count
	$rand_num2 = Get-Random -Minimum -1 -Maximum $hexes.count
	$firstCol = $hexes[$rand_num1].split(" ")[0]
	$secondCol = $hexes[$rand_num2].split(" ")[0]

	
	# ========== file cleaning ==========
	# TODO: replace temp file with variable, if possible
	$tempname = "./temptxt_val/"+$item.name.split(".")[0]+"_tempval.txt"
	# an IM image calculation that calculates difference between 2 colors (2 values)
	$(.\my_magick\magick.exe compare -metric RMSE xc:$firstCol xc:$secondCol txt:-) *> $tempname
	$unclean = Get-Content -path $tempname
	$unclean[2].split("(")[1].split(")")[0] | Out-File -FilePath $tempname
	$single_val = Get-Content -path $tempname
	$rand_diff_sum += [float]$single_val
	# ========== file cleaning ==========
	
	
	$sum_count += 1
    }

    # so in the end, $rand_num is what we need, average of color differences of pairs, across only half of pixels from the scaled down image
    $rand_num = $rand_diff_sum / $sum_count
    Write-Output $rand_num
    
}

function Set-Gray{
    param(
	[Parameter(Position=0)]
        [string]$srgb
    )

     "asd"  -like "*As*"

    if (($srgb -like "*grey*") -or  ($srgb -like "*gray*")){       
	return "Gray"
    }

    if ($srgb.contains("srgb")){
	$arr = ($srgb.split(",") -replace "[()srgb]")

	
	$final  = ([Math]::abs($arr[0] - $arr[1]) + [Math]::abs($arr[0] - $arr[2])) /2
	if ($final -lt 3){
	    return "Gray"
	}else {
	    return "colored"
	}
    }else{
	return "colored"
    }
    
    
    
}

function Get-GrayRatio{

    param(
	[Parameter(Position=0)]
        [string]$filename
    )
    
    $fullCount =  Get-Content $filename | Measure-Object -Line
    $grayCount =  Get-Content $filename | Select-String -pattern "Gray" | Measure-Object -Line
    $nonGrayCountLines = $fullCount.Lines - $grayCount.Lines

    # return $count.Lines
    $Gpct = $grayCount.Lines / $fullCount.Lines
    if ($Gpct -gt 0.8){
	return 0
    }
    $Npct = $nonGrayCountLines / $fullCount.Lines
    return $Npct*0.8
    
}

function Get-LinesCountWeight{

    param(
	[Parameter(Position=0)]
        [string]$filename
    )
    
    $count =  Get-Content $filename | Measure-Object -Line
    
    

    return $count.Lines
    
}

function Copy-FilesToFolder{
    $items = Get-ChildItem -Path "./tempfinal_val"
    # $realImgName = $item.name.split("!")[0]
    foreach($item in $items){
	$val = Get-Content -Path $item.fullname
	if ($val -gt 0.5){
	    Write-Output ".\input\$($item.name.split("!")[0])"
	    cp ".\originals\$($item.name.split("!")[0])"  ".\colored\." 
	}else{
	    # cp ".\input\$($item.split("!")[0])"  ''".\monochrome\."
	    Write-Output ".\input\$($item.name.split("!")[0])"
	    cp ".\originals\$($item.name.split("!")[0])"  ".\monochrome\." 
	}
	
    }
}

# we prepare files from /original folder
# white-removal is also a part of the preparation process
for($i=0; $i -lt $_listItems.Count; $i++){
    Prepare-Files($_listItems[$i].name)
    Start-WhiteRemoval($_listItems[$i].name)
    
    # ===== TODO: simplify_todo: the following 2 lines sit there awkwardly becoz later processing after these simply produced too many files, and took too long
    # further reduce in color. 
    $temp = ./my_magick/magick.exe ./temp_nowhite/$($_listItems[$i]) +dither   -posterize 3   ./temp_reduce/$($_listItems[$i]) | Out-String
    # further reduce in size
    $temp =  ./my_magick/magick.exe ./temp_reduce/$($_listItems[$i])  -resize 10x ./temp_scaled/$($_listItems[$i]) | Out-String
    # ======================================================================================================================================= 

    
    (./my_magick/magick.exe ./temp_scaled/$($_listItems[$i]) -unique-colors -depth 8  txt:-) | Out-File -FilePath ./temptxt/$($_listItems[$i]).txt
}


$_list = Get-ChildItem -Path ./originals

# ========== the 3rd index from each row in .<image-name>.txt will get  the colmn we want, becoz making IM text output behave consistent is a headache


foreach ($itemT in $_list){    
    $csvData = Get-Content -path "./temptxt/$($itemT.name).txt"
    $i = 1
    
    foreach($item in $csvData){
	$item = $item.replace("  "," ")
	$item = $item.split(" ")

	if($i -ne 1){
	    $name = "./temptxt_hexes/"+$itemT.name+"!list_of_hexes.txt"

	    # Write-Output $name
	    $item[3] = Set-Gray($item[3])
	    Write-Output "$($item[2]) $($item[3])" | Out-File -append -FilePath $name
	}	
	$i += 1
    }    
}




$csvHexes = Get-ChildItem -path ./temptxt_hexes/

foreach($item in $csvHexes){

    $hexes = Get-Content -Path $item.fullname
   

    $finalname = "./tempfinal_val/"+$item.name.split("!")[0]+"!singlefinalval.txt"
    $itemname = [String]$item.name
    Write-Output $itemname
    $averageHexDiff =  (Get-AverageHexDiff $itemname $hexes) | Out-String # *>>  $finalname
    $linesCount = Get-LinesCountWeight($item.fullname)
    $nGrayPct = Get-GrayRatio($item.fullname)
    $linesCountWeight = $linesCount / 80
    if($linesCountWeight -gt 1) {$linesCountWeight = 1}
    Write-Output  $averageHexDiff
    Write-Output $linesCountWeight
    Write-Output $nGrayPct

    $finalValue = ([float]$averageHexDiff*0.9 + [float]$linesCountWeight*1.3 + $nGrayPct*0.8) / 3 # weighting
    $finalValue  *>>  $finalname
    Copy-FilesToFolder    
}






    

# ===== now with the values in list_of_hexes.txt we randomly get any pair of number,
# get the difference of color value using magik's compare,
#  output into another file (this file needs constant  "cleaning", becoz of difficult using Powershell output redirect)

# foreach($item in $csvVals){
#     Get-Random -Minimum -1 -Maximum 10
    
# }








#  for($i=0; $i -lt $csvData.Count; $i++){
#     Write-Output $csvData[0]
# }
