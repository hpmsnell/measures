library MIPS_127_2017 version '1'

/*
 * Source: MIPS
 * ID: 127
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 127 Encounter"
valueset "MIPS; MIPS 127 Diabetes"
valueset "MIPS; Performance Met: G8410"
valueset "MIPS; Denominator Exception: G8416"
valueset "MIPS; Performance Not Met: G8415"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 127 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 127 Diabetes"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8410":
  /*
   * config_link_id: G8410
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8410"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G8416":
  /*
   * config_link_id: G8416
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8416"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8415":
  /*
   * config_link_id: G8415
   */
  and "Numerator Performance Met: G8410"
  and not "Denominator Exception: G8416"
