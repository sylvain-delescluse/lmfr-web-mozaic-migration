# LMFR tool for Mosaic migration

## Introduction

We need to replace links and buttons with new Mosaic freemarker macros.

### For "Button"

```
<#--  File to import  -->
<#import "../../macros/common/button.ftl" as button>

<#--  The Button macro  -->
<#assign buttonConfig = {
    "color": "primary-02",
    "size": "s"
}/>
<@button.buttonMozaic buttonConfig >Button text</@button.buttonMozaic>
```

Button documentation :
https://adeo.github.io/integration-web-core--socle/Components/buttons/freemarker/

### For "Link"

```
<#--  File to import  -->
<#import "../../macros/common/link.ftl" as link>

<#--  The Link macro  -->
<#assign linkConfig = {
    "href": "/my-component",
    "color": "primary-02"
}/>
<@link.linkMozaic linkConfig >Link text</@link.linkMozaic>
```

Link documentation :
https://adeo.github.io/integration-web-core--socle/Components/links/freemarker/


## Installation


### Requirements

You need to have NodeJS

https://nodejs.org/fr/


### Step 1 : Install

Clone this repository.
Go in this directory and install required node packages
```
npm install
```

### Step 2 : Symlink

To prepare symlink, do :
```
npm link
```

Now you can directly use "lm-mosaic" command from the other project

## Step 3 : Launch

After the symlink done, go in a Kobi module directory.

1. Check your "socle" version and upgrade if needed.
(Remove node_modules and src/main/resources/templates/macros directories)

2. Why not do a new branch and clean your project.

3. Launch the script :

```
lm-mosaic
```

A prompt will ask you to choose the "link" or "button" and the extension "ftl" or "ftlh".
4. Check all the updated files, and the result on your "dev" env.

5. Git Commit, Push, etc.

## Build / Dev

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
