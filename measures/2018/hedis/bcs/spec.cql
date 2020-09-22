library HEDIS_BCS_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: BCS
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G9899"

// HEDIS value sets

valueset "HEDIS; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1042'
valueset "HEDIS; History of Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1331'
valueset "HEDIS; Unilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1256'
valueset "HEDIS; Absence of Left Breast": '2.16.840.1.113883.3.464.1004.1329'
valueset "HEDIS; Absence of Right Breast": '2.16.840.1.113883.3.464.1004.1330'
valueset "HEDIS; Unilateral Mastectomy Left": '2.16.840.1.113883.3.464.1004.1334'
valueset "HEDIS; Unilateral Mastectomy Right": '2.16.840.1.113883.3.464.1004.1335'
valueset "HEDIS; Mammography": '2.16.840.1.113883.3.464.1004.1168'
valueset "HEDIS; Frailty"and "HEDIS; Advanced Illness"
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

define "Absence of Left Breast Exists":
  exists(["Diagnosis": "HEDIS; Absence of Left Breast"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy Left"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period"
      and P.code.modifier in {'LT'})

define "Absence of Right Breast Exists":
  exists(["Diagnosis": "HEDIS; Absence of Right Breast"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy Right"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period"
      and P.code.modifier in {'RT'})

define "Absence of Left and Right Breast Exists":
  "Absence of Left Breast Exists"
  and "Absence of Right Breast Exists"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 52
  and AgeInYearsAt(end of "Measurement Period") < 75
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Mastectomy":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "HEDIS; Bilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period"
      and A.code.modifier in {'50'})
  or exists(["Diagnosis": "HEDIS; History of Bilateral Mastectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P1
    with ["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P2
      such that P1.relevantPeriod starts 14 days or more before start of P2.relevantPeriod
        and P1.code.modifier != P2.code.modifier)
  or "Absence of Left and Right Breast Exists"

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
  exists("Procedure, Performed": "HEDIS; Mammography"] P
    where P.relevantPeriod starts during [27 months before end of "Measurement Period", end of "Measurement Period")
  or exists("Procedure, Performed": "MIPS; Performance Met: G9899"] P
    where P.relevantPeriod starts during [27 months before end of "Measurement Period", end of "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Mastectomy"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
