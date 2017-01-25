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
valueset "MIPS; Hospice Service: G9710"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 50
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists(["Encounter, Performed": "MIPS; MIPS 113 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period")
    and E.signingProvider.pqrsProvider = true

define "Denominator Exclusion 1":
  /*
   * metadata_identifier_link: exclusion_1
   */
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D
    where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists (["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer: G9711"] P
    where P.relevantPeriod starts before end "Measurement Period")

define "Denominator Exclusion 2":
  /*
   * metadata_identifier_link: exclusion_2
   */
  exists(["Intervention, Performed": "MIPS; Hospice Service: G9710"] I //Updated to Intervention, Performed
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I //New value set added
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3017F":
  /*
   * metadata_identifier_link: 3017F
   */
  "Denominator"
  and not "Denominator Exclusion"
  and (
    exists(["Procedure, Performed": "MIPS; Performance Met: 3017F"] P where P.relevantPeriod starts during "Measurement Period") //New addition
    or exists(["Procedure, Performed": "VSAC; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
    or exists(["Procedure, Performed": "HEDIS; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
    or exists(["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
    or exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
    or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")
    or exists(["Laboratory Test, Performed": "HEDIS; FOBT"] L where L.resultDateTime during "Measurement Period")
    or exists(["Procedure, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.relevantPeriod starts during "Measurement Period")
    or exists(["Procedure, Performed": "HEDIS; FOBT"] L where L.relevantPeriod starts during "Measurement Period")
    )


define "Numerator Performance Not Met: 3017F-8P":
  /*
   * metadata_identifier_link: 3017F-8P
   */
  "Denominator"
  and not "Denominator Exclusion"
  and not "Numerator Performance Met: 3017F"
