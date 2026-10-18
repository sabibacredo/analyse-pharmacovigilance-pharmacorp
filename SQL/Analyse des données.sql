--------------------Analyse-------------------
----------------------------------------------
------Chiffre d'affaires total et par région
SELECT p.region,
ROUND(SUM(v.quantite * v.prix_unitaire * (1 - v.remise_pct)), 0) AS
chiffre_affaires
FROM fact_ventes v
JOIN dim_pharmacies p ON v.pharmacie_id = p.pharmacie_id
GROUP BY p.region
ORDER BY chiffre_affaires DESC;


-------Top 5 des produits les plus vendus (en quantité) et les plus rentables
SELECT d.nom_produit,
SUM(v.quantite) AS quantite_totale,
ROUND(SUM(v.quantite * v.prix_unitaire * (1 - v.remise_pct)), 0) AS ca_total
FROM fact_ventes v
JOIN dim_produits d ON v.produit_id = d.produit_id
GROUP BY d.nom_produit
ORDER BY ca_total DESC
LIMIT 5;


-------Signalements par gravité et par produit
SELECT d.nom_produit, s.gravite, COUNT(*) AS nb
FROM fact_signalements s
JOIN dim_produits d ON s.produit_id = d.produit_id
GROUP BY d.nom_produit, s.gravite
ORDER BY d.nom_produit, s.gravite;


-------Clients ayant eu un signalement grave
SELECT DISTINCT c.prenom, c.nom, c.ville, s.gravite
FROM fact_signalements s
JOIN dim_clients c ON s.client_id = c.client_id
WHERE s.gravite = 'Grave'
ORDER BY c.nom;


------Classement des pharmacies par chiffre d'affaires
SELECT p.nom_pharmacie,
ROUND(SUM(v.quantite * v.prix_unitaire * (1 - v.remise_pct)), 0) AS ca,
RANK() OVER (
ORDER BY SUM(v.quantite * v.prix_unitaire * (1 - v.remise_pct)) DESC
) AS rang
FROM fact_ventes v
JOIN dim_pharmacies p ON v.pharmacie_id = p.pharmacie_id
GROUP BY p.nom_pharmacie;


------Taux de signalements graves par produit
WITH stats_produit AS (
SELECT d.nom_produit,
COUNT(*) AS total_signalements,
COUNT(*) FILTER (WHERE s.gravite = 'Grave') AS nb_graves
FROM fact_signalements s
JOIN dim_produits d ON s.produit_id = d.produit_id
GROUP BY d.nom_produit
)
SELECT nom_produit, total_signalements, nb_graves,
ROUND(nb_graves::NUMERIC / total_signalements * 100, 1) AS taux_grave_pct
FROM stats_produit
ORDER BY taux_grave_pct DESC;

















