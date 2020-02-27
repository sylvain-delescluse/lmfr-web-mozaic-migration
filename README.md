# LMFR tool for Mosaic migration

### Introduction

We need to replace links and buttons with new Mosaic freemarker macros.

#### Pour les "Button"

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

Le lien vers la doc. du socle pour les boutons :
https://adeo.github.io/integration-web-core--socle/Components/buttons/freemarker/

#### Pour les "Link"

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

Le lien vers la doc. du socle pour les liens :
https://adeo.github.io/integration-web-core--socle/Components/links/freemarker/


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
