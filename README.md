Installing Trades using a Scratch Org
Set up your environment. Follow the steps in the Quick Start: Lightning Web Components Trailhead project. The steps include:

Enable Dev Hub in your Trailhead Playground
Install Salesforce CLI
Install Visual Studio Code
Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension
If you haven't already done so, authorize your hub org and provide it with an alias (myhuborg in the command below):

sfdx auth:web:login -d -a myhuborg
Clone this repository:

git clone https://github.com/DarioPiperkoski/Trades
cd trades
Create a scratch org and provide it with an alias (trades in the command below):

sfdx force:org:create -s -f config/project-scratch-def.json -a trades
Push the app to your scratch org:

sfdx force:source:push
Assign the trades permission set to the default user:

sfdx force:user:permset:assign -n trades

sfdx force:org:open
In Setup, under Themes and Branding, activate the Lightning Lite theme.

In App Launcher, select the Ebury app.
