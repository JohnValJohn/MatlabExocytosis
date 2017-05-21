//We start by duplicating the stack and renaming it
run("Duplicate...", "title=[myStack] duplicate");
newImage("ProcessedStack", "32-bit black", 512, 512, 1); // I am creating an image here to be able to concatenate even on the first run of the loop

selectWindow("myStack");// I select the window before the loop to be able to use nSlices
n=nSlices()-10;
for (i=1; i<=n; i++){  
	selectWindow("myStack");
	run("Z Project...", "start="+i+" stop=" + (i+9) +" projection=[Average Intensity]");
	selectWindow("myStack");
	setSlice(i+10);
	imageCalculator("Subtract create 32-bit", "myStack","AVG_myStack"); // image1 minus image2
	rename("subtracted");
	selectWindow("AVG_myStack");
	close();
	run("Concatenate...", "  title=[ProcessedStack] image1=[ProcessedStack] image2=[subtracted] image3=[-- None --]");
}

