# PharmaCorp — Analyse des ventes et de la pharmacovigilance

Projet de portfolio de bout en bout : base de données PostgreSQL, tableau de bord Power BI, reporting Excel et analyse statistique en R, sur l'activité d'une chaîne de 5 pharmacies togolaises (2023-2025).

> **Données simulées.** Le jeu de données est généré aléatoirement à des fins pédagogiques. Il ne décrit aucune pharmacie, aucun patient et aucun médicament réels, et ne permet aucune conclusion médicale ou commerciale.

## Contexte et objectifs

PharmaCorp est une chaîne fictive de 5 pharmacies réparties dans 4 régions. Le projet répond à deux questions :

1. **Performance commerciale** : quels produits, pharmacies et régions portent le chiffre d'affaires, et comment évolue-t-il ?
2. **Pharmacovigilance** : quels facteurs (âge, sexe, classe de médicament, région) sont associés à un signalement d'effet indésirable **grave** ?

## Données

| Table | Rôle | Lignes brutes | Après nettoyage |
|---|---|---|---|
| `dim_pharmacies` | Points de vente (ville, région) | 5 | 5 |
| `dim_produits` | Catalogue de médicaments (catégorie, laboratoire, prix) | 20 | 20 |
| `dim_clients` | Clients (sexe, ville, région, date de naissance) | 610 | 600 |
| `fact_ventes` | Transactions de vente, 2023-2025 | 42 350 | 41 997 |
| `fact_signalements` | Signalements de pharmacovigilance | 3 000 | 3 000 |

Le schéma est un **schéma en étoile** : deux tables de faits (`fact_ventes`, `fact_signalements`) reliées aux dimensions produits, clients et pharmacies.

## Méthodologie

### 1. SQL (PostgreSQL) — `sql/`

Création du schéma avec clés primaires et étrangères, import des CSV, nettoyage des données, puis requêtes d'analyse (jointures, agrégations, fonctions de fenêtrage, CTE).

Anomalies détectées et corrigées :

| Problème | Traitement |
|---|---|
| 10 clients en double | Ventes redirigées vers le client conservé (695 lignes), puis doublons supprimés |
| Villes saisies de 22 façons différentes (casse, espaces) | Normalisées en 7 villes (`INITCAP(TRIM(...))`) |
| 15 valeurs de `sexe` manquantes | Marquées « Inconnu » |
| 20 dates de naissance manquantes | Conservées à `NULL` (une date inventée fausserait les âges) |
| 353 lignes de vente en double | Supprimées (fonction de fenêtrage `ROW_NUMBER`) |
| 25 prix unitaires négatifs | Corrigés par valeur absolue |
| 120 quantités manquantes | Imputées par la médiane (3) |

### 2. Power BI — `powerbi/`

Modèle en étoile, table de dates dédiée avec hiérarchie Année / Trimestre / Mois, mesures DAX (chiffre d'affaires avec remise, comparaison à l'année précédente, taux de signalements graves) et sécurité au niveau ligne par région.

### 3. Excel — `excel/`

Import via Power Query, tableau croisé dynamique, graphique dynamique et feuille de simulation « et si » sur le prix moyen.

### 4. R — `r/`

Statistiques descriptives, test t, test du Khi-deux et régression logistique, avec un rapport R Markdown reproductible (`rapport_pharmacorp.html`).

## Résultats clés

### Performance commerciale

- **Chiffre d'affaires total : 420,6 M FCFA** sur 3 ans (remises déduites).
- **Évolution quasi stable** : 141,4 M en 2023, 140,0 M en 2024 (−1,0 %), 139,3 M en 2025 (−0,5 %).
- **La région Maritime concentre 50 % du chiffre d'affaires** (210,7 M), mais elle compte 2 des 5 pharmacies.

| Région | CA (M FCFA) | Part |
|---|---|---|
| Maritime | 210,7 | 50,1 % |
| Kara | 83,7 | 19,9 % |
| Centrale | 63,7 | 15,2 % |
| Plateaux | 62,5 | 14,9 % |

- **Un seul produit pèse près d'un cinquième du CA** : l'Insuline NPH (77,4 M, soit 18,4 %), suivie du Salbutamol spray (33,2 M) et de l'Azithromycine 250 mg (31,8 M). La classe des antidiabétiques représente 26 % du CA.

### Pharmacovigilance

- Sur 3 000 signalements : **55,8 % légers, 34,0 % modérés, 10,2 % graves** (307).
- Taux de gravité le plus élevé : Ciprofloxacine 500 mg (13,7 %, 21 cas sur 153) ; le plus bas : Amlodipine 5 mg (5,1 %). Ces écarts reposent sur de petits effectifs et sont à interpréter avec prudence.
- **Aucun facteur de risque significatif n'a été mis en évidence** (2 902 signalements analysés, ceux dont la date de naissance est connue) :

| Analyse | Résultat |
|---|---|
| Âge moyen, signalements graves vs non graves | 52,7 vs 51,2 ans, test de Welch p = 0,27 |
| Région × gravité (Khi-deux) | p = 0,41 |
| Régression logistique (âge, sexe, classe thérapeutique) | modèle global p = 0,65 ; OR de l'âge = 1,003 par année (p = 0,29) ; aucune variable avec p < 0,05 |

Ce résultat est **cohérent avec la nature des données** : elles sont tirées au hasard, sans lien construit entre ces variables. L'intérêt du projet est de montrer une chaîne d'analyse rigoureuse, qui sait aussi conclure à l'absence d'effet.


## Structure du repository

```
├── README.md
├── sql/          scripts de création, nettoyage, analyse et exports
├── powerbi/      tableau de bord (.pbix)
├── excel/        reporting complémentaire (.xlsx)
├── r/            script, rapport R Markdown, application shiny et figures
└── captures/     captures d'écran des livrables
```

## Reproduire l'analyse

1. Créer une base PostgreSQL `pharmacorp`, puis exécuter dans l'ordre `sql/01_creation_tables.sql`, l'import des CSV, `sql/02_nettoyage.sql` et `sql/03_analyse.sql`.
2. Ouvrir `powerbi/pharmacorp_dashboard.pbix` et mettre à jour la source de données vers votre base locale.
3. Exporter la requête de jointure vers `r/ventes_signalements.csv`, puis ouvrir `r/rapport_pharmacorp.Rmd` dans RStudio et cliquer sur **Knit**, faites la même chose pour les autres Rmd pour explorer l'application shiny

## Limites

- Données simulées : les résultats statistiques ne reflètent aucune réalité clinique ou commerciale.
- L'imputation des quantités par la médiane est un choix simple ; sur des données réelles, une méthode plus fine serait à justifier.
- Les identifiants et les valeurs de référence (monnaie, prix) sont fictifs.

## Outils

PostgreSQL - SQL - Power BI - DAX - Power Query - Excel - R - tidyverse - ggplot2 - R Markdown - shiny

## Auteur

SABIBA Beyn-yagui Crédo [Email](sabibacredo@gmail.com)

