*** Settings ***
Library    Browser
Library    Collections
Library    OperatingSystem
Library    DebugLibrary
Library    String
Library    RapportLibrary.py

Suite Setup    Configuration du robot
Suite Teardown    Fermeture des navigateurs

*** Keywords ***
Configuration du robot
    Browser.Set Browser Timeout    timeout=30 sec

Fermeture des navigateurs
    Browser.Close Browser

Lister les urls a controler
    [Tags]    log
    ${liste_url_a_controler}    Builtin.Create List     https://www.ausy.fr/fr/
                                ...                     https://www.ausy.fr/fr/nos-solutions/
                                ...                     https://www.impots.gouv.fr/accueil
                                ...                     https://greenpixie.com/website-carbon-calculator
                                ...                     https://www.ausy.fr/fr/secteurs-d-activite/
    RETURN    ${liste_url_a_controler}

Recuperer consommation CO2 de la page
    [Arguments]    ${url_a_controler}
    ${requete_url}                           Builtin.Evaluate    
    ...                                      "https://api.websitecarbon.com/site?url={}".format("${url_a_controler}")
    Browser.New Browser                      browser=chromium
    ...                                      headless=${True}
    ...                                      channel=chrome
    Browser.New Page                         url=${requete_url}
    ${headersDict}                           Builtin.Create Dictionary
    Collections.Set To Dictionary            ${headersDict}
    ...                                      Accept    application/json
    ...                                      Content-Type    application/json
    &{resultat}                              Browser.Http
    ...                                      url=${requete_url}
    ...                                      method=GET
    ...                                      body=${EMPTY}
    ...                                      headers=${headersDict}
    Builtin.Should Be Equal                  first="${resultat.status}"
    ...                                      second="200"
    ...                                      msg=Il y a le message suivant : ${resultat.body}
    Builtin.Log                              ${resultat.status}
    Builtin.Log                              ${resultat.body}
    Browser.Close Browser
    RETURN    ${resultat.body}

Afficher la consommation des sites
    ${liste_url_a_controler}    Lister les urls a controler
    Log To Console    ${liste_url_a_controler}

    ${list_url_co2}         Builtin.Create List
    ${list_url_proprete}    Builtin.Create List

    FOR    ${url}    IN    @{liste_url_a_controler}
        ${resultat.body}    Recuperer consommation CO2 de la page    url_a_controler=${url}
        Log To Console    ${resultat.body}
        ${str_resultat_co2}    Builtin.Convert To String    item=${resultat.body}[statistics][co2][grid][grams]
        ${resultat_proprete}    Builtin.Evaluate    100 * ${resultat.body}[cleanerThan]
        ${str_resultat_proprete}    Builtin.Convert To String    item=${resultat_proprete}
        Collections.Append To List    ${list_url_co2}         ${str_resultat_co2}[0:5]
        Collections.Append To List    ${list_url_proprete}    ${str_resultat_proprete}[0:5]
        RapportLibrary.Generer rapport de la page    url=${url}
        ...                                          proprete=${str_resultat_co2}[0:5]
        ...                                          consommation_co2=${str_resultat_proprete}[0:5]
    END

    ${total}         BuiltIn.Evaluate    ${list_url_co2}[0] + ${list_url_co2}[1] + ${list_url_co2}[2] + ${list_url_co2}[3] + ${list_url_co2}[4]
    ${consommation_co2_total}    BuiltIn.Evaluate    str(${total})

    Log To Console    ${liste_url_a_controler}
    Log To Console    ${list_url_co2}
    Log To Console    ${list_url_proprete}
    Log To Console    ${consommation_co2_total}
    RapportLibrary.Generer synthese    url_1=${liste_url_a_controler}[0]
    ...                                proprete_1=${list_url_proprete}[0]
    ...                                consommation_co2_1=${list_url_co2}[0]
    ...                                url_2=${liste_url_a_controler}[1]
    ...                                proprete_2=${list_url_proprete}[1]
    ...                                consommation_co2_2=${list_url_co2}[1]
    ...                                url_3=${liste_url_a_controler}[2]
    ...                                proprete_3=${list_url_proprete}[2]
    ...                                consommation_co2_3=${list_url_co2}[2]
    ...                                url_4=${liste_url_a_controler}[3]
    ...                                proprete_4=${list_url_proprete}[3]
    ...                                consommation_co2_4=${list_url_co2}[3]
    ...                                url_5=${liste_url_a_controler}[4]
    ...                                proprete_5=${list_url_proprete}[4]
    ...                                consommation_co2_5=${list_url_co2}[4]
    ...                                consommation_co2_total=${consommation_co2_total}


*** Test Cases ***
Verifier la consommation CO2 des sites
   Afficher la consommation des sites
