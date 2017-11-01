library MIPS_337_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 337
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 337 Encounter"
valueset "MIPS; MIPS 337 Rheumatoid Arthritis"
valueset "MIPS; Psoriasis"
valueset "MIPS; Psoriatic Arthritis"
valueset "MIPS; Biologic Immune Response Modifier"
valueset "MIPS; Performance Met: G9359"
valueset "MIPS; Performance Not Met: G9360"

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Diagnosis":
  ["Diagnosis": "MIPS; MIPS 337 Rheumatoid Arthritis"]
  union ["Diagnosis": "MIPS; Psoriasis"]
  union ["Diagnosis": "MIPS; Psoriatic Arthritis"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 337 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with "Denominator Diagnosis" D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Procedure, Performed": "MIPS; Biologic Immune Response Modifier"] P
    such that P.relevantPeriod starts during "Denominator Period"])

define "Numerator Performance Met: G9359":
  /*
   * config_link_id: G9359
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9359"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9360":
  /*
   * config_link_id: G9360
   */
  not "Numerator Performance Met: G9359"
