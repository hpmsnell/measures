library MIPS_286_2018 version '1'

/*
 * Source: MIPS
 * ID: 286
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 286 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: G9922"
valueset "MIPS; Performance Met: G9923"
valueset "MIPS; Denominator Exception: G9924"
valueset "MIPS; Performance Not Met: G9925"
valueset "MIPS; Performance Not Met: G9926"

// Able value sets

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 286 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")


define "Numerator Performance Met: G9922":
  /*
   * config_link_id: G9922
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9922"] P //need to build this valueset
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Met: G9923": //need to build this valueset
  /*
  * config_link_id: G9923
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9923"] P
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Denominator Exception: G9924": //need to build this valueset
  /*
   * config_link_id: G9924
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9924"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Not Met: G9926": //need to build this valueset
  /*
   * config_link_id: G9926
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G9926"] P //need to build this valueset
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G9925": //need to build this valueset
 /*
  * config_link_id: G9925
  */
 not "Numerator Performance Met: G9922"
 and not "Numerator Performance Met: G9923"
 and not "Denominator Exception: G9924"
 and not "Numerator Performance Not Met: G9926"
