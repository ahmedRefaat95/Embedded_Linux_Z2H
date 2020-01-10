#!/bin/bash

#Creating the TRASH directory , if it's already created then the command is ignored
mkdir -p ~/TRASH

#Saving the path in a variable
path=~/TRASH

#checking if files existed for 48 hours in trash to be deleted
find "$path" -type f -atime +2 -exec rm -f {} \;

#checking if the script has been already added to crontab
if crontab -l | grep -q "sdel.sh";
	
then 
	#do nothing
	:
else
	#adding the script to crontab to make the script periodically invoked every 30 mins
	(crontab -l 2>/dev/null; echo "*/30 * * * * sdel.sh") | crontab -
fi	

#looping on all non empty input arguments
for filePassed in "$@"
do 
	#checking if the passed file is already compressed
	if  file "$filePassed" | grep -q "gzip";

		then
		#file is already compressed , moving it to TRASH
		mv $filePassed $path
		echo "$filePassed is already compressed , moved to TRASH!"

	else
		if [[ -d $filePassed ]]; 
		then
			#Compressing the files inside the directory
			gzip -r $filePassed
			#compressing the folder		    
			tar -zcf $filePassed.tar.gz $filePassed
			#moving the compressed folder to TRASH
			mv "$filePassed.tar.gz" $path
			echo "$filePassed compressed successfully and moved to TRASH!"
			#removing the uncompressed folder
			rm -r $filePassed	
		elif [[ -f $filePassed ]]; 
		then
		   #compressing the file
		   gzip $filePassed
		   mv $filePassed* $path
		   echo "$filePassed compressed successfully and moved to TRASH!"		
		else
		    echo "$filePassed does not exist"
		fi
		
	fi		
  	
done
