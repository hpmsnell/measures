library MIPS_019_2017 version '1'

/*
 * Source: MIPS
 * ID: 019
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
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
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 019 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Diabetic Retinopathy"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator Encounter with Exam":
  "Denominator Encounter"
    with ["Procedure, Performed": "VSAC; Macular Exam"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Encounter with Findings":
  "Denominator Encounter"
    with ["Procedure, Performed": "Able; Macular Edema Finding"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "Able; Retinopathy Finding"]
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter with Exam")
  or exists("Denominator Encounter with Findings")

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
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 5010F-2P":
  /*
   * config_link_id: 5010F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 5010F-2P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 5010F-8P":
  /*
   * config_link_id: 5010F-8P
   */
  and "Numerator Performance Met: 5010F"
  and not "Denominator Exception: 5010F-1P"
  and not "Denominator Exception: 5010F-2P"
