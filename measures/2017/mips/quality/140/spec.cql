library MIPS_140_2017 version '1'

/*
 * Source: MIPS
 * ID: 140
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 140 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Age-Related Macular Degeneration"
valueset "MIPS; Performance Met: 4177F"
valueset "MIPS; Performance Not Met: 4177F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 140 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Age-Related Macular Degeneration"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 4177F":
  /*
   * config_link_id: 4177F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4177F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 4177F-8P":
  /*
   * config_link_id: 4177F-8P
   */
  and "Numerator Performance Met: 4177F"
