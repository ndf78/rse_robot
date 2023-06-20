*** Settings ***
Library    Browser
Library    Collections
Library    String
Library    ExcelLibrary
Library    DebugLibrary
Library    ScreenCapLibrary
Library    RapportRSELibrary.py

Variables    liste_url_ihm.yaml

Suite Setup       Initialisation du robot
Test Setup        Initialisation du cas de test
Test Teardown     Fin du cas de test
Suite Teardown    Fermeture des navigateurs

*** Keywords ***
Initialisation du robot
    Browser.Set Browser Timeout                                timeout=60 sec
    # Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}
    # ...                                                        0
    # RapportRSELibrary.Creer Le Fichier De Rapport              fichier_sortie=rapport/rapport_ihm.xlsx

Fermeture des navigateurs
    # RapportRSELibrary.Initialiser Tableau Campagne De Tests    fichier_sortie=rapport/rapport_ihm.xlsx
    # RapportRSELibrary.Renseigner Tableau Campagne De Tests     fichier_sortie=rapport/rapport_ihm.xlsx
    # ...                                                        nom_de_la_campagne_de_tests=${SUITE_NAME}
    # ...                                                        consommation_de_la_campagne_de_tests=${consommation_co2_campagne_de_tests}
    Browser.Close Browser

Initialisation du cas de test
    ScreenCapLibrary.Start Video Recording                     alias=none
    ...                                                        name=${EXECDIR}/videos/${TEST NAME}
    ...                                                        fps=None
    ...                                                        size_percentage=1  
    ...                                                        embed=True   
    ...                                                        embed_width=100px   
    ...                                                        monitor=1
    # Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    # ...                                                        0
    # RapportRSELibrary.Initialiser Tableau Cas De Test          fichier_sortie=rapport/rapport_ihm.xlsx
    # ...                                                        titre_cas_de_test=${TEST_NAME}

Fin du cas de test
    # RapportRSELibrary.Initialiser Tableau Cas De Test Total    fichier_sortie=rapport/rapport_ihm.xlsx
    # RapportRSELibrary.Renseigner Tableau Cas De Test Total     fichier_sortie=rapport/rapport_ihm.xlsx
    # ...                                                        titre_cas_de_test=${TEST_NAME}
    # ...                                                        consommation_co2_total=${consommation_co2_cas_de_test}
    Sleep    time_=5
    Browser.Close Browser
    ScreenCapLibrary.Stop Video Recording

Recuperer consommation CO2 de la page
    [Tags]    log
    [Arguments]    ${url_a_controler}
    ${requete_url}                                             Builtin.Evaluate    
    ...                                                        "https://api.websitecarbon.com/site?url={}".format("${url_a_controler}")
    Browser.New Page                                           url=${requete_url}
    ${headersDict}                                             Builtin.Create Dictionary
    Collections.Set To Dictionary                              ${headersDict}
    ...                                                        Accept    application/json
    ...                                                        Content-Type    application/json
    &{resultat}                                                Browser.Http
    ...                                                        url=${requete_url}
    ...                                                        method=GET
    ...                                                        body=${EMPTY}
    ...                                                        headers=${headersDict}
    Builtin.Should Be Equal                                    first="${resultat.status}"
    ...                                                        second="200"
    ...                                                        msg=Il y a le message suivant : ${resultat.body}
    Builtin.Log                                                ${resultat.status}
    Builtin.Log                                                ${resultat.body}
    RETURN    ${resultat.body}
    [Teardown]        Browser.Close Page

Enregistrer consommation de la page
    [Arguments]    ${url_a_controler}
    # ${resultat.body}                                           Recuperer consommation CO2 de la page    
    # ...                                                        url_a_controler=${url_a_controler}
    # ${resultat_proprete}                                       Builtin.Evaluate
    # ...                                                        100 * ${resultat.body}[cleanerThan]
    # ${consommation_co2_cas_de_test}                            Builtin.Evaluate
    # ...                                                        ${consommation_co2_cas_de_test} + ${resultat.body}[statistics][co2][grid][grams]
    # ${consommation_co2_campagne_de_tests}                      Builtin.Evaluate
    # ...                                                        ${consommation_co2_campagne_de_tests} + ${resultat.body}[statistics][co2][grid][grams]
    # RapportRSELibrary.Renseigner Tableau Cas De Test           fichier_sortie=rapport/rapport_ihm.xlsx
    # ...                                                        url=${url_a_controler}    
    # ...                                                        proprete=${resultat_proprete}
    # ...                                                        consommation_co2=${consommation_co2_cas_de_test}
    # Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}    
    # Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    ${url_custom1}    String.Replace String    string=${url_a_controler}    search_for=https://    replace_with=''
    ${url_custom2}    String.Replace String    string=${url_custom1}    search_for=/    replace_with=_
    RapportRSELibrary.Executer Lighthouse    url=${url_a_controler}    sortie=${EXECDIR}/rapport/${url_custom2}
    # RETURN    ${consommation_co2_cas_de_test}     ${consommation_co2_campagne_de_tests}

Accepter les cookies - Ausy
    Browser.Click                                              selector=//button[@id="onetrust-accept-btn-handler"]

Accepter les cookies - Amazon
    Browser.Click                                              selector=//input[@id="sp-cc-accept"]

Acceder a la page "Carrieres"
    Browser.Click                                              selector=//li[@class="navigation__menu-item"]//a[@href="/fr/carrieres/"]
    ${url}                                                     Browser.Get Url
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Ausy_page_Carrieres

Acceder a la page "Vente Flash"
    Browser.Click    selector=//a[@href="/deals?ref_=nav_cs_gb"]
    ${url}                                                     Browser.Get Url
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Amazon_page_Ventes_flash

Acceder a la page "Votre compte"
    Browser.Click                                             selector=//a[@id="nav-link-accountList"]
    ${url}                                                     Browser.Get Url
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Amazon_page_Votre_compte

Acceder a la page "Vos commandes"
    Browser.Click                                              selector=//div[@class="ya-card-cell"]//div[@data-card-identifier="YourOrders_C"]
    ${url}                                                     Browser.Get Url
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Amazon_page_Vos_commandes

Cliquer sur un produit
    Browser.Click    selector=(//div[@data-testid="deal-card"])[2]
    ${url}                                                     Browser.Get Url
    ${cookies}        Browser.Get Cookies
    Debug
    ${url_custom1}    String.Replace String    string=${url}    search_for=https://    replace_with=''
    ${url_custom2}    String.Replace String    string=${url_custom1}    search_for=/    replace_with=_
    RapportRSELibrary.Executer Lighthouse Avec Identifiant    url=${url}    option=${cookies}[7]    sortie=${EXECDIR}/rapport/${url_custom2}
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Amazon_page_Produit

Connexion au site
    [Arguments]    ${url}    ${headless}
    Browser.New Browser                                        browser=chromium
    ...                                                        headless=${headless}
    ...                                                        channel=chrome
    Browser.New Context                                        viewport={'width': 1920, 'height': 1080}
    Browser.New Page                                           url=${url}
    Enregistrer consommation de la page                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Page_accueil_{index}

Renseigner la barre de recherche
    [Arguments]    ${recherche}
    Browser.Type Text                                          selector=//input[@id="search-keyword"]
    ...                                                        txt=${recherche}

Consulter le resultat
    Browser.Click                                              selector=(//form[@id="header-search-form"]//button)[1]
    Browser.Wait For Elements State                            selector=(//span[@class="dots"])[1]
    ...                                                        state=attached
    ...                                                        timeout=60
    ${url}                                                     Browser.Get Url
    Builtin.Run Keyword And Continue On Failure                Enregistrer consommation de la page
    ...                                                        url_a_controler=${url}
    Browser.Take Screenshot                                    filename=${EXECDIR}/images/Ausy_page_Resultat_recherche.png

Se connecter a amazon
    Browser.Click                                              selector=//span[@id="gw-sign-in-button"]
    Browser.Type Text                                          selector=//input[@id="ap_email"]
    ...                                                        txt=romuald.classeur@gmail.com
    Browser.Click                                              selector=//input[@id="continue"]
    Browser.Type Text                                          selector=//input[@id="ap_password"]
    ...                                                        txt=ausyforever
    Browser.Click                                              selector=//input[@id="signInSubmit"]


*** Test Cases ***
# Cas de test 1
    # Connexion au site                                          url=${liste_url_cas_de_test_1}[0]
    # ...                                                        headless=${False}
    # Accepter les cookies - Ausy
    # Acceder a la page "Carrieres"
    # Renseigner la barre de recherche                           recherche=auto
    # Consulter le resultat

Cas de test 2
    Connexion au site                                          url=${liste_url_cas_de_test_2}[0]
    ...                                                        headless=${False}
    Accepter les cookies - Amazon
    Se connecter a amazon
    Acceder a la page "Vente Flash"
    Cliquer sur un produit
    Acceder a la page "Votre compte"
    Acceder a la page "Vos commandes"

