library MIPS_254_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 254
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 254 Encounter"
valueset "MIPS; Abdominal Pain"
valueset "MIPS; Other Condition Complicating Pregnancy"
valueset "MIPS; Abdominal Pain"
valueset "MIPS; Vaginal Bleeding"
valueset "MIPS; Performance Met: G8806"
valueset "MIPS; Denominator Exception: G8807"
valueset "MIPS; Performance Not Met: G8808"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Abdominal Pain or Vaginal Bleeding":
  ["Diagnosis": "MIPS; Abdominal Pain"]
  union ["Diagnosis": "MIPS; Vaginal Bleeding"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 254 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and "Patient Characteristic Sex" = 'Female'
      and AgeInYearsAt(start of E.relevantPeriod) >= 14
      and AgeInYearsAt(start of E.relevantPeriod) < 50
      and E.signingProvider.hasMeasureMembership = true
      and E.placeOfService = 23
    with "Abdominal Pain or Vaginal Bleeding" D1
      such that D1.prevalencePeriod starts during E.relevantPeriod
    with ["Diagnosis": "Other Condition Complicating Pregnancy"] D2
      such that D2.prevalencePeriod overlaps E.relevantPeriod

/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8806":
  /*
   * config_link_id: G8806
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8806"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G8807":
  /*
   * config_link_id: G8807
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8807"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G8808":
  /*
   * config_link_id: G8808
   */
  not "Numerator Performance Met: G8806"
  and not "Denominator Exception: G8807"
