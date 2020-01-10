library MIPS_271_2019 version '1'

/*
 * Source: MIPS
 * ID: 271
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 271 Encounter"
valueset "MIPS; Inflammatory Bowel Disease"
valueset "MIPS; MIPS 271 Corticosteroid"
valueset "MIPS; Performance Met: G8861"
valueset "MIPS; Performance Not Met: G9472"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 271 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    without ["Diagnosis": "MIPS; Inflammatory Bowel Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Procedure, Performed": "MIPS; MIPS 271 Corticosteroid"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G8861":
  /*
   * config_link_id: G8861
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8861"] P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period",end of "Measurement Period"])

define "Numerator Performance Not Met: G9472":
  /*
   * config_link_id: G9472
   */
  not "Numerator Performance Met: G8861"
