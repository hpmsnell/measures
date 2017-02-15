library MIPS_113_2017 version '1'

/*
 * Based on MIPS Registry specification for #113 Colorectal Cancer Screening
 */

using Able

// Diagnosis

valueset "VSAC; Malignant Neoplasm of Colon": '2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'

// Encounter, Performed

valueset "MIPS; 113 Encounter"
valueset "MIPS; Hospice Service"

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
valueset "MIPS; History of Total Colectomy or Colorectal Cancer"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 50
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists(["Clinical Activity": "113 Encounter"] E where E.startDateTime during "Measurement Period")

define "Denominator Exclusion":
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D where D.startDateTime before end "Measurement Period")
  or exists(["Clinical Activity": "VSAC; Total Colectomy"] P where P.startDateTime before end "Measurement Period")
  or exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D where D.startDateTime before end "Measurement Period")
  or exists(["Clinical Activity": "HEDIS; Total Colectomy"] P where P.startDateTime before end "Measurement Period")
  or exists (["Clinical Activity": "MIPS; History of Total Colectomy or Colorectal Cancer"] P where P.startDateTime before end "Measurement Period")
  or exists(["Clinical Activity": "Hospice Service"] E where E.startDateTime during "Measurement Period")

define "Numerator Success: 3017F":
  "Denominator"
  and not "Denominator Exclusions"
  and (
    exists(["Clinical Activity": "VSAC; Colonoscopy"] P where P.startDateTime 9 years or less before end "Measurement Period")
    or exists(["Clinical Activity": "HEDIS; Colonoscopy"] P where P.startDateTime 9 years or less before end "Measurement Period")
    or exists(["Clinical Activity": "VSAC; Flexible Sigmoidoscopy"] P where P.startDateTime 4 years or less before end "Measurement Period")
    or exists(["Clinical Activity": "HEDIS; Flexible Sigmoidoscopy"] P where P.startDateTime 4 years or less before end "Measurement Period")
    or exists(["Laboratory Test": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.startDateTime during "Measurement Period")
    or exists(["Laboratory Test": "HEDIS; FOBT"] L where L.startDateTime during "Measurement Period")
    )

define "Numerator Failure: 3017F-8P":
  "Denominator"
  and not "Denominator Exclusion"
  and not "Numerator Success: 3017F"
