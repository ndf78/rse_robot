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
    Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}
    ...                                                        0
    RapportRSELibrary.Creer Le Fichier De Rapport              fichier_sortie=rapport/rapport_ihm.xlsx

Fermeture des navigateurs
    RapportRSELibrary.Initialiser Tableau Campagne De Tests    fichier_sortie=rapport/rapport_ihm.xlsx
    RapportRSELibrary.Renseigner Tableau Campagne De Tests     fichier_sortie=rapport/rapport_ihm.xlsx
    ...                                                        nom_de_la_campagne_de_tests=${SUITE_NAME}
    ...                                                        consommation_de_la_campagne_de_tests=${consommation_co2_campagne_de_tests}
    Browser.Close Browser

Initialisation du cas de test
    Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    ...                                                        0
    RapportRSELibrary.Initialiser Tableau Cas De Test          fichier_sortie=rapport/rapport_ihm.xlsx
    ...                                                        titre_cas_de_test=${TEST_NAME}

Fin du cas de test
    RapportRSELibrary.Initialiser Tableau Cas De Test Total    fichier_sortie=rapport/rapport_ihm.xlsx
    RapportRSELibrary.Renseigner Tableau Cas De Test Total     fichier_sortie=rapport/rapport_ihm.xlsx
    ...                                                        titre_cas_de_test=${TEST_NAME}
    ...                                                        consommation_co2_total=${consommation_co2_cas_de_test}

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
    Browser.Close Page
    RETURN    ${resultat.body}

Enregistrer consommation de la page
    [Arguments]    ${url_a_controler}
    ${resultat.body}                                           Recuperer consommation CO2 de la page    
    ...                                                        url_a_controler=${url_a_controler}
    ${resultat_proprete}                                       Builtin.Evaluate
    ...                                                        100 * ${resultat.body}[cleanerThan]
    ${consommation_co2_cas_de_test}                            Builtin.Evaluate
    ...                                                        ${consommation_co2_cas_de_test} + ${resultat.body}[statistics][co2][grid][grams]
    ${consommation_co2_campagne_de_tests}                      Builtin.Evaluate
    ...                                                        ${consommation_co2_campagne_de_tests} + ${resultat.body}[statistics][co2][grid][grams]
    RapportRSELibrary.Renseigner Tableau Cas De Test           fichier_sortie=rapport/rapport_ihm.xlsx
    ...                                                        url=${url_a_controler}    
    ...                                                        proprete=${resultat_proprete}
    ...                                                        consommation_co2=${consommation_co2_cas_de_test}
    Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}    
    Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    RETURN    ${consommation_co2_cas_de_test}     ${consommation_co2_campagne_de_tests}

Accepter les cookies - Ausy
    Browser.Click                                              selector=//button[@id="onetrust-accept-btn-handler"]

Accepter les cookies - Amazon
    Browser.Click                                              selector=//input[@id="sp-cc-accept"]

Acceder a la page "Carrieres"
    Browser.Click                                              selector=//li[@class="navigation__menu-item"]//a[@href="/fr/carrieres/"]
    ${url}                                                     Browser.Get Url
    Enregistrer consommation de la page                        url_a_controler=${url}

Connexion au site
    [Arguments]    ${url}    ${headless}
    Browser.New Browser                                        browser=chromium
    ...                                                        headless=${headless}
    ...                                                        channel=chrome
    Browser.New Page                                           url=${url}
    Enregistrer consommation de la page                        url_a_controler=${url}

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
    Enregistrer consommation de la page                        url_a_controler=${url}

Se connecter a amazon
    Browser.Click                                              selector=//span[@class="action-inner"]
    Browser.Type Text                                          selector=//input[@id="ap_email"] 
    ...                                                        txt=romuald.classeur@gmail.com
    Browser.Click                                              selector=//input[@id="continue"] 
    Browser.Type Text                                          selector=//input[@id="ap_password"] 
    ...                                                        txt=ausyforever
    Browser.Click                                              selector=//input[@id="signInSubmit"] 
    ${url}                                                     Browser.Get Url
    Enregistrer consommation de la page                        url_a_controler=${url}

*** Test Cases ***
Cas de test 1
    Connexion au site                                          url=${liste_url_cas_de_test_1}[0]
    ...                                                        headless=${False}
    Accepter les cookies - Ausy
    Acceder a la page "Carrieres"
    Renseigner la barre de recherche                           recherche=auto
    Consulter le resultat

Cas de test 2
    Connexion au site                                          url=${liste_url_cas_de_test_2}[0]
    ...                                                        headless=${False}
    Debug
    Accepter les cookies - Amazon
    Acceder a la page "Carrieres"
    Renseigner la barre de recherche                           recherche=auto
    Consulter le resultat


