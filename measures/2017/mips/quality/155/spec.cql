library MIPS_155_2017 version '1'

/*
 * Source: MIPS
 * ID: 155
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 155 Encounter"
valueset "MIPS; Falls in Past Year"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 0518F"
valueset "MIPS; Denominator Exception: 0518F-1P"
valueset "MIPS; Performance Not Met: 0518F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Falls Screening": '	2.16.840.1.113883.3.464.1003.118.12.1028'
valueset "VSAC; Patient not ambulatory": '2.16.840.1.113883.3.464.1003.118.12.1009'

// HEDIS Value Sets

valueset "HEDIS; Falls": '2.16.840.1.113883.3.464.1004.1101'

// Able Value Sets

valueset "ABLE; Fall"
valueset "ABLE; Fall with Injury"
valueset "ABLE; Falls Diet Recommendation"
valueset "ABLE; Falls Training Recommendation"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 155 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.hasMeasureMembership = true

define "Fall":
  ["Diagnosis": "HEDIS; Falls"]
  union ["Diagnosis": "ABLE; Fall"]

define "Denominator":
  "MIPS 154 Performance Met: 3288F"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: 0518F":
  /*
   * config_link_id: 0518F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 0518F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists(["Intervention, Performed": "ABLE; Falls Diet Recommendation"] I
      where I.authorDateTime during "Measurement Period")
    and exists("["Intervention, Performed": "ABLE; Falls Training Recommendation"]" I
      where I.authorDateTime during "Measurement Period")
  )

define "Denominator Exception: 0518F-1P":
  /*
   * config_link_id: 0518F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 0518F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Patient not ambulatory"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 0518F-8P":
  /*
   * config_link_id: 0518F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 0518F"
   and not "Denominator Exception: 0518F-1P"
