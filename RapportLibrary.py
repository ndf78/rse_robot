import pdfkit
import os
from PyPDF2 import PdfWriter
import requests


class Document_page:
    def __init__(self, url, consommation_co2, proprete_site):
        self.url = url
        self.consommation_co2 = consommation_co2
        self.proprete_site = proprete_site

    def get_url(self):
        return self.url

    def get_consommation_co2(self):
        return self.consommation_co2

    def get_proprete_site(self):
        return self.proprete_site

class Document_synthese:
    def __init__(self, url_1, proprete_1, consommation_co2_1, url_2, proprete_2, consommation_co2_2, url_3, proprete_3, consommation_co2_3, url_4, proprete_4, consommation_co2_4, url_5, proprete_5, consommation_co2_5, consommation_co2_total):
        self.url_1 = url_1
        self.proprete_1 = proprete_1
        self.consommation_co2_1 = consommation_co2_1

        self.url_2 = url_2
        self.proprete_2 = proprete_2
        self.consommation_co2_2 = consommation_co2_2

        self.url_3 = url_3
        self.proprete_3 = proprete_3
        self.consommation_co2_3 = consommation_co2_3

        self.url_4 = url_4
        self.proprete_4 = proprete_4
        self.consommation_co2_4 = consommation_co2_4

        self.url_5 = url_5
        self.proprete_5 = proprete_5
        self.consommation_co2_5 = consommation_co2_5

        self.consommation_co2_total = consommation_co2_total

    def get_url_1(self):
        return self.url_1

    def get_url_2(self):
        return self.url_2

    def get_url_3(self):
        return self.url_3

    def get_url_4(self):
        return self.url_4

    def get_url_5(self):
        return self.url_5

    def get_proprete_1(self):
        return self.proprete_1

    def get_proprete_2(self):
        return self.proprete_2

    def get_proprete_3(self):
        return self.proprete_3

    def get_proprete_4(self):
        return self.proprete_4

    def get_proprete_5(self):
        return self.proprete_5

    def get_consommation_co2_1(self):
        return self.consommation_co2_1

    def get_consommation_co2_2(self):
        return self.consommation_co2_2

    def get_consommation_co2_3(self):
        return self.consommation_co2_3

    def get_consommation_co2_4(self):
        return self.consommation_co2_4

    def get_consommation_co2_5(self):
        return self.consommation_co2_5

    def get_consommation_co2_total(self):
        return self.consommation_co2_total

def incrementer_nom(nom_fichier):
    i = 0
    while os.path.exists(f'{nom_fichier}{i}.pdf'):
        i += 1
    nom_fichier_increment = str(nom_fichier) + str(i)
    return nom_fichier_increment

def rechercher_liste_dossier_fichier(chemin, rechercher):
    list_dossier_fichier = os.listdir(chemin)
    filtre1 = [x for x in list_dossier_fichier if x.startswith(rechercher)]
    msg = filtre1
    resultat_log = print(msg)
    return filtre1

def renseigner_document(template, class_document):
    HTML_File=open(f'{template}.html','r')
    document = HTML_File.read().format(p=class_document)
    return document

def generer_rapport_html(template, rapport, class_document):
    document = renseigner_document(template, class_document)
    with open(f'{rapport}.html', 'w') as fichier:
        fichier.write(document)
    return

def convertir_rapport_html_en_pdf(template, rapport, class_document):
    generer_rapport_html(template, rapport, class_document)
    nom_fichier_increment = incrementer_nom(rapport)
    with open(f'{rapport}.html', 'r') as fichier:
        pdfkit.from_file(fichier, f'{nom_fichier_increment}.pdf')
    os.remove(f'{rapport}.html')
    return

def generer_rapport_de_la_page(url, proprete, consommation_co2):
    convertir_rapport_html_en_pdf('templates/page_site', 'rapport/_01_page_site', Document_page(url, proprete, consommation_co2))
    return "Le rapport a été crée"

def generer_synthese(url_1, proprete_1, consommation_co2_1, url_2, proprete_2, consommation_co2_2, url_3, proprete_3, consommation_co2_3, url_4, proprete_4, consommation_co2_4, url_5, proprete_5, consommation_co2_5, consommation_co2_total):
    convertir_rapport_html_en_pdf('templates/page_synthese', 'rapport/_00_page_synthese', Document_synthese(url_1, proprete_1, consommation_co2_1, url_2, proprete_2, consommation_co2_2, url_3, proprete_3, consommation_co2_3, url_4, proprete_4, consommation_co2_4, url_5, proprete_5, consommation_co2_5, consommation_co2_total))
    list_pdf = rechercher_liste_dossier_fichier('rapport', '_0')
    list_pdf_tri = sorted(list_pdf)
    # fusionner_pdf(list_pdf_tri)
    return "Le rapport a été crée"

def fusionner_pdf(liste_pdf_file):
    merger = PdfWriter()
    for pdf in [liste_pdf_file]:
        merger.append(pdf)
    merger.write("rapport_consommation")
    merger.close()
    return

# list_pdf = rechercher_liste_dossier_fichier('rapport', '_0')
# list_pdf_tri = sorted(list_pdf)

# fusionner_pdf(list_pdf_tri)

# list_pdf = rechercher_liste_dossier_fichier('rapport', '_0')
# print(sorted(list_pdf))

# rechercher_liste_dossier_fichier('rapport', '_page')
# generer_rapport_de_la_page("url", "proprete", "consommation_co2")

# generer_synthese("url_1", "proprete_1", "consommation_co2_1", "url_2", "proprete_2", "consommation_co2_2", "url_3", "proprete_3", "consommation_co2_3", "url_4", "proprete_4", "consommation_co2_4", "url_5", "proprete_5", "consommation_co2_5", "consommation_co2_total")
# HTML_File=open('page_site.html','r')
# s = HTML_File.read().format(p=Document_page('lapin','catapulte'))
# print(s)

# with open('templates/page_synthese.html', 'r') as fichier:
#     print(fichier)

# objet = Document_synthese("url_1", "proprete_1", "consommation_co2_1", "url_2", "proprete_2", "consommation_co2_2", "url_3", "proprete_3", "consommation_co2_3", "url_4", "proprete_4", "consommation_co2_4", "url_5", "proprete_5", "consommation_co2_5", "consommation_co2_total")

# HTML_File=open('templates/page_synthese.html','r')
# document = HTML_File.read().format(p=objet)

