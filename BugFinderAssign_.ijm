print("\\Clear");
//	MIT License
//	Copyright (c) 2020 Nicholas Condon n.condon@uq.edu.au
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

//Prints info for the user + records into log details of the script
scripttitle= "BugFinderAssign";
version= "0.6";
date= "08-07-2020";
description= "This script finds bacteria (Using Ch2) and measures the area + intensities of each channel (Ch1/2/3) printing results out to a table. Mask Images and ROIs are also saved.";
showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><h4>
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> 
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><h4> </P4>"
    +"<h3>   <h3>"    
    +"<p1><font size=3  i>"+description+"</p1>
    +"<h1><font size=2> </h1>"  
	   +"<h0><font size=5> </h0>"
    +"");
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2020) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder for output files) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
Dialog.show(); 

//Directory Location
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);

//Setting up the dialog for file extension filtering
ext = ".lsm";																							//Defaults to .tif but this can be changed to another default filetype for convenience
Dialog.create("Settings");
Dialog.addString("File Extension: ", ext);
Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
Dialog.show();
ext = Dialog.getString();																				//Updates the variable ext should it be changed by the user in the dialog

start = getTime();																						//Begins internal timer as no more user inputs are required

//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_"+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/"; 
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);


//This generates xls file and creates the titles for each column
summaryFile = File.open(resultsDir+"Results_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+".xls");
print(summaryFile,"Image\t Image Number \t Num Nuclei \t Bug Number \t Bug Area \t Blue Mean \t Blue Median \t Blue Max  \t Green Mean \t Green Median \t Green Max \t Red Mean \t Red Median \t Red Max \t Bug PosX \t Bug PosY \t \t Distance to Nuc1...2...");	//creates table titles, these are split by tabs (\t)

//turns on the correct measurement parameters, clears results and ROI manager and closes any images
run("Set Measurements...", "area mean standard modal min centroid shape feret's median redirect=None decimal=3");
run("Clear Results");
roiManager("reset");
while (nImages>0) {selectImage(nImages); close();} 


//Main script loops
for (i=0; i<list.length; i++) {																			//Determines if any files exist in the directory
	if (endsWith(list[i],ext)){																			//Determines if the files end with the chosen extension

		run("Bio-Formats Importer", "open=["+path+list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");	//Opens File
		run("Clear Results");
		roiManager("reset");
		windowtitle = getTitle();																		//Gets the filename
		windowtitlenoext = replace(windowtitle, ext, "");												//Scrapes the extension from the filename to prevent weird names
		print("Opening File: "+(i+1)+" of "+list.length+"  Filename: "+windowtitle);					//Reports to the log which file is being opened

		run("Duplicate...", "title=Copy duplicate");													//Creates a working copy of the open image
		run("Split Channels");																			//Splits the image out into 3 channels
		selectWindow("C1-Copy");																		//Selects Red Channel
		rename("Red");																					//Renames the image to Red
		selectWindow("C3-Copy");																		//Selects the Blue Channel
		rename("Blue");																					//Renames the image to Blue
		selectWindow("C2-Copy");																		//Selects the Green Channel
		rename("Green");																				//Renames the image Green
		run("Duplicate...", "title=greenThresh duplicate");												//Creates a copy of the Green image and names it greenThresh

		selectWindow(windowtitle);
		run("Duplicate...", "title=Overlay duplicate channels=2");
		run("Enhance Contrast", "saturated=0.20");
	
		selectWindow("Blue");
		run("Median...", "radius=2");																	//Massages the greenThresh image prior to thresholding
		setAutoThreshold("Huang dark");
		run("Convert to Mask");
		run("Analyze Particles...", "size=30-Infinity show=Masks display add");

		NumNuc = nResults;
		NucX = newArray(nResults);
		NucY = newArray(nResults);
		for (n=0; n<nResults();n++){
			NucX[n] = getResult("X",n);
			NucY[n] = getResult("Y",n);
			}	
		run("Clear Results");

		selectWindow("Overlay");
			roiManager("Set Color", "blue");
			roiManager("Set Line Width", 2);
			roiManager("Show All");
			run("From ROI Manager");
			run("Flatten");
			rename("OverlayNuc");
		roiManager("reset");
		
		selectWindow("greenThresh");  																	//Selects the Green image
		run("Subtract Background...", "rolling=10");
		run("Median...", "radius=2");																	//Massages the greenThresh image prior to thresholding
		//setAutoThreshold("MaxEntropy dark");															//Creates an AutoTHreshold using the MaxEntropy algorithm
		setAutoThreshold("Li dark");																//Creates an AutoTHreshold using the Triangle algorithm
		//run("Threshold...");																			//Ensures the threshold window is active
		run("Convert to Mask");																			//Binarises the resultant threshold image


		selectWindow("Green");  																		//Selects the Green image
		run("Median...", "radius=2");																	//Massages the Green image prior to finding maxima
		run("Subtract Background...", "rolling=10");
		run("Find Maxima...", "prominence=50 output=[Segmented Particles]");							//Finds maxima and ouputs a segmented image
		rename("segmented");																			//Renames the output image as segmented
		imageCalculator("AND create", "greenThresh","segmented");										//Combines the thresholded bugs with the segmented image to 'split' them into individual bacteria
		run("Analyze Particles...", "size=0.15-Infinity show=Masks display exclude summarize add");		//Finds the bacteria and outputs a new image + ROIs and records the measurements
		rename("MaskofBugs");																			//Renames the resultant mask MaskofBugs
		print("Number of bacteria found: "+nResults);													//Reports the number of bugs found to the log window

  		//Sets up arrays needed for script
		BugArea=newArray(nResults);
		BlueMean=newArray(nResults);
		BlueMedian=newArray(nResults);
 		BlueMax=newArray(nResults);
 		GreenMean=newArray(nResults);
 		GreenMedian=newArray(nResults);
 		GreenMax=newArray(nResults);
		RedMean=newArray(nResults);
		RedMedian=newArray(nResults);
 		RedMax=newArray(nResults);
 		BugX=newArray(nResults);
 		BugY=newArray(nResults);

		//Measures blue channel
		run("Clear Results");
		selectWindow("Blue");
		roiManager("multi-measure measure_all");

		//Loops through results and places the results into the relevant array for the blue channel
		for (r=0; r<nResults();r++){
			BugArea[r] = getResult("Area",r);	
			BlueMean[r] = getResult("Mean",r);
			BlueMedian[r] = getResult("Median",r);
			BlueMax[r] = getResult("Max",r);
			BugX[r] = getResult("X", r);
			BugY[r] = getResult("Y", r);
			}

 		//Measures Green channel
 		run("Clear Results");
 		selectWindow("Green");
 		roiManager("multi-measure measure_all");

 		//Loops through results and places the results into the relevant array for the green channel
 		for (bl=0; bl<nResults();bl++){
			GreenMean[bl] = getResult("Mean",bl);
			GreenMedian[bl] = getResult("Median",bl);
			GreenMax[bl] = getResult("Max", bl);
 			}

		//Measures Red Chanenl
		run("Clear Results");
 		selectWindow("Red");
 		roiManager("multi-measure measure_all");

 		//Loops through results and places the results into the relevant array for the blue channel
 		for (bl=0; bl<nResults();bl++){
			RedMean[bl] = getResult("Mean",bl);
			RedMedian[bl] = getResult("Median",bl);
			RedMax[bl] = getResult("Max", bl);
 			}

			
		
			
	
    	//creates a loop for the number of bacteria found above, moves through each of the many arrays created above and scrapes the arrays to print into the output file
 		for (j=0 ; j<nResults ; j++) {  
    		window =i+1;
    		bugnumber = j+1;   		
    		Bugarea = BugArea[j];
    		Bluemean = BlueMean[j];
    		BlueMed =	BlueMedian[j];
       		Bluemax = BlueMax[j];
       		Greenmean = GreenMean[j];
       		GreenMed =	GreenMedian[j];
       		Greenmax = GreenMax[j];
       		Redmean = RedMean[j];
       		RedMed =	RedMedian[j];
       		Redmax = RedMax[j];
       		bugX = BugX[j];
       		bugY = BugY[j];
       		brk = "\t";
       		str = "";
       		for (k=0; k<NumNuc;k++){
       		xdif = abs(NucX[k] - bugX);
       		ydif = abs(NucY[k] - bugY);
       		hyp = sqrt((xdif^2)+(ydif^2));
       		str = str + brk + hyp;
       		}
       		
       		nucDistanceStr = str;

       		 
    		print(summaryFile,windowtitlenoext+"\t"+window+"\t"+NumNuc+"\t"+bugnumber+"\t"+Bugarea+"\t"+Bluemean+"\t"+BlueMed+"\t"+Bluemax+"\t"+Greenmean+"\t"+GreenMed+"\t"+Greenmax+"\t"+Redmean+"\t"+RedMed+"\t"+Redmax+"\t"+bugX+"\t"+bugY+"\t"+nucDistanceStr);
  	   		} 

		
	//Outputing results files into the output folder. The script will close and clear all relevant windows/results
	selectWindow("MaskofBugs");
  		saveAs("Tiff", resultsDir+ windowtitlenoext + "TotalfoudnBugs.tif");
	//saves the roi's found as defined above and empties the list before moving onto the next image
	roiManager("Save", resultsDir+ windowtitlenoext + "RoiSet.zip");
  	run("Clear Results");


	selectWindow("OverlayNuc");
	roiManager("Set Color", "white");
	roiManager("Set Line Width", 2);
	roiManager("Show All");
	run("From ROI Manager");
	run("Flatten");
  	saveAs("Tiff", resultsDir+ windowtitlenoext + "_overlay.tif");
  	roiManager("reset");
	print("Output files saved to directory");


//closes anything left open
	while (nImages>0) {selectImage(nImages); close();} 
     	
		}}														//End of script loops
		
//saves log file
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");

//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);
