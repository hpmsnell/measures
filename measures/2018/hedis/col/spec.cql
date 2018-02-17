library HEDIS_COL_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: COL
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; FOBT": '2.16.840.1.113883.3.464.1004.1093'
valueset "HEDIS; CT Colonography": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT-DNA": '2.16.840.1.113883.3.464.1004.1420'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice Exists":
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 51
  and AgeInYearsAt(end of "Measurement Period") < 76
  and not "Hospice Exists"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end "Measurement Period")
 exists(["Procedure, Performed": "HEDIS; Colorectal Cancer"] P
   where P.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Colonoscopy"] P where P.relevantPeriod starts 10 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 5 years or less before end of "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FOBT"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FOBT"] L where L.relevantPeriod starts during "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FIT-DNA"] L where L.resultDateTime 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FIT-DNA"] L where L.relevantPeriod starts 3 years or less before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; CT Colonography"] L where L.relevantPeriod starts 5 years or less before end of "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
