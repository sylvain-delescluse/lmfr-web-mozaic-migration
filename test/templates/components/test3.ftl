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
                <a href="/espace-perso/fidelite/ma-carte_5" class="ka-button">Autre lien 5</a>
            </div>
        </div>
    </section>

    <section>
        <a href="/espace-perso/fidelite/ma-carte-6" class="ka-button">Autre lien 6</a>
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
            <a href="#" data-target="js-my-popin-fidNotActive" class="js-show-popin class-test-3">
                <@icons.icon iconPath="Navigation_Notification_Information_24px" class="m-discount__ico" />
            </a>
        </div>
    </div>

    <div class="l-myCard__inner">
        <p class="l-myCard__text"><@icons.icon iconPath="User_Card_LoyaltyCard_48px" class="l-myCard__picto"/> Ma Carte Maison</p>
        <a href="/v3/compteinternaute/espaceperso/cartemaison/macarte.do" class="l-myCard__link">Consulter mes avantages <@icons.icon iconPath="Navigation_Arrow_Arrow--Right_32px" class="l-myCard__arrow"/></a>
    </div>

    <div>
        <a href="https://m1.lmcdn.fr/media/15/5e37ee987eb45f518507d94e/175899224/nouvel-emmenage5e37ee98de91bb0008f1209d.pdf" target="_blank" class="ka-link">
            Je découvre les avantages <@icons.icon iconPath="Navigation_Arrow_Arrow--Right_24px" class="m-loyaltyCard__linkArrow"/>
        </a>
    </div>
</div>