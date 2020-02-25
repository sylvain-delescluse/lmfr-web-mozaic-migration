<#import "../../macros/common/data_layer.ftl" as tc>

<div id="component-donationConfirmation" class="component-donationConfirmation" <@tc.tcVars/>>

    <#--  Titre de la page  -->
    <section class="col-container-inner">
        <div class="col-s-12 col-m-10 col-start-s-1 col-start-m-2 m-confirmation-validated">
            <h1 class="m-confirmation-validated__title ka-title-bold-xxl">Félicitations</h1>

            <div class="m-confirmation-validated">
                <img class="m-confirmation-validated__img" src="/static/img/04_Dons_points-Confirmation.png" />

                <p class="m-confirmation-validated__text ka-title-bold-m">Votre ami(e) vient de recevoir 1000 points ! </p>
                <p class="m-confirmation-validated__legend">Il peut dès maintenant profiter d’une remise de 10%  sur ses prochains achats en ligne ou en magasin.</p>
            </div>

            <div class="m-button-container mu-mt-100">
                <a href="/espace-perso/fidelite/ma-carte_3" class="ka-button">Autre lien 3</a>
            </div>
        </div>
    </section>

    <section>
		<a href="/espace-perso/fidelite/ma-carte-4" class="ka-button">Autre lien 4 (tabs)</a>
    </section>

    <#--  Remise 0 pts ou remise x pts / 1000 -->
    <div class="m-discount__box m-discount__box${class} ${isHidden}">
        <div class="m-discount__info">
        <#if loyalty.missingPointsBeforeNextDiscount! == 1000 || loyalty.isExpired>
            <p class="a-picto-discount a-picto-discount--isNotActive">10<span>%</span></p>
        <#else>
            ${isComing!}
        </#if>
            <div class="m-discount__content">
                <p class="m-discount__title"><@icons.icon iconPath="Universe_Security_32px"/>Remise de Fidélité</p>
                <span class="m-discount__text">Encore ${loyalty.missingPointsBeforeNextDiscount!} pts pour en bénéficier.</span>
                <span class="m-discount__pts">1pt = 1,5 € dépensés</span>
            </div>
            <a href="#" data-target="js-my-popin-fidNotActive" class="js-show-popin class-test-2"><@icons.icon iconPath="Navigation_Notification_Information_24px" class="m-discount__ico" />right text test</a>
        </div>
    </div>

    <#if !hasValidLoyaltyCard && !isReadherable>
        <a href="/fidelite/adhesion/mesdonnees?type=1" class="ka-button ka-button--full" data-target="js-my-popin-fidNotActive" data-target2="js-my-popin-fidNotActive2" data-cerberus="BTN_adhererEnLigne">Adhérer à la Carte Maison 1 an</a>
    </#if>
</div>