library MIPS_156_2018 version '1'

/*
 * Source: MIPS
 * ID: 156
 * Year: 2018
 * Version: 1
 * Author: Becky Weber
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 156 Encounter"
valueset "MIPS; MIPS 156 Cancer"
valueset "MIPS; MIPS 156 Metastatic Cancer"
valueset "MIPS; Performance Met: 0520F"
valueset "MIPS; Performance Not Met: 0520F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 156 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 156 Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    without ["Diagnosis": "MIPS; MIPS 156 Metastatic Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 0520F":
  /*
   * config_link_id: 0520F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 0520F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 0520F-8P":
 /*
  * config_link_id: 0520F-8P
  */
 not "Numerator Performance Met: 0520F"
