library MIPS_137_2019 version '1'

/*
 * Source: MIPS
 * ID: 137
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 137 Encounter"
valueset "MIPS; Melanoma"
valueset "MIPS; Performance Met: 7010F"
valueset "MIPS; Denominator Exception: 7010F-3P"
valueset "MIPS; Performance Not Met: 7010F-8P"


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 137 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Melanoma"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 7010F":
  /*
   * config_link_id: 7010F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 7010F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 7010F-3P":
  /*
   * config_link_id: 7010F
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 7010F-3P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 7010F-8P":
  /*
   * config_link_id: 7010F-8P
   */
  not "Numerator Performance Met: 7010F"
  and not "Denominator Exception: 7010F-3P"
