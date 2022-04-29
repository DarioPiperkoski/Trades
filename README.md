## Installing Trades using a Scratch Org

#### 1. Login to your DevHub

```sfdx auth:web:login -d -a myhuborg```

#### 2. Clone this repository:

```git clone https://github.com/DarioPiperkoski/Trades```

#### 3. Create a scratch org and provide it with an alias (trades in the command below):

```sfdx force:org:create -s -f config/project-scratch-def.json -a trades```

#### 4. Push the app to your scratch org:

```sfdx force:source:push```

#### 5. Assign the trades permission set to the default user:

```sfdx force:user:permset:assign -n trades```

#### 6. Open the scratch org

```sfdx force:org:open```

#### 7. In App Launcher, select the Ebury app and open the Trades tab (Second).
