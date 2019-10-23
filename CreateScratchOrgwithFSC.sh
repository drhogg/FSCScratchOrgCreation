ECHO "%%%%%%%%%%%%%%% Welcome to TDWealth scratch org creater.  Would you like to continue to authenicate to the DevHub?"

function installPackage
{
	ECHO "++++++++++++++++++>>>>>>>>>>>Parameter #1 is $1 and #2 is $2 and #3 is $3"
	ECHO "===>> $3 begin install"

	finServExtResult="$(sfdx force:package:install --package $1 --targetusername $2; )"		
	ECHO "===>>> Finserv result is: $finServExtResult"
	
	searchStringExt="sfdx"
	extStatus=${finServExtResult#*$searchStringExt} # everything after "status using " will be inserted into temp
	extStatus="sfdx$extStatus" #put sfdx back on string

	counter=1
		ECHO "===>>> Waiting for $3 + === ext status id $extStatus  "
		
	while true
		do
		ECHO "interaction count =  $counter"
		extResult="$($extStatus)"
			#if [ $Result ]; then
			timestamp
			ECHO "=====>>> inside if 1and exResult is:  $extResult"
			ECHO "=====>>> inside if 1 and exStatus is:  $extStatus"
			#if [[ $extResult == *"InProgress"*]]; then
			if [[ $extResult == *"InProgress"* ]]; then
  				ECHO "=====>>> inside if 2 Still Waiting on $3"
  				sleep 10s
  				continue
			elif [[ $extResult == *"Successfully installed"* ]]; then
				ECHO "=====>>> inside elif 1 and exResult is:  $extResult"
				ECHO "=====>>> inside elif 1 and exStatus is:  $extStatus"
				break
			elif [[ $extResult == *"Encountered errors"* ]]; then
				ECHO "=====>>> inside elif 2 and exResult is:  $extResult"
				ECHO "=====>>> inside elif 2 and exStatus is:  $extStatus"
				exit 1
				break
			else
					ECHO "=====>>> inside else 1 and exResult is:  $extResult"
					ECHO "=====>>> inside else 1 and exStatus is:  $extStatus"
				break
			fi			
		#else
			#If error exit script
			#ECHO "====>>> $3  ERROR"
			#ECHO "=====>>> inside else 2 and exResult is:  $extResult"
			#ECHO "=====>>> inside else 2 and exStatus is:  $extStatus"
			#exit 1
		#fi
		counter=$((counter+1))
	done

	ECHO "===>> $3 install finished"

}

timestamp() {
  date +"%T"
}

function validate () {
  if $test -eq 1; then
    echo "OK"
    else echo "ERROR" 
  fi
}




#read -s -p "Continue?: " cont
#echo $cont

#devHubName="DevHubToo"

FSCCloudPkgId="04t1E000000y9lo"  #r220.8.0
FSCCloudExtPkgId="04t1E000001Iql5"  
#FSCCloudExtPkgId="04t80000000pecQAAQ"  #210.0.0.1
FSCCloudExtRefPkgId="04t80000000lTp4"
packageFSC="Financial Services Cloud Package"
packageFSCExt="Financial Services Ext RefPackage"
packageFSCExtRef="Financial Services Ext Ref Package"

read -p "Would you like to continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	read -p "Please enter your devhub username : "  devHubUserName
	read -p "Please enter the name of the DevHub Org you like to authenticate to : "  devHubName
	read -p "Please enter the alias for you scratch org: "  scratchName

	ECHO "**** authenticating to $devHubName"
	sfdx force:auth:web:login -d -a $devHubName

	#if "$(sfdx force:auth:web:login -d -a $devHubName; )"	
	#then
		#continue on
	#	ECHO "Authentication success"
	#else
	#		ECHO "Authentication failed"
	#		exit 1
	#fi

	timestamp
	ECHO "======>	$timestamp Creating TDWealth Scratch Org.."


	# need to replace error handling with if statement containing command to better handle
	fscCloudResult="$(sfdx force:org:create -s -f config/project-scratch-def.json -a $scratchName -u $devHubUserName)"
	

	if [[ $fscCloudResult == *"ERROR"* ]]; then
		ECHO "====>>>>  Scratch Org Creation Failed"
		exit 1
	else 
		ECHO "====>>>>  Scratch Org Creation Succss"
	fi
	






	sleep 5s

	searchString="username: "
	usrName=${fscCloudResult#*$searchString} # everything after "username" will be inserted into temp
	ECHO "===>>> User name is $usrName"


	#testSH "$FSCCloudPkgId" "$usrName"

	timestamp
	###Begin to install FSC Cloud packages
	ECHO "===>>   $packageFSC begin install"
	installPackage  "$FSCCloudPkgId" "$usrName" "$packageFSC"
	ECHO "===>> $packageFSC installed"

	###Begin to install FSC EXT Cloud packages
	timestamp
	ECHO "===>> $packageFSCExt begin install"
	installPackage  "$FSCCloudExtPkgId" "$usrName" "$packageFSCExt"
	ECHO "===>> $packageFSCExt installed"

	timestamp
	###Begin to install FSC EXT REF Cloud packages
	ECHO "===>> $packageFSCExtRef begin install"
	installPackage  "$FSCCloudExtRefPkgId" "$usrName" "$packageFSCExtRef"
	ECHO "===>> $packageFSCExtRef installed"
	sfdx force:org:open -u $usrName
else
	exit 1
fi