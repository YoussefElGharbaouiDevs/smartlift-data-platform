# SmartLift Data Intelligence Platform

## Présentation du Projet
**SmartLift Data Intelligence Platform** est une plateforme moderne de Data Engineering et d'Intelligence Artificielle conçue pour collecter, nettoyer, historiser, analyser et prédire les données de consommation énergétique et le comportement opérationnel des ascenseurs.

### Fonctionnalités Clés
- **Ingestion Hybride** : Traitement Batch (4 datasets réels + Mendeley + Figshare) et Streaming IoT (Kafka + Simulateur Python).
- **Architecture Medallion (Bronze $\rightarrow$ Silver $\rightarrow$ Gold)** : Stockage Data Lake MinIO et Data Warehouse PostgreSQL.
- **Data Quality & Traçabilité** : Validation des schémas, gestion des valeurs manquantes, traçabilité `record_nature` (OBSERVED / SIMULATED / DERIVED).
- **IA & Analytics** : Modèles de prévision énergétique (Scikit-Learn/XGBoost), classification de pannes de portes et détection d'anomalies.
- **Dashboards & Restitution** : Visualisation en temps réel via Power BI / Grafana et restitution des indicateurs (`health_score`, `availability_rate`, `MTTR`, `MTBF`).

---

## Architecture Technique

```
                       +---------------------------------------+
                       |        SmartLift IoT Simulator        |
                       +---------------------------------------+
                                           | (Streaming IoT)
                                           v
+------------------+             +-------------------+             +-----------------------+
|  Datasets CSV    | ----------> |   Apache Kafka    | ----------> |   Spark Streaming /   |
|  (Historique)    | (Batch)     |   Event Broker    |             |   Airflow ETL         |
+------------------+             +-------------------+             +-----------------------+
                                                                               |
                                                                               v
                                                          +------------------------------------------+
                                                          |          Data Lake - MinIO               |
                                                          |  (smartlift-bronze / silver / gold)      |
                                                          +------------------------------------------+
                                                                               |
                                                                               v
                                                          +------------------------------------------+
                                                          |     Data Warehouse - PostgreSQL 15       |
                                                          |        (Schemas: bronze, silver, gold)   |
                                                          +------------------------------------------+
                                                                               |
                                                                               v
                                                          +------------------------------------------+
                                                          |       Power BI / Grafana Dashboards      |
                                                          +------------------------------------------+
```

---

## 📁 Arborescence du Dépôt

```
SmartLift/
├── dags/                  # DAGs Apache Airflow (Pipelines d'orchestration)
├── dbt/                   # Modèles dbt pour le Data Warehouse
├── data/
│   ├── raw/               # Datasets CSV réels bruts
│   └── external/          # Datasets téléchargés (Mendeley, Figshare)
├── scripts/
│   ├── simulator/         # Simulateur IoT temps réel (Python + Kafka producer)
│   ├── etl/               # Scripts PySpark & Python (Bronze -> Silver -> Gold)
│   └── ml/                # Scripts d'entraînement et inférence IA
├── sql/
│   └── init/              # Scripts DDL d'initialisation PostgreSQL (01_create_schemas.sql)
├── .env                   # Variables d'environnement
├── .gitignore             # Exclusion Git
├── docker-compose.yml     # Orchestration Docker (MinIO, Postgres, Kafka, Airflow)
├── Cahier_des_charges_SmartLift.pdf
├── SmartLift_Modelisation_Donnees_Complete_A_Z.pdf
└── README.md
```

---

## Démarrage Rapide (Infrastructure Docker)

### 1. Prérequis
- Docker Desktop (avec Docker Compose V2)
- Python 3.10+ (optionnel pour scripts locaux)

### 2. Lancement des Services
Pour démarrer l'ensemble de l'infrastructure en arrière-plan :
```bash
docker-compose up -d
```

### 3. Services & Enregistrements d'Accès

| Service | URL / Endpoint | Identifiants par défaut |
| :--- | :--- | :--- |
| **PostgreSQL Data Warehouse** | `localhost:5432` | User: `smartlift` / Pass: `smartlift_pass123` / DB: `smartlift_dw` |
| **MinIO Console** | [http://localhost:9001](http://localhost:9001) | User: `smartlift_admin` / Pass: `smartlift_pass123` |
| **MinIO API (S3)** | `http://localhost:9000` | User: `smartlift_admin` / Pass: `smartlift_pass123` |
| **Kafka UI** | [http://localhost:8080](http://localhost:8080) | N/A (Tableau de bord visuel Kafka) |
| **Apache Airflow UI** | [http://localhost:8085](http://localhost:8085) | User: `admin` / Pass: `admin` |

### 4. Arrêt des Services
```bash
docker-compose down
```

---

## Status des Schémas de Données (PostgreSQL)

- **`bronze`** : Tables brutes d'ingestion (`raw_elevator_energy_efficiency`, `raw_elevator_traffic`, `raw_elevator_door_fault`, `raw_predictive_maintenance`).
- **`silver`** : Tables nettoyées et typées par domaine.
- **`gold`** : Modèle dimensionnel en étoile (`dim_date`, `dim_time`, `dim_building`, `dim_elevator`, `dim_sensor`, etc.) et tables de faits.
