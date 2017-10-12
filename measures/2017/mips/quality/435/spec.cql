library MIPS_435_2017 version '1'

/*
 * Source: MIPS
 * ID: 435
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 435 Encounter"
valueset "MIPS; Primary Headache"
valueset "MIPS; Performance Met: G9634"
valueset "MIPS; Denominator Exception: G9635"
valueset "MIPS; Performance Not Met: G9636"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 435 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Primary Headache"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9634":
  /*
   * config_link_id: G9634
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9634"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G9635":
  /*
   * config_link_id: G9635
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9635"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9636":
  /*
   * config_link_id: G9636
   */
  and "Numerator Performance Met: G9634"
  and not "Denominator Exception: G9635"
