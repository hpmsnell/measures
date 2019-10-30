library HEDIS_SPD1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPD1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Acute Inpatient":
valueset "HEDIS; Inpatient Stay":
valueset "HEDIS; IVD":
valueset "HEDIS; PCI":
valueset "HEDIS; Other Revascularization":
valueset "HEDIS; ESRD":
valueset "HEDIS; Cirrhosis":
valueset "HEDIS; Pregnancy":
valueset "HEDIS; IVF":
valueset "HEDIS; Estrogen Agonists Medications":
valueset "HEDIS; MI":
valueset "HEDIS; CABG":
valueset "HEDIS; Muscular Pain and Disease":
valueset "HEDIS; High and Moderate-Intensity Statin Medications"
valueset "HEDIS; Low-Intensity Statin Medications"

// VSAC value sets
valueset "VSAC; Low intensity statin therapy": '2.16.840.1.113762.1.4.1047.107'
valueset "VSAC; Moderate intensity statin therapy": '2.16.840.1.113762.1.4.1047.98'
valueset "VSAC; High intensity statin therapy": '2.16.840.1.113762.1.4.1047.97'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "IVD Exists During Measurement Year and Prior Year":
  exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  and exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Cardiovascular Procedure":
  ["Procedure, Performed": "HEDIS; PCI"]
  union ["Procedure, Performed": "HEDIS; CABG"]
  union ["Procedure, Performed": "HEDIS; Other Revascularization"]

define "Kidney/Liver Disease":
  ["Diagnosis": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Diagnosis": "HEDIS; Cirrhosis"]

define "Statin":
  ["Medication": "VSAC; Low intensity statin therapy"]
  union ["Medication": "VSAC; Moderate intensity statin therapy"]
  union ["Medication": "VSAC; High intensity statin therapy"]
  union ["Medication": "HEDIS; High and Moderate-Intensity Statin Medications"]
  union ["Medication": "HEDIS; Low-Intensity Statin Medications"]

/* Populations */

define "Denominator":
  "HEDIS CDC1: Denominator"
  and AgeInYearsAt(end of "Measurement Period") >= 40
  and AgeInYearsAt(end of "Measurement Period") < 76
and not exists("Hospice" I
where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Condition"
  /*
  * config_link_id: exclusion_1
  */
  "IVD Exists During Measurement Year and Prior Year"
  or exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; MI"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists(["Diagnosis": "HEDIS; Muscular Pain and Disease"] D
    where D.prevalencePeriod starts during "Measurement Period")
  or exists("Cardiovascular Procedure" P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", start of "Measurement Period"])
  or exists("Kidney/Liver Disease" D
    where D.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Pregnancy"
  /*
  * config_link_id: exclusion_2
  */
  exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])
  or exists(["Procedure, Performed": "HEDIS; IVF"] P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])
  or exists(["Medication, Order": "HEDIS; Estrogen Agonists Medications"] M
    where M.relevantPeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Diabetes"
  /*
  * config_link_id: exclusion_3
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Statin" M
    where M.relevantPeriod starts during "Measurment Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Diabetes"
  and not "Numerator Performance Met"
