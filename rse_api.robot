*** Settings ***
Library    Browser
Library    Collections
Library    String
Library    ExcelLibrary
Library    DebugLibrary
Library    ScreenCapLibrary
Library    RapportRSELibrary.py

Variables    liste_url_api.yaml

Suite Setup       Initialisation du robot
Test Setup        Initialisation du cas de test
Test Teardown     Fin du cas de test
Suite Teardown    Fermeture des navigateurs

*** Keywords ***
Initialisation du robot
    Browser.Set Browser Timeout                                timeout=60 sec
    Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}
    ...                                                        0
    RapportRSELibrary.Creer Le Fichier De Rapport              fichier_sortie=rapport/rapport_api.xlsx

Fermeture des navigateurs
    RapportRSELibrary.Initialiser Tableau Campagne De Tests    fichier_sortie=rapport/rapport_api.xlsx
    RapportRSELibrary.Renseigner Tableau Campagne De Tests     fichier_sortie=rapport/rapport_api.xlsx
    ...                                                        nom_de_la_campagne_de_tests=${SUITE_NAME}
    ...                                                        consommation_de_la_campagne_de_tests=${consommation_co2_campagne_de_tests}
    Browser.Close Browser

Initialisation du cas de test
    Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    ...                                                        0
    RapportRSELibrary.Initialiser Tableau Cas De Test          fichier_sortie=rapport/rapport_api.xlsx
    ...                                                        titre_cas_de_test=${TEST_NAME}

Fin du cas de test
    RapportRSELibrary.Initialiser Tableau Cas De Test Total    fichier_sortie=rapport/rapport_api.xlsx
    RapportRSELibrary.Renseigner Tableau Cas De Test Total     fichier_sortie=rapport/rapport_api.xlsx
    ...                                                        titre_cas_de_test=${TEST_NAME}
    ...                                                        consommation_co2_total=${consommation_co2_cas_de_test}
    Sleep    time_=5
    Browser.Close Browser

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
    ${resultat.body}                                           Recuperer consommation CO2 de la page    
    ...                                                        url_a_controler=${url_a_controler}
    ${resultat_proprete}                                       Builtin.Evaluate
    ...                                                        100 * ${resultat.body}[cleanerThan]
    ${consommation_co2_cas_de_test}                            Builtin.Evaluate
    ...                                                        ${consommation_co2_cas_de_test} + ${resultat.body}[statistics][co2][grid][grams]
    ${consommation_co2_campagne_de_tests}                      Builtin.Evaluate
    ...                                                        ${consommation_co2_campagne_de_tests} + ${resultat.body}[statistics][co2][grid][grams]
    RapportRSELibrary.Renseigner Tableau Cas De Test           fichier_sortie=rapport/rapport_api.xlsx
    ...                                                        url=${url_a_controler}    
    ...                                                        proprete=${resultat_proprete}
    ...                                                        consommation_co2=${consommation_co2_cas_de_test}
    Builtin.Set Suite Variable                                 ${consommation_co2_campagne_de_tests}    
    Builtin.Set Test Variable                                  ${consommation_co2_cas_de_test}
    RETURN    ${consommation_co2_cas_de_test}     ${consommation_co2_campagne_de_tests}

Enregistrer consommation de la liste url
    [Arguments]    ${liste_url}
    FOR    ${url}    IN    @{liste_url}
        Enregistrer consommation de la page                    url_a_controler=${url}
    END

*** Test Cases ***
Cas de test 1
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_1}

Cas de test 2
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_2}

Cas de test 3
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_3}

Cas de test 4
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_4}

Cas de test 5
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_5}

Cas de test 6
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_6}

Cas de test 7
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_7}

Cas de test 8
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_8}

Cas de test 9
    Enregistrer consommation de la liste url    liste_url=@{liste_url_cas_de_test_9}
