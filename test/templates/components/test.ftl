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
                <a href="/espace-perso/fidelite/ma-carte" class="ka-button">Revenir à ma fidélité</a>
            </div>
        </div>
    </section>

    <section>
        <a href="/espace-perso/fidelite/ma-carte-2" class="ka-button">Autre lien</a>
    </section>
</div>