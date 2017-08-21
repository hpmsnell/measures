library MIPS_178_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 178
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 178 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; Performance Met: 1170F"
valueset "MIPS; Performance Not Met: 1170F-8P"

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 178 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 1170F":
  /*
   * config_link_id: 1170F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1170F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Functional Status Assessment"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 1170F-8P":
  /*
   * config_link_id: 1170F-8P
   */
  not "Numerator Performance Met: 1170F"
