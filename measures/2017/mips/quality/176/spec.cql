library MIPS_176_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 176
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 176 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; First-Time Anti-Rheumatic Drug Therapy"
valueset "MIPS; Performance Met: 3455F"
valueset "MIPS; Denominator Exception: 3455F-1P"
valueset "MIPS; Performance Not Met: 3455F-8P"

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 176 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Procedure, Performed": "MIPS; First-Time Anti-Rheumatic Drug Therapy"] P
    where P.relevantPeriod starts during "Denominator Period"])

define "Numerator Performance Met: 3455F":
  /*
   * config_link_id: 3455F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3455F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 3455F-1P":
  /*
   * config_link_id: 3455F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3455F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3455F-8P":
  /*
   * config_link_id: 3455F-8P
   */
  not "Numerator Performance Met: 3455F"
  and not "Denominator Exception: 3455F-1P"
