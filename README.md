# LMFR tool for Mosaic migration

### Introduction

We need to replace links and buttons with new Mosaic freemarker macros.

### Installation

First, clone this repository.

#### Requirements

You need to have NodeJS

https://nodejs.org/fr/


#### Step 1 : Install dependencies

Go in this directory and install required node packages
```
npm install
```

#### Step 2 : Symlink

To prepare symlink, do :
```
sudo npm link
```

Now you can directly use "lm-mosaic" command from the other project


#### Step 3 : Use

After the symlink done, go in the target directory and do :
```
lm-mosaic
```
A prompt will ask you to choose the "link" or "button" and the extension "ftl" or "ftlh".

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
Maybe you will need to install "gulp" globally with :
```
npm install -g gulp
```

Test the app on local test files :
```
npm start
```

### About "bin" system

If you work on the "bin" system, maybe you should unlink and link again
