# LMFR tool for Mosaic migration

### Introduction

We need to replace links and buttons with new Mosaic freemarker macros.

### Installation

#### Requirements

You need to have NodeJS

https://nodejs.org/fr/


#### Install dependencies

Install required node packages
```
npm install
```


#### Symlink

First, clone this repository.
To prepare symlink, go in the directory of this project and do :
```
sudo npm link
```

Now you can directly use "lm-mosaic" command from the other project


### Use
After the symlink done, go in the target directory and do :
```
lm-mosaic
```


### Build / Dev
To generate the js file from the coffee file :
```
npm run build
```


You can use gulp too :
```
gulp
```
This command will watch the coffee file.


Test the app on local test files :
```
npm start
```

### About "bin" system
If you work on the "bin" system, maybe you should unlink and link again
