library HEDIS_CDC4_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC4
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; CABG": ''
valueset "HEDIS; PCI": ''
valueset "HEDIS; Chronic Heart Failure": ''
valueset "HEDIS; MI ": ''
valueset "HEDIS; ESRD": ''
valueset "HEDIS; ESRD Obsolete": ''
valueset "HEDIS; CKD Stage 4": ''
valueset "HEDIS; Dementia": ''
valueset "HEDIS; Frontotemporal Dementia": ''
valueset "HEDIS; Blindness": ''
valueset "HEDIS; Lower Extremity Amputation": ''
valueset "HEDIS; IVD": ''
valueset "HEDIS; Thoracic Aortic Aneurysm": ''
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Outpatient"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"
valueset "HEDIS; Nonacute Inpatient"
valueset "HEDIS; Acute Inpatient"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

define "Last HbA1c Result":
  Last(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year"
      and not L.result = null
    sort by L.resultDateTime asc
    return L.result)

define "Recent Excluded Procedure":
  ["Diagnosis": "HEDIS; CABG"]
  union ["Diagnosis": "HEDIS; PCI"]

define "Historical Excluded Diagnosis":
  ["Diagnosis": "HEDIS; Chronic Heart Failure"]
  union ["Diagnosis": "HEDIS; MI"]
  union ["Diagnosis": "HEDIS; ESRD"]
  union ["Diagnosis": "HEDIS; ESRD Obsolete"]
  union ["Diagnosis": "HEDIS; CKD Stage 4"]
  union ["Diagnosis": "HEDIS; Dementia"]
  union ["Diagnosis": "HEDIS; Frontotemporal Dementia"]
  union ["Diagnosis": "HEDIS; Blindness"]
  union ["Diagnosis": "HEDIS; Lower Extremity Amputation"]

define "Encounter":
  ["Encounter": "HEDIS; Outpatient"]
  union ["Encounter": "HEDIS; Acute Inpatient"]

define "IVD Exists During Measurement Period and Year Prior":
  exists("Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  and exists("Encounter" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Aneurysm Exists During Measurement Period and Year Prior":
  exists("Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Thoracic Aortic Aneurysm"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  and exists("Encounter" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Thoracic Aortic Aneurysm"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

/* Populations */

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   "HEDIS CDC1: Exclusion: Hospice"

define "Denominator Exclusion: Frailty or Advanced Illness"
  /*
  * config_link_id: exclusion_frailty_advanced_illness
  */
  "HEDIS CDC1: Denominator Exclusion: Frailty and Advanced Illness"


define "Denominator Exclusion: Selected Population"
  /*
  * config_link_id: exclusion_2
  */
  AgeInYearsAt(end of "Measurement Period") >= 65
  or exists("Recent Excluded Procedure" P
    where P.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists("Historical Excluded Diagnosis" D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Encounter"] E
    where E.prevalencePeriod starts before end of "Measurement Period"
    and E.placeOfService = '65')
  or "IVD Exists During Measurement Period and Year Prior"
  or "Aneurysm Exists During Measurement Period and Year Prior"

define "Numerator Performance Met: Controlled HbA1c":
  /*
   * config_link_id: hba1c_controlled
   */
  "Last HbA1c Result" < 7

define "Numerator Performance Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  "Last HbA1c Result" >= 7

define "Numerator Performance Not Met: No HbA1c":
  /*
   * config_link_id: hba1c_none
   */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met: Controlled HbA1c"
  and not "Numerator Performance Not Met: High HbA1c"
