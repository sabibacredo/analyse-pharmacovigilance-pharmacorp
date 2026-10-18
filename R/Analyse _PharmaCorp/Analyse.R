# ============================================================
# Analyse des signalements PharmaCorp
# ============================================================
library(tidyverse)

# ##### 1. Import et préparation ###########

signalements <- read_csv("ventes_signalements.csv")
signalements <- signalements %>%
  mutate(
    gravite = factor(gravite, levels = c("Légère", "Modérée", "Grave"),
                     ordered = TRUE),
    est_grave = ifelse(gravite == "Grave", 1, 0),
    sexe = factor(sexe)
  )
glimpse(signalements)


# ##### 2. Statistiques descriptives ##########

summary(signalements$age_patient)
signalements %>%
  count(gravite) %>%
  mutate(pct = round(n / sum(n) * 100, 1))


# ##### 3. Test de normalité et test t ############

shapiro.test(signalements$age_patient)
t.test(age_patient ~ est_grave, data = signalements)


# ##### 4. Test du Khi-deux ############

chisq.test(table(signalements$region, signalements$gravite))


# ##### 5. Régression logistique ###########

modele <- glm(
  est_grave ~ age_patient + sexe + categorie,
  data = signalements,
  family = binomial
)
summary(modele)
exp(coef(modele)) # odds ratios
exp(confint(modele)) # intervalles de confiance à 95 %


# ##### 6. Visualisations ########

##### Graphique Histogramme
g1 <- ggplot(signalements, aes(x = age_patient)) +
  geom_histogram(bins = 20, fill = "#2E7D6B", color = "white") +
  labs(title = "Distribution de l'âge des patients concernés",
       x = "Âge (années)", y = "Effectif") +
  theme_minimal()

##### Graphique Boxplot
g2 <- ggplot(signalements, aes(x = gravite, y = age_patient, fill = gravite))+
  geom_boxplot() +
  labs(title = "Âge selon la gravité du signalement",
       x = "Gravité", y = "Âge (années)") +
  theme_minimal() + theme(legend.position = "none")



########################## LES AFFICHAGES ####################################
##==========================================================================##
print(g1)
print(g2)
ggsave("figure_distribution_age.png", plot = g1, width = 7, height = 4.5, dpi =
         300)
ggsave("figure_age_gravite.png", plot = g2, width = 7, height = 4.5, dpi = 300)







