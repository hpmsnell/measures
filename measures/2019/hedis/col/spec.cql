library HEDIS_COL_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: COL
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; History of Total Colectomy or Colorectal Cancer"
valueset "MIPS; Performance Met: 3017F"

// HEDIS value sets

valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; FOBT": '2.16.840.1.113883.3.464.1004.1093'
valueset "HEDIS; CT Colonography": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT-DNA": '2.16.840.1.113883.3.464.1004.1420'
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Outpatient"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"
valueset "HEDIS; Nonacute Inpatient"
valueset "HEDIS; Acute Inpatient"
valueset "HEDIS; Hospice"

// NCQA value sets

valueset "NCQA; Dementia Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Visit with Advanced Illness":
  "Visit" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Advanced Illness Exists":
  exists("Visit with Advanced Illness" E1
    with "Visit with Advanced Illness" E2
      such that E1.relevantPeriod starts after E2.relevantPeriod)
  or exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists(["Medication, Order": "NCQA; Dementia Medications"] M
    where M.relevantPeriod starts during "Measurement Period")

/* POPULATIONS */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 51
  and AgeInYearsAt(end of "Measurement Period") < 76
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Colectomy or Cancer":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Colorectal Cancer"] P
    where P.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * config_link_id: exclusion_2
   */
  AgeInYearsAt(end of "Measurement Period") >= 66
  and (
    exists(["Diagnosis": "HEDIS; Frailty"] D
      where D.prevalencePeriod overlaps "Measurement Period")
    or exists(["Procedure, Performed": "HEDIS; Frailty"] D
      where D.prevalencePeriod overlaps "Measurement Period")
  )
  and "Advanced Illness Exists"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Colonoscopy"] P where P.relevantPeriod starts 10 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 5 years or less before end of "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FOBT"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FOBT"] L where L.relevantPeriod starts during "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FIT-DNA"] L where L.resultDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FIT-DNA"] L where L.relevantPeriod starts 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; CT Colonography"] L where L.relevantPeriod starts 5 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Colectomy or Cancer"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
