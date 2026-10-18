library(shiny)
library(shinythemes)
library(tidyverse)
library(broom) # Package très pratique pour nettoyer l'affichage des tests statistiques

# 1. Chargement et préparation des données
signalements <- read_csv("ventes_signalements.csv") %>%
  mutate(
    gravite = factor(gravite, levels = c("Légère", "Modérée", "Grave"), ordered = TRUE),
    est_grave = ifelse(gravite == "Grave", 1, 0),
    sexe = factor(sexe)
  )

# 2. Interface Utilisateur (UI)
ui <- fluidPage(
  theme = shinytheme("flatly"), # Optionnel : donne un style visuel épuré (nécessite library(shinythemes))
  titlePanel("Dashboard d'Analyse des Signalements PharmaCorp"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Configuration des Graphiques"),
      sliderInput("nb_bins", 
                  label = "Nombre de barres (Histogramme) :", 
                  min = 5, max = 50, value = 20),
      
      selectInput("couleur_hist", 
                  label = "Couleur de l'histogramme :",
                  choices = c("Vert Pharma" = "#2E7D6B", "Bleu" = "steelblue", "Rouge" = "darkred"),
                  selected = "#2E7D6B")
    ),
    
    mainPanel(
      tabsetPanel(
        # Onglet 1 : Visualisations graphiques
        tabPanel("📊 Graphiques", 
                 br(),
                 plotOutput("plot_hist"),
                 br(),
                 plotOutput("plot_boxplot")),
        
        # Onglet 2 : Statistiques Descriptives (Tableau pct)
        tabPanel("📈 Description de la Gravité", 
                 br(),
                 h4("Répartition et pourcentages par niveau de gravité"),
                 tableOutput("table_desc")),
        
        # Onglet 3 : Tests statistiques (Normalité, t-test, Chi2)
        tabPanel("🔬 Tests Inférentiels", 
                 br(),
                 h4("1. Test de normalité de Shapiro-Wilk (sur l'âge)"),
                 verbatimTextOutput("test_shapiro"),
                 
                 h4("2. Test t de Student (Âge selon le caractère Grave)"),
                 verbatimTextOutput("test_ttest"),
                 
                 h4("3. Test du Chi-deux (Région vs Gravité)"),
                 verbatimTextOutput("test_chisq")),
        
        # Onglet 4 : Modélisation (Régression logistique)
        tabPanel("🤖 Modélisation Logistique", 
                 br(),
                 h4("Résultats de la Régression Logistique (Variable cible : est_grave)"),
                 tableOutput("table_modele"),
                 p("Note : Ce tableau affiche les coefficients estimés, les erreurs types et les p-values associés à vos variables prédictrices."))
      )
    )
  )
)

# 3. Logique Serveur (Server)
server <- function(input, output) {
  
  # --- GRAPH_1 : HISTOGRAMME ---
  output$plot_hist <- renderPlot({
    ggplot(signalements, aes(x = age_patient)) +
      geom_histogram(bins = input$nb_bins, fill = input$couleur_hist, color = "white") +
      labs(title = "Distribution de l'âge des patients concernés", x = "Âge (années)", y = "Effectif") +
      theme_minimal()
  })
  
  # --- GRAPH_2 : BOXPLOT ---
  output$plot_boxplot <- renderPlot({
    ggplot(signalements, aes(x = gravite, y = age_patient, fill = gravite)) +
      geom_boxplot() +
      labs(title = "Âge selon la gravité du signalement", x = "Gravité", y = "Âge (années)") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # --- TAB_1 : STATISTIQUES DESCRIPTIVES ---
  output$table_desc <- renderTable({
    signalements %>%
      count(gravite) %>%
      mutate(pct = round(n / sum(n) * 100, 1))
  }, digits = 1)
  
  # --- STATS_1 : SHAPIRO-WILK ---
  output$test_shapiro <- renderPrint({
    shapiro.test(signalements$age_patient)
  })
  
  # --- STATS_2 : T-TEST ---
  output$test_ttest <- renderPrint({
    t.test(age_patient ~ est_grave, data = signalements)
  })
  
  # --- STATS_3 : CHI-DEUX ---
  output$test_chisq <- renderPrint({
    chisq.test(table(signalements$region, signalements$gravite))
  })
  
  # --- MODELE : RÉGRESSION LOGISTIQUE ---
  output$table_modele <- renderTable({
    # Exécution du modèle de régression logistique globale
    modele <- glm(est_grave ~ age_patient + sexe + categorie, data = signalements, family = binomial)
    
    # Présentation propre des résultats sous forme de tableau
    tidy(modele) %>%
      rename(Variable = term, Coefficient = estimate, Erreur_Type = std.error, Statistique_z = statistic, P_value = p.value)
  }, digits = 4)
}

# 4. Lancement de l'application
shinyApp(ui = ui, server = server)
  
  
  
  