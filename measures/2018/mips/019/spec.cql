library MIPS_019_2018 version '1'

/*
 * Source: MIPS
 * ID: 019
 * Year: 2018
 * Version: 1
 * Author: Becky Weber
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 019 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Diabetic Retinopathy"
valueset "MIPS; Dilated Macular or Fundus Exam"
valueset "MIPS; Performance Met: 5010F"
valueset "MIPS; Denominator Exception: 5010F-1P"
valueset "MIPS; Denominator Exception: 5010F-2P"
valueset "MIPS; Performance Not Met: 5010F-8P"

// Able value sets

valueset "Able; Macular Edema Finding"
valueset "Able; Retinopathy Finding"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 019 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Diabetic Retinopathy"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator Encounter with Exam":
  "Denominator Encounter"
    with ["Procedure, Performed": "MIPS; Dilated Macular or Fundus Exam"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Encounter with Findings":
  "Denominator Encounter"
    with ["Procedure, Performed": "Able; Macular Edema Finding"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "Able; Retinopathy Finding"]
      such that P.relevantPeriod starts during E.relevantPeriod

define "Exam or Findings":
  ["Procedure, Performed": "MIPS; Dilated Macular or Fundus Exam"] P
  or ["Procedure, Performed": "Able; Macular Edema Finding"] P1
    with ["Procedure, Performed": "Able; Retinopathy Finding"] P2
      such that P1.relevantPeriod starts during P2.relevantPeriod

define "Denominator Encounter with Exam or Findings":
  "Denominator Encounter" E
    with "Exam or Findings" P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter with Exam or Findings")

define "Numerator Performance Met: 5010F":
  /*
   * config_link_id: 5010F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 5010F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 5010F-1P":
  /*
   * config_link_id: 5010F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 5010F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 5010F-2P":
  /*
   * config_link_id: 5010F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 5010F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 5010F-8P":
  /*
   * config_link_id: 5010F-8P
   */
  and "Numerator Performance Met: 5010F"
  and not "Denominator Exception: 5010F-1P"
  and not "Denominator Exception: 5010F-2P"
