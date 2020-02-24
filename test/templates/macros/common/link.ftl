<#import "common-macro.ftl" as macros>
<#import "icons.ftl" as icons>

<#--  MOZAIC LINK

  <#import "../../macros/common/link.ftl" as link>

  <#assign linkExample = {
    "href": "/my-component", // STRING, optionnal
    "color": "primary-02", // STRING, optionnal - "light", "primary", "primary-02", "danger"
    "size": "s", // STRING, optionnal - "m" if empty - "s"
    "icon": {
        "side": "right",
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

  <@link.linkMozaic configLink = linkExample >Link text</@link.linkMozaic>

-->

<#--  Mozaic buttons  -->
<#macro linkMozaic configLink = {}>
	<@compress single_line=true>
		<#assign prefix = "mc-link" />
        <#assign dataAttr = "" />
		<#assign classes = prefix />

		<#--  Insert symbol first if config contains an icon  -->
		<#if configLink.icon?has_content >
			<@icons.icon iconPath="${configLink.icon.id!}" symbolOnly=true />
		</#if>

		<#--  Build style and color class  -->
		<#if configLink.color?has_content >
			<#assign classes = classes + " ${prefix}--${configLink.color!}" />
		</#if>

		<#--  Add size class  -->
		<#if configLink.size?has_content >
			<#assign classes = classes + " ${prefix}--${configLink.size!}" />
		</#if>

		<#--  Build icon DOM  -->
		<#if configLink.icon?has_content >
            <#assign iconSideClass = "" />
            <#if !configLink.icon.iconOnly?has_content >
                <#assign iconSideClass = "mc-link__icon--${configLink.icon.side!}" />
            </#if>
			<#assign iconCode><@icons.icon iconPath="${configLink.icon.id!}" class="mc-link__icon ${iconSideClass!}" /></#assign>
		</#if>

  		<#--  Add custom CSS Class  -->
		<#if configLink.cssClass?has_content >
			<#assign classes = classes + " ${configLink.cssClass!}" />
		</#if>

  	    <#--  Add href  -->
		<#if configLink.href?has_content >
			<#assign href = configLink.href />
		</#if>

        <#--  Add DATA: TagCo, TcEvent, Cerberus, custom data attributes  -->
        <#if configLink.dataTagco?has_content>
            <#assign dataAttr = dataAttr + ' data-tagco="${configLink.dataTagco!}"' />
        </#if>
        <#if configLink.dataTcevent?has_content>
            <#assign dataAttr = dataAttr + ' data-tcevent="${configLink.dataTcevent!}"' />
        </#if>
        <#if configLink.cerberus?has_content>
            <#assign dataCerberus> <@macros.cerberus "${configLink.cerberus!}" /></#assign>
            <#assign dataAttr = dataAttr + dataCerberus />
        </#if>
        <#if configLink.dataAttributes?has_content>
            <#list configLink.dataAttributes as attr>
                <#assign dataAttr = dataAttr + ' data-${attr.name!}="${attr.value!}"' />
            </#list>
        </#if>

		<a href="${href!}" class="${classes!}" ${dataAttr!}>
			<#if configLink.icon?has_content && configLink.icon.side?has_content && configLink.icon.side == "left" >${iconCode!}</#if>
			<#if !(configLink.icon?has_content && configLink.icon.iconOnly?has_content) ><#nested></#if>
			<#if configLink.icon?has_content && configLink.icon.side?has_content && configLink.icon.side == "right" >${iconCode!}</#if>
		</a>
	</@compress>
</#macro>
