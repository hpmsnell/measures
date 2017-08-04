library MIPS_014_2017 version '1'

/*
 * Source: MIPS
 * ID: 014
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 014 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Age-Related Macular Degeneration"
valueset "MIPS; Performance Met: 2019F"
valueset "MIPS; Denominator Exception: 2019F-1P"
valueset "MIPS; Denominator Exception: 2019F-2P"
valueset "MIPS; Performance Not Met: 2019F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 014 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Age-Related Macular Degeneration"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 2019F":
  /*
   * config_link_id: 2019F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2019F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 2019F-1P":
  /*
   * config_link_id: 2019F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 2019F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 2019F-2P":
  /*
   * config_link_id: 2019F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 2019F-2P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 2019F-8P":
  /*
   * config_link_id: 2019F-8P
   */
  and "Numerator Performance Met: 2019F"
  and not "Denominator Exception: 2019F-1P"
  and not "Denominator Exception: 2019F-2P"
