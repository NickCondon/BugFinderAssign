# BugFinderAssign
This script takes 3-colour images and finds bacteria (channel 2) and assigns them to a cell (macrophage) before measuring their internsity, size, and
shape descriptors before saving the outputs to a spreadsheet.

Developed by Dr Nicholas Condon for Jessica von Pein.

[ACRF:Cancer Biology Imaging Facility](https://imb.uq.edu.au/microscopy), 
Institute for Molecular Biosciences, The University of Queensland
Brisbane, Australia 2018.

This script is written in the ImageJ1 Macro Language.


Running the script
-----
The first dialog box to appear explains the script, acknowledges the creator and the ACRF:Cancer Biology Imaging Facility.

The next window to open will be the input file directory location.

The nest dialog to open will prompt the user to select parameters for the script to run including the expected file's extension (eg, .lsm, .tif, etc) and whether to run in batch mode (background).
The file extension is actually a file ‘filter’ running the command ‘ends with’ which means for example .tif may be different from .txt in your folder only opening .tif files. Perhaps you wish to process 
files in a folder containing <Filename>.tif and <Filename>+deconvolved.tif you could enter in the box here deconvolved.tif to select only those files. 
It also uses this information to tidy up file names it creates (i.e. no example.tif.avi)

The final dialog box is an alert to the user that the batch is completed. 

### Preventing the Bio-formats Importer window from displaying:
1. Open FIJI
2. Navigate to Plugins > Bio-Formats > Bio-Formats Plugins Configuration
3. Select Formats
4. Select your desired file format (e.g. “Zeiss CZI”) and select “Windowless”
5. Close the Bio-Formats Plugins Configuration window

Now the importer window won’t open for this file-type. To restore this, simply untick ‘Windowless”  
  
  
  
Output files
-----
Files are put into a results directory called 'Results_<date&time>' within the chosen working directory. 
Files will be saved as either a .tif or .txt for the log file. Original filenames are kept and have tags appended to them based upon the chosen parameters.

A text file called log.txt is included which has the chosen parameters and date and time of the run.
A mask of the detected bacteria is saved into the results directory along with the found bacterial ROIs.
An overlay image of the identifed bacteria is also included.
