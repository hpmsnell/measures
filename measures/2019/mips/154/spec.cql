library MIPS_154_2019 version '1'

/*
 * Source: MIPS
 * ID: 154
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 154 Encounter"
valueset "MIPS; Falls in Past Year"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 3288F"
valueset "MIPS; Denominator Exception: 3288F-1P"
valueset "MIPS; Performance Not Met: 3288F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Falls Screening": '	2.16.840.1.113883.3.464.1003.118.12.1028'
valueset "VSAC; Patient not ambulatory": '2.16.840.1.113883.3.464.1003.118.12.1009'

// HEDIS Value Sets

valueset "HEDIS; Falls": '2.16.840.1.113883.3.464.1004.1101'

// Able Value Sets

valueset "Able; Fall"
valueset "Able; Fall with Injury"
valueset "Able; Falls Count Screening"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 154 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.hasMeasureMembership = true

define "Fall":
  ["Diagnosis": "HEDIS; Falls"]
  union ["Diagnosis": "Able; Fall"]

define "Fall Exists":
  exists(["Procedure, Performed": "MIPS; Falls in Past Year"] P
    where P.relevantPeriod starts during "Denominator Period")
  or exists(["Diagnosis": "Able; Fall with Injury"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts on or 1 year or less before start of E.relevantPeriod)
  or count("Fall" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts on or 1 year or less before start of E.relevantPeriod) >= 2
  or exists(["Assessment, Performed": "Able; Falls Count Screening"] A
    where A.authorDateTime during "Measurement Period"
      and A.result_as_decimal >= 2)

define "Denominator":
  exists("Denominator Encounter")
  and "Fall Exists"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: 3288F":
  /*
   * config_link_id: 3288F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3288F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "VSAC; Falls Screening"] A
    where A.authorDateTime during "Measurement Period")

define "Denominator Exception: 3288F-1P":
  /*
   * config_link_id: 3288F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3288F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Patient not ambulatory"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 3288F-8P":
  /*
   * config_link_id: 3288F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 3288F"
   and not "Denominator Exception: 3288F-1P"
