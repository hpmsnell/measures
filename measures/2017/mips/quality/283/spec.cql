library MIPS_283_2017 version '1'

/*
 * Source: MIPS
 * ID: 283
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 283 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: 1181F"
valueset "MIPS; Performance Not Met: 1181F-8P"

// Able value sets

valueset "Able; Neuropsychiatric Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 283 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 1181F":
  /*
   * config_link_id: 1181F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1181F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Neuropsychiatric Assessment"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 1181F-8P":
  /*
   * config_link_id: 1181F-8P
   */
  not "Numerator Performance Met: 1181F"
