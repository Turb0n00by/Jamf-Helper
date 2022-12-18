#!/bin/bash
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, Professional Services Team. For more
#       information or support for this script, please contact your JAMF Software Account Manager.
#
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   jamfHelperByPolicy.sh
#
# SYNOPSIS - How to use
#   Run via a policy to populate JAMF Helper with values to present messages to the user.
#
# DESCRIPTION
#
#   Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#
####################################################################################################
#
# HISTORY
#
#   Version: 1.0
#
#   - Created by Douglas Worley, Professional Services Engineer, JAMF Software on May 10, 2013
#
#   Version: 1.5
#
#   - Modified by Matthew Durante & Michael Lawson. Nov 23, 2022
#
#   - 
#
####################################################################################################
# The recursively named JAMF Helper help file is accessible at:
# /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help

##Try to get device uptime
dayCount=$( uptime | awk -F "(up | days)" '{ print $2 }' )

if ! [ "$dayCount" -eq "$dayCount" ] 2> /dev/null ; then
    dayCount="0"
fi

##Get Logged in user
LoggedInUser=$(who | awk '/console/{print $1}')
#currentUser=$(osascript -e "long user name of (system info)")
#Jamf Variable currentUser=$(ls -l /dev/console | awk '{ print $3}')
#echo $currentUser

windowType="utility"       #   [hud | utility | fs]
#windowPosition="" #   [ul | ll | ur | lr]
title="Computer Health Check"          #   "string"
heading="Your computer requires a restart"            #   "string" macOS Monterey Upgrade
description="$LoggedInUser Your computer has not been restarted in over $dayCount days. Please restart your machine."
icon="/Library/<img.png>"          #   path
#iconSize=""           #   pixels
#timeout=""            #   seconds 120



[ "$4" != "" ] && [ "$windowType" == "" ] && windowType=$4
#[ "$5" != "" ] && [ "$windowPosition" == "" ] && windowPosition=$5
[ "$6" != "" ] && [ "$title" == "" ] && title=$6
[ "$7" != "" ] && [ "$heading" == "" ] && heading=$7
[ "$8" != "" ] && [ "$description" == "" ] && description=$8
#[ "$9" != "" ] && [ "$icon" == "" ] && icon=$9
#[ "${10}" != "" ] && [ "$iconSize" == "" ] && iconSize=$10
#[ "${11}" != "" ] && [ "$timeout" == "" ] && timeout=${11}


function setSnooze ()
{

#Get the time right now in Unix seconds
timeNow=$(date +"%s")
echo "$timeNow"
#Calculate the time for the next available display of the prompt (adds the time now and time chosen together in seconds)
timeNextRun=$((timeNow+SnoozeVal))
echo "$timeNextRun"
## Create or update a plist value containing the above next time to run value
/usr/bin/defaults write /Library/Preferences/com.acme.policy_001.snooze.plist DelayUntil -integer $timeNextRun
exit 0

}


function showPrompt1 ()
{


## Prompt, and capture the output
HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -title "$title" -heading "$heading" -description "$description" -icon "$icon" -button1 "Restart" -button2 "Snooze" -cancelButton "2" -countdown "$timeout" -timeout "1800" -showDelayOptions "1800, 2700")
##OG
#HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" -heading "$heading" -description "$description"  -icon "$icon" -iconSize "$iconSize" -button1 Install Now -button2 Snooze -defaultButton 2 -cancelButton "2" -countdown "$timeout" -timeout "$timeout" -showDelayOptions "900, 1800, 3600, 7200, 14400")

echo "jamf helper result was $HELPER"

## Dissect the response to get just the button clicked and the value selected from the drop down menu
ButtonClicked="${HELPER: -1}"
SnoozeVal="${HELPER%?}"

echo "$ButtonClicked"
echo "$SnoozeVal"

if [ "$ButtonClicked" == "1" ]; then
    echo "User chose restart"
    /usr/local/bin/jamf recon -verbose
    /usr/local/bin/jamf reboot -minutes 1 -message "Your device will restart in 1 minute" -startTimerImmediately 
elif [ "$ButtonClicked" == "2" ]; then
    echo "User chose Snooze"
    touch /tmp/1
    
    setSnooze
fi


}

function showPrompt2 ()
{

## Prompt, and capture the output
HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -title "$title" -heading "$heading" -description "$description" -icon "$icon" -button1 "Restart" -button2 "Snooze" -cancelButton "2" -countdown "$timeout" -timeout "1800" -showDelayOptions "1800, 2700")
##OG
#HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" -heading "$heading" -description "$description"  -icon "$icon" -iconSize "$iconSize" -button1 Install Nowâ€ -button2 Snooze -defaultButton 2 -cancelButton "2" -countdown "$timeout" -timeout "$timeout" -showDelayOptions "900, 1800, 3600, 7200, 14400")

echo "jamf helper result was $HELPER"

## Dissect the response to get just the button clicked and the value selected from the drop down menu
ButtonClicked="${HELPER: -1}"
SnoozeVal="${HELPER%?}"

echo "$ButtonClicked"
echo "$SnoozeVal"

if [ "$ButtonClicked" == "1" ]; then
    echo "User chose Restart"
    /usr/local/bin/jamf recon -verbose
    /usr/local/bin/jamf reboot -minutes 1 -message "Your device will restart in 1 minute" -startTimerImmediately 
elif [ "$ButtonClicked" == "2" ]; then
    echo "User chose Snooze twice"
    touch /tmp/2

    setSnooze
fi

}

function showPrompt3 ()
{

## Prompt, and capture the output
HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -title "$title" -heading "$heading" -description "$description" -icon "$icon" -button1 "Restart" -button2 "Snooze" -cancelButton "2" -countdown "$timeout" -timeout "1800" -showDelayOptions "1800, 2700")
##OG
#HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" -heading "$heading" -description "$description"  -icon "$icon" -iconSize "$iconSize" -button1 Install Nowâ€ -button2 Snooze -defaultButton 2 -cancelButton "2" -countdown "$timeout" -timeout "$timeout" -showDelayOptions "900, 1800, 3600, 7200, 14400")

echo "jamf helper result was $HELPER"

## Dissect the response to get just the button clicked and the value selected from the drop down menu
ButtonClicked="${HELPER: -1}"
SnoozeVal="${HELPER%?}"

echo "$ButtonClicked"
echo "$SnoozeVal"

if [ "$ButtonClicked" == "1" ]; then
    echo "User chose Restart"
    /usr/local/bin/jamf recon -verbose
    /usr/local/bin/jamf reboot -minutes 1 -message "Your device will restart in 1 minute" -startTimerImmediately
elif [ "$ButtonClicked" == "2" ]; then
    echo "User Chose snooze - last run"
    touch /tmp/3
    
    setSnooze
fi

}

function showPrompt4 ()
{

## Prompt, and capture the output
HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -title "$title" -heading "Device restart will be enforced" -description "Your machine will restart in a couple minutes. Please save all of your work and plug device into power now." -icon "/Library/Northern/NT_Logo.png" -button1 "Restart" -countdown -timeout "60" -defaultButton "2" ) #-button2 "Snooze" -countdown "$timeout" -timeout "$timeout" -showDelayOptions "90, 180, 3600, 7200, 14400")
##OG
#HELPER=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" -heading "$heading" -description "$description"  -icon "$icon" -iconSize "$iconSize" -button1 Install Nowâ€ -button2 Snooze -defaultButton 2 -cancelButton "2" -countdown "$timeout" -timeout "$timeout" -showDelayOptions "900, 1800, 3600, 7200, 14400")

echo "jamf helper result was $HELPER"

## Dissect the response to get just the button clicked and the value selected from the drop down menu
ButtonClicked="${HELPER: -1}"
SnoozeVal="${HELPER%?}"

echo "$ButtonClicked"
echo "$SnoozeVal"

###Buttons not used here- just clean up after yourself!
if [ "$ButtonClicked" == "1" ]; then
    echo "Device is being restarted"
    #/usr/local/bin/jamf recon -verbose
    /usr/local/bin/jamf reboot -message "Your device will restart in a moment" -immediately
    rm -R /tmp/1
    rm -R /tmp/2
    rm -R /tmp/3
elif [ "$ButtonClicked" == "2" ]; then
    echo "Device is being restarted"
    #/usr/local/bin/jamf recon -verbose
    /usr/local/bin/jamf reboot -message "Your device will restart in a moment" -immediately
    rm -R /tmp/1
    rm -R /tmp/2
    rm -R /tmp/3

    setSnooze
fi

}

function FunctionCallTimer ()
{
##Check if the Prompt 1 has been run and tagged
if [ -e "/tmp/1" ]; then
    echo "User Snoozed Once"
    
else
    ## If none of the txt files exist we'll assume the policy has never started
    echo "Process not started yet, call restart script"
    showPrompt1
    
fi


echo "Check for Flag 2"
##Check for Flag 2
if [ -e "/tmp/2" ]; then
    echo "User Snoozed twice"
    
else
    echo "Missing Tag 2 calling Prompt 2"
    showPrompt2
fi

##Enforce this OS upgrade!
echo "Check for Flag 3"
if [ -e "/tmp/3" ]; then
    echo "Flag 3 present, enforcing restart"
    showPrompt4
else
    echo "Calling final prompt missing Flag 3"
    showPrompt3
fi

}



## Get a value (if possible) from a plist of the next valid time we can prompt the user
SnoozeValueSet=$(/usr/bin/defaults read /Library/Preferences/com.acme.policy_001.snooze.plist DelayUntil 2>/dev/null)

## If we got something from the plist...
if [ -n "$SnoozeValueSet" ]; then
    ## See what time it is now, and compare it to the value in the plist.
    ## If the time now is greater or equal to the value in the plist, enough time has elapsed, so...
    timeNow=$(date +"%s")
    if [[ "$timeNow" -ge "$SnoozeValueSet" ]]; then
        ## Display the prompt to the user again
        FunctionCallTimer
    else
        ## If the time now is less than the value in the plist, exit
        echo "Not enough time has elapsed. Exiting..."
        exit 0
    fi
else
    ## If no value was in the plist or the plist wasn't there, assume it is the first run of the script and prompt them
    #getdeviceUpTime 
    FunctionCallTimer 
fi