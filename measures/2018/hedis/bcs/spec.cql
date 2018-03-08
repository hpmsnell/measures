library HEDIS_BCS_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: BCS
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1042'
valueset "HEDIS; History of Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1331'
valueset "HEDIS; Unilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1256'
valueset "HEDIS; Absence of Left Breast": '2.16.840.1.113883.3.464.1004.1329'
valueset "HEDIS; Absence of Right Breast": '2.16.840.1.113883.3.464.1004.1330'
valueset "HEDIS; Unilateral Mastectomy Left": '2.16.840.1.113883.3.464.1004.1334'
valueset "HEDIS; Unilateral Mastectomy Right": '2.16.840.1.113883.3.464.1004.1335'
valueset "HEDIS; Mammography": '2.16.840.1.113883.3.464.1004.1168'

parameter "Measurement Period" Interval<DateTime>

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Absence of Left Breast Exists":
  exists(["Diagnosis": "HEDIS; Absence of Left Breast"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy Left"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Absence of Right Breast Exists":
  exists(["Diagnosis": "HEDIS; Absence of Right Breast"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy Right"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Absence of Left and Right Breast Exists":
  "Absence of Left Breast Exists"
  and "Absence of Right Breast Exists"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 52
  and AgeInYearsAt(end of "Measurement Period") < 75
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "HEDIS; Bilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "HEDIS; History of Bilateral Mastectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P1
    with ["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P2
      such that P1.relevantPeriod starts 14 days or more before start of P2.relevantPeriod)
  or "Absence of Left and Right Breast Exists"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Procedure, Performed": "HEDIS; Mammography"] P
    where P.relevantPeriod starts during [27 months before end of "Measurement Period", end of "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
