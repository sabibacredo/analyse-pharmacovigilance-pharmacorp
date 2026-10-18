CREATE TABLE dim_pharmacies (
pharmacie_id INT PRIMARY KEY,
nom_pharmacie VARCHAR(100),
ville VARCHAR(50),
region VARCHAR(50),
date_ouverture DATE
);


CREATE TABLE dim_produits (
produit_id INT PRIMARY KEY,
nom_produit VARCHAR(100),
categorie VARCHAR(50),
sous_categorie VARCHAR(50),
laboratoire VARCHAR(50),
prix_unitaire NUMERIC(10,2)
);



CREATE TABLE dim_clients (
client_id INT PRIMARY KEY,
prenom VARCHAR(50),
nom VARCHAR(50),
sexe VARCHAR(1),
ville VARCHAR(50),
region VARCHAR(50),
date_naissance DATE
);



CREATE TABLE fact_ventes (
vente_id INT PRIMARY KEY,
date_vente DATE,
pharmacie_id INT REFERENCES dim_pharmacies(pharmacie_id),
client_id INT REFERENCES dim_clients(client_id),
produit_id INT REFERENCES dim_produits(produit_id),
quantite INT,
prix_unitaire NUMERIC(10,2),
remise_pct NUMERIC(4,2)
);


CREATE TABLE fact_signalements (
signalement_id INT PRIMARY KEY,
date_signalement DATE,
produit_id INT REFERENCES dim_produits(produit_id),
client_id INT REFERENCES dim_clients(client_id),
gravite VARCHAR(20),
description_effet VARCHAR(200)
);

DROP TABLE IF EXISTS fact_ventes;

CREATE TABLE fact_ventes (
    vente_id INT PRIMARY KEY,
    date_vente DATE,
    pharmacie_id INT REFERENCES dim_pharmacies(pharmacie_id),
    client_id INT REFERENCES dim_clients(client_id),
    produit_id INT REFERENCES dim_produits(produit_id),
    quantite NUMERIC(6,1),
    prix_unitaire NUMERIC(10,2),
    remise_pct NUMERIC(4,2)
);

SELECT COUNT(*) FROM dim_pharmacies; -- attendu : 5
SELECT COUNT(*) FROM dim_produits; -- attendu : 20
SELECT COUNT(*) FROM dim_clients; -- attendu : 610
SELECT COUNT(*) FROM fact_ventes; -- attendu : 42350
SELECT COUNT(*) FROM fact_signalements; -- attendu : 3000









