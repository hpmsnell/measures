library HEDIS_CDC1_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC1
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Outpatient"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"
valueset "HEDIS; Nonacute Inpatient"
valueset "HEDIS; Acute Inpatient"
valueset "HEDIS; Hospice"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// MIPS value sets

valueset "MIPS; Performance Met: 3046F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3045F" //HbA1c Test
valueset "MIPS; Performance Not Met: 3044F" //HbA1c Test

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Nonacute Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"] E
    where not E.code.modifier in {'GT','95'}
    and not E.placeOfService in {'02'}

define "Nonacute Visit with Diabetes":
  "Nonacute Visit" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
      and not E.code.modifier in {'GT','95'}
      and not E.placeOfService in {'02'})
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Patient Has Diabetes":
  exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists("Nonacute Visit with Diabetes" E1
    with "Nonacute Visit with Diabetes" E2
      such that start of E2.relevantPeriod != start of E1.relevantPeriod
      and not E.code.modifier in {'GT','95'}
      and not E.placeOfService in {'02'})
  or exists(["Medication": "HEDIS; Diabetes Medication"] M
    where M.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

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

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 76
  and "Patient Has Diabetes"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

 define "Denominator Exclusion: Diagnosis"
   /*
    * config_link_id: exclusion_1
    */
   not exists(["Diagnosis": "HEDIS; Diabetes"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
   and exists(["Diagnosis": "HEDIS; Diabetes Exclusions"] D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Frailty and Advanced Illness":
  /*
   * config_link_id: exclusion_2
   */
  AgeInYearsAt(end of "Measurement Period") >= 66
  and (
    exists(["Diagnosis": "HEDIS; Frailty"] D
      where D.prevalencePeriod starts during "Measurement Period")
    or exists(["Procedure, Performed": "HEDIS; Frailty"] D
      where D.prevalencePeriod starts during "Measurement Period")
  )
  and "Advanced Illness Exists"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year")
  or exists(["Procedure, Performed": "HEDIS; HbA1c Tests"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Not Met: 3045F"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure, Performed": "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
