library MIPS_179_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 179
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 179 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; Performance Met: 3475F"
valueset "MIPS; Performance Met: 3476F"
valueset "MIPS; Performance Not Met: 3475F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 179 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3475F":
  /*
   * config_link_id: 3475F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3475F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3476F":
  /*
   * config_link_id: 3476F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3476F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3475F-8P":
  /*
   * config_link_id: 3475F-8P
   */
  not "Numerator Performance Met: 3475F"
  and not "Numerator Performance Met: 3476F"
