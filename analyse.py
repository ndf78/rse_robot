import json

with open('report.json') as mon_fichier:
    data = json.load(mon_fichier)

for cle in data.keys():
	print(cle)

