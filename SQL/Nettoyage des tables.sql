---------- Nettoyage Clients---------
--Doublon--
SELECT prenom, nom, sexe, ville, region, date_naissance, COUNT(*)
FROM dim_clients
GROUP BY prenom, nom, sexe, ville, region, date_naissance
HAVING COUNT(*) > 1;

--Supprimer les doublons (garder le plus petit client_id de chaque groupe)--
UPDATE fact_ventes v
SET client_id = principal.id_garder
FROM (
    SELECT client_id AS id_supprimer,
           FIRST_VALUE(client_id) OVER (
               PARTITION BY prenom, nom, sexe, ville, region, date_naissance
               ORDER BY client_id
           ) AS id_garder
    FROM dim_clients
) principal
WHERE v.client_id = principal.id_supprimer
  AND principal.id_supprimer != principal.id_garder;
SELECT COUNT(*) FROM fact_ventes WHERE client_id >= 601;


DELETE FROM dim_clients
WHERE client_id IN (
SELECT client_id FROM (
SELECT client_id,
ROW_NUMBER() OVER (
PARTITION BY prenom, nom, sexe, ville, region, date_naissance
ORDER BY client_id
) AS rn
FROM dim_clients
) t
WHERE rn > 1
);


UPDATE dim_clients
SET ville = INITCAP(TRIM(ville));

-- Sexe manquant : on ne peut pas deviner, on marque explicitement "Inconnu"
UPDATE dim_clients SET sexe = 'I' WHERE sexe IS NULL; ---- I = Inconnue--
-- Date de naissance manquante : on ne l'invente pas, on laisse NULL
-- (une date fictive fausserait les calculs d'âge) -- on vérifie juste le nombre concerné :
SELECT COUNT(*) FROM dim_clients WHERE date_naissance IS NULL;


-------- Nettoyage Ventes--------
---Supprimer les doublons stricts
DELETE FROM fact_ventes
WHERE vente_id IN (
SELECT vente_id FROM (
SELECT vente_id,
ROW_NUMBER() OVER (
PARTITION BY date_vente, pharmacie_id, client_id, produit_id,
quantite, prix_unitaire, remise_pct
ORDER BY vente_id
) AS rn
FROM fact_ventes
) t
WHERE rn > 1
);

-----Corriger les prix negatifs
UPDATE fact_ventes
SET prix_unitaire = ABS(prix_unitaire)
WHERE prix_unitaire < 0;

-----Traiter les quantités manquantes
ALTER TABLE fact_ventes
ALTER COLUMN quantite TYPE INT USING ROUND(quantite)::INT;

UPDATE fact_ventes
SET quantite = (
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quantite)
FROM fact_ventes WHERE quantite IS NOT NULL
)
WHERE quantite IS NULL;

----Verification
SELECT COUNT(*) FROM dim_pharmacies;
SELECT COUNT(*) FROM dim_produits; 
SELECT COUNT(*) FROM dim_clients;
SELECT COUNT(*) FROM fact_ventes; 
SELECT COUNT(*) FROM fact_signalements; 



