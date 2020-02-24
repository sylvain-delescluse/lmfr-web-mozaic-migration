<#import "common-macro.ftl" as macros>
<#import "icons.ftl" as icons>

<#--  MOZAIC BUTTON

  <#import "../../macros/common/button.ftl" as button>

  <#assign buttonExample = {
    "type": "submit", // STRING, optionnal - "button" if empty
    "color": "primary-02", // STRING, optionnal - "primary-02", "danger", "neutral"
    "style": "bordered", // STRING, optionnal - "solid" if empty - "bordered"
    "size": "s", // STRING, optionnal - "m" if empty - "s", "l"
    "icon": {
      "iconOnly": true, // BOOLEAN, optionnal
      "id": "Media_Camera_24px" // STRING, mandatory to insert icon
    },
    "cssClass": "myClass", // STRING, optionnal
    "dataTagco": "{'titi' : 'tata', 'tutu' : 'toto'}", // STRING, optionnal
    "dataTcevent": "tc-event-example", // STRING, optionnal
    "cerberus": "BTN_addtocart", // STRING, optionnal
    "dataAttributes": [
        {'name': 'truc', 'value': 'valeur de truc'}, // OBJECT, must contain "name" and "value" keys
        {'name': 'truc2', 'value': 'valeur de truc 2'}
    ]
  }/>

  <@button.buttonMozaic configButton = buttonExample >Button text</@button.buttonMozaic>

-->

<#-- addToCart
  @param {String} type                : Submit by default (Can be button)
  @param {String} wrapperCustomClass  : Class use only for wrapper html tag
  @param {String} customClass         : Unique class for both button and icon /!\ IF YOU NEED MULTIPLE CLASSES USE wrapperCustomClass
  @param {Boolean} displayIcon        : Display Basket icon, by default true
  @param {String} textContent         : Text of button, by default "Ajouter au panier"
  @param {Object} dataTagco           : data tag commander
  @param {String} dataTcevent         : data tc-event
  @param {String} cerberus            : data cerberus

  How to use :

  Default display :
  <@button.addToCart />

  Will generate :
  <button type="submit" class="ka-button js-cart-add">
  <svg class="ku-icon-48 ka-button__icon"><use xlink:href="#Product_Basket_Add_48px" href="#Product_Basket_Add_48px"></use></svg>
  Ajouter au panier
  </button>

  Custom display :
  <#assign buttonConfig = {
    "type" : "button",
    "wrapperCustomClass" : "parent classes" //multiple classes,
    "customClass" : "my-class" //unique classe,
    "textContent" : "",
    "dataTagco"   : "{'titi' : 'tata', 'tutu' : 'toto'}", //optional
    "dataTcevent" : "tc-event-example", //optional
    "cerberus"    : "BTN_addtocart", // optional
    "dataAttributes" : [
      {
        "name" : "merch-pos",
        "value" : "merch position value"
      }
    ] //optional

  } />

  <@button.addToCart buttonConfig />

  Will generate :
  <button type="button" class="ka-button js-cart-add parent classes my-class js-tagGA" data-merch-pos="merch position value" data-tagco="{'titi' : 'tata', 'tutu' : 'toto'}" data-tcevent="tc-event-example" data-cerberus="BTN_addtocart">
    <svg class="ku-icon-48 ka-button__icon my-class__icon"><use xlink:href="#Product_Basket_Add_48px" href="#Product_Basket_Add_48px"></use></svg>
  </button>

-->

<#--  Mozaic buttons  -->
<#macro buttonMozaic configButton = {}>
	<@compress single_line=true>
		<#assign prefix = "mc-button" />
		<#assign dataAttr = "" />
		<#assign classes = prefix />

		<#--  Insert symbol first if config contains an icon  -->
		<#if configButton.icon?has_content >
			<@icons.icon iconPath="${configButton.icon.id!}" symbolOnly=true />
		</#if>

		<#--  Build style and color class  -->
		<#if configButton.style?has_content && configButton.color?has_content >
			<#assign classes = classes + " ${prefix}--${configButton.style!}-${configButton.color!}" />
		<#elseif configButton.style?has_content && !configButton.color?has_content >
			<#assign classes = classes + " ${prefix}--${configButton.style!}" />
		<#elseif !configButton.style?has_content && configButton.color?has_content >
			<#assign classes = classes + " ${prefix}--solid-${configButton.color!}" />
		</#if>

		<#--  Add size class  -->
		<#if configButton.size?has_content >
			<#assign classes = classes + " ${prefix}--${configButton.size!}" />
		</#if>

		<#--  Add width class  -->
		<#if configButton.width?has_content >
			<#assign classes = classes + " ${prefix}--${configButton.width!}" />
		</#if>

		<#--  Build icon DOM  -->
		<#if configButton.icon?has_content >
			<#assign iconCode><@icons.icon iconPath="${configButton.icon.id!}" class="mc-button__icon" /></#assign>
		</#if>

		<#--  Add symbol only class  -->
		<#if configButton.icon?has_content && configButton.icon.iconOnly?has_content >
			<#assign classes = classes + " ${prefix}--square" />
		</#if>

  		<#--  Add custom CSS Class  -->
		<#if configButton.cssClass?has_content >
			<#assign classes = classes + " ${configButton.cssClass!}" />
		</#if>

  	<#--  Add button type  -->
		<#if configButton.type?has_content >
			<#assign type = configButton.type />
    <#else>
			<#assign type = "button" />
		</#if>

    <#--  Add DATA: TagCo, TcEvent, Cerberus, custom data attributes  -->
    <#if configButton.dataTagco?has_content>
      <#assign dataAttr = dataAttr + ' data-tagco="${configButton.dataTagco!}"' />
    </#if>
    <#if configButton.dataTcevent?has_content>
      <#assign dataAttr = dataAttr + ' data-tcevent="${configButton.dataTcevent!}"' />
    </#if>
    <#if configButton.cerberus?has_content>
      <#assign dataCerberus> <@macros.cerberus "${configButton.cerberus!}" /></#assign>
      <#assign dataAttr = dataAttr + dataCerberus />
    </#if>
    <#if configButton.dataAttributes?has_content>
      <#list configButton.dataAttributes as attr>
        <#assign dataAttr = dataAttr + ' data-${attr.name!}="${attr.value!}"' />
      </#list>
    </#if>

		<button type="${type!}" class="${classes!}" ${dataAttr!} >
			<#if ( configButton.icon?has_content && !configButton.icon.side?has_content ) || ( configButton.icon?has_content && configButton.icon.side?has_content && configButton.icon.side == "left" ) >${iconCode!}</#if>

			<#if !(configButton.icon?has_content && configButton.icon.iconOnly?has_content) >
				<span class="mc-button__label"><#nested></span>
			</#if>

			<#if configButton.icon?has_content && configButton.icon.side?has_content && configButton.icon.side == "right" >${iconCode!}</#if>
		</button>
	</@compress>
</#macro>

<#macro addToCart config = {}>
  <#compress>

    <#assign defaultOptions = {
        "type"               : "submit",
        "wrapperCustomClass" : "",
        "customClass"        : "",
        "displayIcon"        : true,
        "textContent"        : "Ajouter au panier"
    } />

    <#assign options = {
        "type"               : (config.type)!defaultOptions.type,
        "wrapperCustomClass" : (config.wrapperCustomClass)!defaultOptions.wrapperCustomClass,
        "customClass"        : (config.customClass)!defaultOptions.customClass,
        "displayIcon"        : (config.displayIcon)!defaultOptions.displayIcon,
        "textContent"        : (config.textContent)!defaultOptions.textContent,
        "dataAttributes"     : (config.dataAttributesAddToCart)![]
    } />

    <#assign customClassButton = "ka-button js-cart-add ${options.wrapperCustomClass} ${options.customClass}">
    <#assign customClassIcon = "ka-button__icon">

    <#--  Add class BEM for icon if customClass is not empty-->
    <#if (options.customClass)?? && options.customClass != '' && !options.customClass?contains(" ")>
        <#assign customClassIcon = customClassIcon + " ${options.customClass}__icon">
    </#if>

    <button type="${options.type}" class="${customClassButton} js-tagGA"
      <#if (config.dataTagco)??> data-tagco="${config.dataTagco}" </#if>
      <#if (config.dataTcevent)??> data-tcevent="${config.dataTcevent}" </#if>
      <#if (config.cerberus)??> <@macros.cerberus "${config.cerberus}" /> </#if>
      <#list options.dataAttributes as attr> data-${attr.name}=${attr.value} </#list>>
      <#if options.displayIcon>
        <@icons.icon iconPath="Product_Basket_Add_48px" class="${customClassIcon}" />
      </#if>
      ${options.textContent}
    </button>
    <#if options.customClass?contains(" ")>
        <p class='ka-text--micro ka-text--error'><mark>customClass option don't support multiple classes</mark><br> you have to use wrapperCustomClass option.</p>
    </#if>
  </#compress>
</#macro>
