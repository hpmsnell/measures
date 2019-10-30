library HEDIS_SPD2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPD2
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
  union ["Diagnosis": "HEDIS; Cirrhosis"]

define "Statin":
  ["Medication": "VSAC; Low intensity statin therapy"]
  union ["Medication": "VSAC; Moderate intensity statin therapy"]
  union ["Medication": "VSAC; High intensity statin therapy"]
  union ["Medication": "HEDIS; High and Moderate-Intensity Statin Medications"]
  union ["Medication": "HEDIS; Low-Intensity Statin Medications"]

define "Statin in Measurement Period":
  "Statin" M
    where M.relevantPeriod starts during "Measurement Period"

define "Prescription Start Date":
  "Statin in Measurement Period" M
    return start of M.relevantPeriod

define "Prescription Stop Date":
  "Statin in Measurement Period" M
    return end of M.relevantPeriod

define "Prescription Duration":
  Min(
    {
      days between "Prescription Start Date" and "Prescription Stop Date",
      days between "Prescription Start Date" and end of "Measurement Period" // Default to this if Stop Date is null
    }
  )

define "Sum of Prescription Durations":
  Sum("Prescription Duration")

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

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Sum of Prescription Durations" / "Treatment Period" >= 0.8

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Diabetes"
  and not "Numerator Performance Met"
