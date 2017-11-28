library MIPS_286_2017 version '1'

/*
 * Source: MIPS
 * ID: 286
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 286 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: 6101F"
valueset "MIPS; Performance Met: 6102F"
valueset "MIPS; Denominator Exception: 6101F-1P"
valueset "MIPS; Denominator Exception: 6102F-1P"
valueset "MIPS; Performance Not Met: 6101F-8P"
valueset "MIPS; Performance Not Met: 6102F-8P"

// Able value sets

valueset "Able; Dementia Safety Counseling"
valueset "Able; Referral for Dementia Safety Counseling"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 286 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 6101F":
  /*
   * config_link_id: 6101F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 6101F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Dementia Safety Counseling"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 6102F":
  /*
  * config_link_id: 6102F
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: 6102F"] P
   where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Referral for Dementia Safety Counseling"] P
  where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 6101F-1P":
  /*
   * config_link_id: 6101F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 6101F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Denominator Exception: 6102F-1P":
  /*
   * config_link_id: 6102F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 6102F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 6101F-8P":
  /*
   * config_link_id: 6101F-8P
   */
  not exists(["Procedure, Performed": "MIPS; Performance Not Met: 6102F-8P"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 6102F-8P":
 /*
  * config_link_id: 6102F-8P
  */
 not "Numerator Performance Met: 6101F"
 and not "Numerator Performance Met: 6102F"
 and not "Denominator Exception: 6101F-1P"
 and not "Denominator Exception: 6102F-1P"
 and not "Numerator Performance Not Met: 6101F-8P"
