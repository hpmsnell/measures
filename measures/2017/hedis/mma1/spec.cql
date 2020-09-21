library HEDIS_MMA1_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: MMA1
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Asthma": '2.16.840.1.113883.3.464.1004.1025'
valueset "HEDIS; Emphysema": '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; Other Emphysema": '2.16.840.1.113883.3.464.1004.1200'
valueset "HEDIS; COPD": '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; Obstructive Chronic Bronchitis": '2.16.840.1.113883.3.464.1004.1193'
valueset "HEDIS; Chronic Respiratory Conditions Due to Fumes/Vapors": '2.16.840.1.113883.3.464.1004.1063'
valueset "HEDIS; Cystic Fibrosis": '2.16.840.1.113883.3.464.1004.1068'
valueset "HEDIS; Acute Respiratory Failure": '2.16.840.1.113883.3.464.1004.1019'
valueset "HEDIS; Asthma Controller Medication"
valueset "HEDIS; Asthma Reliever Medication"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Visit or Medication Exists During Measurement Year"
  "Inpatient Visit with Asthma Exists During Measurement Year"
  or "Four Outpatient Visits With Asthma and Two Medications Exist During Measurement Year"
  or "Four Medications Exist During Measurement Year"

define "Visit or Medication Exists During Prior Year"
  "Inpatient Visit with Asthma Exists During Prior Year"
  or "Four Outpatient Visits With Asthma and Two Medications Exist During Prior Year"
  or "Four Medications Exist During Prior Year"

define "Inpatient Visit":
  ["Encounter, Performed": "HEDIS: ED"]
  union ["Encounter, Performed": "HEDIS: Acute Inpatient"]

define "Inpatient Visit with Asthma Exists During Measurement Year":
  exists("Inpatient Visit" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Inpatient Visit with Asthma Exists During Prior Year":
  exists("Inpatient Visit" E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Outpatient Visit":
  ["Encounter, Performed": "HEDIS: Outpatient"]
  union ["Encounter, Performed": "HEDIS: Observation"]

define "Asthma Medication":
  ["Medication, Order": "HEDIS; Asthma Controller Medication"]
  union ["Medication, Order": "HEDIS; Asthma Reliever Medication"]

define "Four Outpatient Visits With Asthma and Two Medications Exist During Measurement Year":
  count("Outpatient Visit" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during E.relevantPeriod) >= 4
  and count("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period") >= 2

define "Four Outpatient Visits With Asthma and Two Medications Exist During Prior Year":
  count("Outpatient Visit" E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during E.relevantPeriod) >= 4
  and count("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period") >= 2

define "Four Medications Exist During Measurement Year":
  count("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period") >= 4

define "Four Medications Exist During Prior Year":
  count("Asthma Medication" M
    where M.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"]) >= 4

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Excluded Condition":
  ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Other Emphysema"]
  union ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Obstructive Chronic Bronchitis"]
  union ["Diagnosis": "HEDIS; Chronic Respiratory Conditions Due to Fumes/Vapors"]
  union ["Diagnosis": "HEDIS; Cystic Fibrosis"]
  union ["Diagnosis": "HEDIS; Acute Respiratory Failure"]

define "Asthma Medication Start Date":
  ["Medication, Order": "HEDIS; Asthma Controller Medication"] M
    where M.relevantPeriod starts during "Measurement Period"
    return start of M.relevantPeriod

define "Asthma Medication Stop Date":
  ["Medication, Order": "HEDIS; Asthma Controller Medication"] M
    where M.relevantPeriod starts during "Measurement Period"
    return end of M.relevantPeriod

define "Asthma Medication Stop Date or End of Measurement Period":
  Lower("Asthma Medication Stop Date", end of "Measurement Period")

define "First Asthma Medication Start Date":
  First(["Medication, Order": "HEDIS; Asthma Controller Medication"] M
    where M.relevantPeriod starts during "Measurement Period"
    sort by start of M.relevantPeriod asc)
    return start of M.relevantPeriod

define "Treatment Period":
  ["First Asthma Medication Start Date", end of "Measurement Period"]

define "Days Covered Per Medication":
  "Asthma Medication Stop Date or End of Measurement Period" - "Asthma Medication Start Date"

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 5
  and AgeInYearsAt(end of "Measurement Period") < 65
  and "Visit or Medication Exists During Measurement Year"
  and "Visit or Medication Exists During Prior Year"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Condition":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Excluded Condition"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Denominator Exclusion: No Medication":
  /*
   * config_link_id: exclusion_1
   */
  not exists(["Medication, Order": "HEDIS; Asthma Controller Medication"] M
    where M.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  Sum("Days Covered Per Medication") / "Treatment Period" >= 0.5

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: No Medication"
  and not "Numerator Performance Met"
