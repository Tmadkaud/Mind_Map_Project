# Mind map

## Description

Ce projet a pour but de concevoir facilement une mind map. 

## Requirements

- Vagrant
- VirtualBox
- Root Access (pour l'installation des packages)
- Distribution : Debian, Redhat ou Centos

## How to run

Afin d'installer et lancer l'API, ouvrez un terminal et copier/coller les commandes suivantes:

```
git clone https://github.com/Tmadkaud/Mind_Map_Project.git
```

```
cd Mind_Map_Project
```

```
pipeline.sh
```

De plus si vous êtes vous avez un probleme, vous pouvez lancer l'application via :
```
sudo docker-compose up
```

Exemple de requete:
```
curl -X POST -H "Content-Type: application/json" -d '{"map_id": "hello_nbc"}' localhost/api/maps
```

## API Workflow
J'ai essayé de faire de mon mieux pour suivre votre guideline et de faire en sorte que l'API suive autant que possible les exemples que vous avez fournis.

J'ai choisi d'utiliser une base de données noSQL (MongoDB) pour stocker facilement la requête envoyée par l'utilisateur.  

A mon avis, Flask est apparu comme le meilleur choix pour construire une API : facile à installer, facile à manipuler à la racine de l'API, il fonctionne bien avec pymongo, et il est léger.

## Automatisation de l'infrastructure
Pour supporter l'API, j'ai choisi de construire un environnement conteneur avec Docker.

J'ai choisi d'utiliser docker pour mes deux stack (flask et mongo)

flask utilise une image légère de python 3, ainsi j'ai creer une image docker via un dockerfile customiser (image python et des lib a utiliser qui sont les requirements)

pour mongodb j'ai juste utiliser l'image de base

### Pipeline.sh
Ces deux containers sont managés par docker compose qui me permet de construire et de faire fonctionner les deux environnements ensemble en exposant leurs ports et en montant des volumes spécifiques

J'ai voulu essayer de faire le plus de point bonus possible tout en simplifiant au maximum le deploiement et voulant minimiser le nombre d'opérations manuelles (setter les credentials AWS).

Ainsi pour montrer ma passion de l'automatisation j'ai pu en un seul BASH script :

- Provisionner une machine virtuelle vagrant, ayant pour but de simuler une instance AWS EC2. Toutes les prochaines étapes seront exécutées dans cette même instance.
- Builder la Dockerfile pour l'environement Flask
- Executer le dockercompose.yml
- Executer differents test sur l'API
- Cleaner l'environement

Tout cela me permet rapidement de simuler un deploiement, des test et la pereniter du script from scratch


