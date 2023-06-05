*** Settings ***
Library    Browser
Library    Collections
Library    String
Library    ExcelLibrary

Variables    liste_url_api.yaml

Suite Setup       Initialisation du robot
Test Setup        Initialisation du cas de test
Test Teardown     Fin du cas de test
Suite Teardown    Fermeture des navigateurs

*** Keywords ***
Initialisation du robot
    Builtin.Set Suite Variable               ${consommation_campagne_de_test}
    ...                                      0
    Builtin.Set Suite Variable               ${excel_numero_de_ligne}       
    ...                                      1
    Builtin.Set Suite Variable               ${excel_nombre_cas_de_test} 
    ...                                      1
    Browser.Set Browser Timeout              timeout=60 sec
    ExcelLibrary.Create Excel Document       doc_id=rapport_api
    ExcelLibrary.Write Excel Cell            row_num=${excel_nombre_cas_de_test}        
    ...                                      col_num=5
    ...                                      value=Cas de test
    ExcelLibrary.Write Excel Cell            row_num=${excel_nombre_cas_de_test}        
    ...                                      col_num=6
    ...                                      value=Consommation C02 total du cas de test (en g)
    ExcelLibrary.Write Excel Cell            row_num=${excel_nombre_cas_de_test}        
    ...                                      col_num=8
    ...                                      value=Campagne de test
    ExcelLibrary.Write Excel Cell            row_num=${excel_nombre_cas_de_test}
    ...                                      col_num=9
    ...                                      value=Consommation CO2 total de la campagne de test (en g)

Fermeture des navigateurs
    ExcelLibrary.Write Excel Cell            row_num=2    
    ...                                      col_num=8
    ...                                      value=${SUITE_NAME}
    ExcelLibrary.Write Excel Cell            row_num=2      
    ...                                      col_num=9
    ...                                      value=${consommation_campagne_de_test}
    ExcelLibrary.Save Excel Document    filename=rapport/rapport_api.xlsx
    ExcelLibrary.Close All Excel Documents
    Browser.Close Browser

Initialisation du cas de test
    ExcelLibrary.Write Excel Cell            row_num=${excel_numero_de_ligne}         
    ...                                      col_num=1
    ...                                      value=${TEST_NAME}
    ExcelLibrary.Write Excel Cell            row_num=${${excel_numero_de_ligne}+1}
    ...                                      col_num=1    
    ...                                      value=url
    ExcelLibrary.Write Excel Cell            row_num=${${excel_numero_de_ligne}+1}    
    ...                                      col_num=2    
    ...                                      value=Proprete du site (en %)
    ExcelLibrary.Write Excel Cell            row_num=${${excel_numero_de_ligne}+1}    
    ...                                      col_num=3    
    ...                                      value=Consommation de CO2 (en g)

Fin du cas de test
    ExcelLibrary.Write Excel Cell            row_num=${${excel_nombre_cas_de_test}+1}
    ...                                      col_num=5
    ...                                      value=${TEST_NAME}
    ExcelLibrary.Write Excel Cell            row_num=${${excel_nombre_cas_de_test}+1}
    ...                                      col_num=6
    ...                                      value=${total}
    ${excel_nombre_cas_de_test}              Builtin.Evaluate
    ...                                      ${excel_nombre_cas_de_test} + 1
    Builtin.Set Suite Variable               ${excel_nombre_cas_de_test}
    ${excel_numero_de_ligne}                 Builtin.Evaluate
    ...                                      ${excel_numero_de_ligne} + ${nombre_url_dans_cas_de_test} + 3
    Builtin.Set Suite Variable               ${excel_numero_de_ligne}

Recuperer consommation CO2 de la page
    [Tags]    log
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
    [Arguments]    ${liste_url}
    ${iteration}                             Builtin.Set Variable    
    ...                                      0
    ${total}                                 Builtin.Set Variable
    ${list_url_co2}                          Builtin.Create List
    ${list_url_proprete}                     Builtin.Create List
    FOR    ${url}    IN    @{liste_url}
        ${iteration}                         Builtin.Set Variable
        ...                                  ${0+${iteration}}
        ${resultat.body}                     Recuperer consommation CO2 de la page    
        ...                                  url_a_controler=${url}
        ${total}                             Builtin.Evaluate
        ...                                  ${total} + ${resultat.body}[statistics][co2][grid][grams]
        ${str_resultat_co2}                  Builtin.Convert To String
        ...                                  item=${resultat.body}[statistics][co2][grid][grams]
        ${resultat_proprete}                 Builtin.Evaluate
        ...                                  100 * ${resultat.body}[cleanerThan]
        ${str_resultat_proprete}             Builtin.Convert To String
        ...                                  item=${resultat_proprete}
        Collections.Append To List           ${list_url_co2}
        ...                                  ${str_resultat_co2}[0:5]
        Collections.Append To List           ${list_url_proprete}
        ...                                  ${str_resultat_proprete}[0:5]
        ExcelLibrary.Write Excel Cell        row_num=${${excel_numero_de_ligne}+${iteration}+2}    
        ...                                  col_num=1
        ...                                  value=${url}
        ExcelLibrary.Write Excel Cell        row_num=${${excel_numero_de_ligne}+${iteration}+2}    
        ...                                  col_num=2    
        ...                                  value=${resultat_proprete}
        ExcelLibrary.Write Excel Cell        row_num=${${excel_numero_de_ligne}+${iteration}+2}    
        ...                                  col_num=3    
        ...                                  value=${resultat.body}[statistics][co2][grid][grams]
        ${iteration}                         Builtin.Set Variable
        ...                                  ${1+${iteration}}
        Builtin.Log                          message=${TEST_NAME}\nURL : ${url}\nConsommation de CO2 : ${str_resultat_co2}[0:5]g\nProprete du site : ${str_resultat_proprete}[0:5]
    END
    ${consommation_co2_total}                Builtin.Convert To String
    ...                                      item=${total}
    ${nombre_url_dans_cas_de_test}           Builtin.Get Length
    ...                                      item=${liste_url}
    Builtin.Set Suite Variable               ${nombre_url_dans_cas_de_test}
    Builtin.Set Suite Variable               ${total}

    ${consommation_campagne_de_test}         Builtin.Evaluate
    ...                                      ${consommation_campagne_de_test} + ${total}
    Builtin.Set Suite Variable               ${consommation_campagne_de_test}
    Builtin.Log    message=${TEST_NAME}\nConsommation de CO2 total : ${consommation_co2_total}g

*** Test Cases ***
Cas de test 1
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_1}

Cas de test 2
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_2}

Cas de test 3
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_3}

Cas de test 4
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_4}

Cas de test 5
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_5}

Cas de test 6
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_5}

Cas de test 7
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_5}

Cas de test 8
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_5}

Cas de test 9
    Afficher la consommation des sites    liste_url=@{liste_url_cas_de_test_5}
