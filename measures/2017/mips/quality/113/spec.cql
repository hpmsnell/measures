library MIPS_113_2017 version '1'

/*
 * Source: MIPS
 * ID: 113
 * Year: 2017
 * Version: 1
 */

using QDM

// Diagnosis

valueset "VSAC; Malignant Neoplasm of Colon": '2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'

// Encounter, Performed

valueset "MIPS; MIPS 113 Encounter"

// Laboratory Test, Performed

valueset "VSAC; Fecal Occult Blood Test (FOBT)": '2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "HEDIS; FOBT": '2.16.840.1.113883.3.464.1004.1093'

// Procedure, Performed

valueset "VSAC; Colonoscopy": '2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "VSAC; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "VSAC; Total Colectomy": '2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "MIPS; Performance Met: 3017F"
valueset "MIPS; Performance Not Met: 3017F-8P"
valueset "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"

// Intervention, Performed

valueset "VSAC; Palliative Care" '2.16.840.1.113883.3.600.1.1579'
valueset "MIPS; MIPS Hospice Service"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Encounter, Performed": "MIPS; MIPS 113 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period")
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D
    where D.prevalencePeriod starts before end "Denominator Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P
    where P.relevantPeriod starts before end "Denominator Period")
  or exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end "Denominator Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end "Denominator Period")
  or exists (["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"] P
    where P.relevantPeriod starts before end "Denominator Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I //Updated to Intervention, Performed
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I //New value set added
    where I.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: 3017F":
  /*
   * config_link_id: 3017F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period") //New addition
  or exists(["Procedure, Performed": "VSAC; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")
  or exists(["Laboratory Test, Performed": "HEDIS; FOBT"] L where L.resultDateTime during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; FOBT"] L where L.relevantPeriod starts during "Measurement Period")


define "Numerator Performance Not Met: 3017F-8P":
  /*
   * config_link_id: 3017F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 3017F"
