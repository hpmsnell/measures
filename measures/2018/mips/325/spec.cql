library MIPS_325_2017 version '1'

/*
 * Source: MIPS
 * ID: 325
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 325 Encounter"
valueset "MIPS; Major Depressive Disorder (MDD)"
valueset "MIPS; Performance Met: G8959"
valueset "MIPS; Denominator Exception: G9232"
valueset "MIPS; Performance Not Met: G8960"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Comorbid Diagnosis":
  ["Diagnosis": "MIPS; MIPS 325 Diabetes"]
  union ["Diagnosis": "MIPS; MIPS 325 CAD"]
  union ["Diagnosis": "MIPS; MIPS 325 Stroke"]
  union ["Diagnosis": "MIPS; MIPS 325 Kidney Disease"]
  union ["Diagnosis": "MIPS; MIPS 325 Heart Failure"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 325 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Major Depressive Disorder (MDD)"] D1
      such that D1.prevalencePeriod overlaps E.relevantPeriod
    with "Comorbid Condition" D2
      such that D2.prevalencePeriod overlaps E.relevantPeriod

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8959":
  /*
   * config_link_id: G8959
   */
  exists("Procedure, Performed": "MIPS; Performance Met: G8959"] P
      where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G9232":
  /*
   * config_link_id: G9232
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9232"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8960":
  /*
   * config_link_id: G8960
   */
  not "Numerator Performance Met: G8959"
  and not "Denominator Exception: G9232"
