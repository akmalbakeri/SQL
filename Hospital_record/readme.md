## 📊 Project Flow

### 📥 Data Source
Dataset downloaded from [Maven Analytics Hospital Patient Records](https://mavenanalytics.io/data-playground/hospital-patient-records).

---

### 🗂️ Project Files

| File | Description |
|------|-------------|
| [`encounters.csv`](https://github.com/akmalbakeri/SQL/blob/main/Hospital_record/encounters.csv) | Primary dataset used for all analysis |
| [`create_hospital_db.sql`](https://github.com/akmalbakeri/SQL/blob/main/Hospital_record/create_hospital_db.sql) | Script to create and load the MySQL database |
| [`hospital_analytics_questions.sql`](https://github.com/akmalbakeri/SQL/blob/main/Hospital_record/hospital_analytics_questions.sql) | Analytics questions |
| [`questionbased.sql`](https://github.com/akmalbakeri/SQL/blob/main/Hospital_record/questionbased.sql) | ✅ Full answers to all questions below |

> **Note:** While the dataset includes multiple CSV files, only `encounters.csv` was needed to answer all analytical questions.

---

### 🔄 Pipeline
1. Download the dataset from Maven Analytics
2. Run `create_hospital_db.sql` to set up the MySQL database and load the data
3. Execute queries from `questionbased.sql` to explore the answers
4. Optionally, this project runs to visualization in Tableau in another repo in [here](https://github.com/akmalbakeri/Visualization/tree/main/Hospital_record)

---

### ❓ Analytical Questions

#### 🏥 Objective 1: Encounters Overview
- **a.** How many total encounters occurred each year?
- **b.** For each year, what percentage of all encounters belonged to each encounter class *(ambulatory, outpatient, wellness, urgent care, emergency, inpatient)*?
- **c.** What percentage of encounters were over 24 hours vs. under 24 hours?

#### 💰 Objective 2: Cost & Coverage Insights
- **a.** How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
- **b.** What are the top 10 most frequent procedures performed and the average base cost for each?
- **c.** What are the top 10 procedures with the highest average base cost and the number of times performed?
- **d.** What is the average total claim cost for encounters, broken down by payer?

#### 🧍 Objective 3: Patient Behavior Analysis
- **a.** How many unique patients were admitted each quarter over time?
- **b.** How many patients were readmitted within 30 days of a previous encounter?
- **c.** Which patients had the most readmissions?
