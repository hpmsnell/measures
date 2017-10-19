library MIPS_288_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 288
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 288 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: 4322F"
valueset "MIPS; Denominator Exception: 4322F-1P"
valueset "MIPS; Performance Not Met: 4322F-8P"

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 288 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 4322F":
  /*
   * config_link_id: 4322F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4322F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 4322F-1P":
  /*
   * config_link_id: 4322F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4322F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 4322F-8P":
  /*
   * config_link_id: 4322F-8P
   */
  not "Numerator Performance Met: 4322F"
  and not "Denominator Exception: 4322F-1P"
