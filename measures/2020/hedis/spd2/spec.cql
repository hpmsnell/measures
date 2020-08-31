library HEDIS_SPD2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPD2
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; CABG": '2.16.840.1.113883.3.464.1004.1048'
valueset "HEDIS; Cirrhosis": '2.16.840.1.113883.3.464.1004.1379'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Dialysis Procedure": '2.16.840.1.113883.3.464.1004.1952'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; ESRD Diagnosis": '2.16.840.1.113883.3.464.1004.1747'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IVD": '2.16.840.1.113883.3.464.1004.1137'
valueset "HEDIS; IVF": '2.16.840.1.113883.3.464.1004.1392'
valueset "HEDIS; MI": '2.16.840.1.113883.3.464.1004.1157'
valueset "HEDIS; Muscular Pain and Disease": '2.16.840.1.113883.3.464.1004.1381'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Other Revascularization": '2.16.840.1.113883.3.464.1004.1388'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; PCI": '2.16.840.1.113883.3.464.1004.1204'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'

// NCQA medication list value sets

valueset "NCQA; Estrogen Agonists Medications"
valueset "NCQA; Atorvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1801'
valueset "NCQA; Amlodipine Atorvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1805'
valueset "NCQA; Rosuvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1803'
valueset "NCQA; Simvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1798'
valueset "NCQA; Ezetimibe Simvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1807'
valueset "NCQA; Atorvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1800'
valueset "NCQA; Amlodipine Atorvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1804'
valueset "NCQA; Rosuvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1803'
valueset "NCQA; Simvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1797'
valueset "NCQA; Ezetimibe Simvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1806'
valueset "NCQA; Pravastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1796'
valueset "NCQA; Lovastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1795'
valueset "NCQA; Fluvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1799'
valueset "NCQA; Pitavastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1808'
valueset "NCQA; Ezetimibe Simvastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1953'
valueset "NCQA; Fluvastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1954'
valueset "NCQA; Lovastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1955'
valueset "NCQA; Pitavastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1956'
valueset "NCQA; Pravastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1957'
valueset "NCQA; Simvastatin Low Intensity Medications": '2.16.840.1.113883.3.464.1004.1958'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "High Intensity Statin"
  ["Medication, Dispensed": "Atorvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Amlodipine Atorvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Rosuvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Simvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Ezetimibe Simvastatin High Intensity Medications"]

define "Medium Intensity Statin"
  ["Medication, Dispensed": "Atorvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Amlodipine Atorvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Rosuvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Simvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Ezetimibe Simvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Pravastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Lovastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Fluvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Pitavastatin Moderate Intensity Medications"]

define "Low Intensity Statin"
  ["Medication, Dispensed": "Ezetimibe Simvastatin Low Intensity Medications"]
  union ["Medication, Dispensed": "Fluvastatin Low Intensity Medications"]
  union ["Medication, Dispensed": "Lovastatin Low Intensity Medications"]
  union ["Medication, Dispensed": "Pitavastatin Low Intensity Medications"]
  union ["Medication, Dispensed": "Pravastatin Low Intensity Medications"]
  union ["Medication, Dispensed": "Simvastatin Low Intensity Medications"]


define "Sum of Prescription Durations"
    Sum((collapse("Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Atorvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Amlodipine Atorvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Rosuvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Simvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Ezetimibe Simvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Atorvastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Amlodipine Atorvastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Rosuvastatin High Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Simvastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Ezetimibe Simvastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Pravastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Lovastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Fluvastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Pitavastatin Moderate Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Ezetimibe Simvastatin Low Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Fluvastatin Low Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Lovastatin Low Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Pitavastatin Low Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Pravastatin Low Intensity Medications"],"Statin","Measurement Period")
    union "Medications Dispensed Relevant Periods Valuesets"(["Medication, Dispensed": "Simvastatin Low Intensity Medications"],"Statin","Measurement Period")
    ) X
    return all duration in days of X)


define "Statin Med List":
  ["High Intensity Statin"]
  union ["Medium Intensity Statin"]
  union ["Low Intensity Statin"]

define "Sum of Prescription Durations"
    "CumulativeDuration"("Statin Med List", "Measurement Period")

define "Prescription Start Date":
  "Statin Med List" M
    return start of M.relevantPeriod

define "First Prescription Start Date":
  First("Prescription Start Date")

define "Treatment Period":
  days between "First Prescription Start Date" and end of "Measurement Period"

/* Populations */

define "Denominator":
  "HEDIS SPD1: Performance Met"

define "Denominator Exclusion: Condition"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS SPD1: Denominator Exclusion: Condition"

define "Denominator Exclusion: Pregnancy"
  /*
  * config_link_id: exclusion_2
  */
  "HEDIS SPD1: Denominator Exclusion: Pregnancy"

define "Denominator Exclusion: Diabetes"
  /*
  * config_link_id: exclusion_3
  */
  "HEDIS SPD1: Denominator Exclusion: Diabetes"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
 /*
  * config_link_id: exclusion_required_frailty
  */
  AgeInYearsAt(end of "Measurement Period") >= 66
   and ("LTI During Period"("Measurement Period")
         or "SNP"("Measurement Period")
         or ("Advanced Illness"("Measurement Period and Year Prior")
             and "Frailty: Claim During Period"("Measurement Period")
           )
     )


define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  Round(("Sum of Prescription Durations" / "Treatment Period") * 100) >= 80

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Diabetes"
  and not "Exclusion: Hospice"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
