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
valueset "MIPS; History of Total Colectomy or Colorectal Cancer"
valueset "MIPS; Performance Met: 3017F"

// HEDIS value sets

valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; FOBT": '2.16.840.1.113883.3.464.1004.1093'
valueset "HEDIS; CT Colonography": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT-DNA": '2.16.840.1.113883.3.464.1004.1420'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Colonoscopy": '2.16.840.1.113883.3.464.1003.108.12.1020'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 51
  and AgeInYearsAt(end of "Measurement Period") < 76
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Colorectal Cancer"] P
    where P.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer"] P
    where P.relevantPeriod starts before end of "Measurement Period")

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
  or exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
