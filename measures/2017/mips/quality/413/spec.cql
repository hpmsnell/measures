library MIPS_413_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 413
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 413 Encounter"
valueset "MIPS; Ischemic Stroke"
valueset "MIPS; Performance Met: G9580"
valueset "MIPS; Performance Not Met: G9582"
valueset "MIPS; Transfer with Diagnosis of CVA"
valueset "MIPS; Hospitalization with Newly Diagnosed CVA"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 413 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Ischemic Stroke"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Exclusion"
  ["Procedure, Performed": "MIPS; Transfer with Diagnosis of CVA"]
  union ["Procedure, Performed": "MIPS; Hospitalization with Newly Diagnosed CVA"]

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: Transfer or Hospitalization"
  /*
   * config_link_id: G9580
   */
  exists("Exclusion Procedure" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9580":
  /*
   * config_link_id: G9580
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9580"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9582":
  /*
   * config_link_id: G9582
   */
  not "Denominator Exclusion: Transfer or Hospitalization"
  and not "Numerator Performance Met: G9580"
