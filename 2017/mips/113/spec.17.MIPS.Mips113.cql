library MIPS_113_2017 version '1'

/*
 * Based on MIPS Registry specification for #113 Colorectal Cancer Screening
 */

using QDM

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
valueset "MIPS; Medical Performance Exclusion: 3017F-1P"
valueset "MIPS; Performance Not Met: 3017F-8P"
valueset "MIPS; History of Total Colectomy or Colorectal Cancer"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Valid Procedures":
  distinct(
    ["Procedure, Performed": "VSAC; Colonoscopy"]
    union ["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"]
    union ["Procedure, Performed": "HEDIS; Colonoscopy"]
    union ["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"]
    )

define "Valid Laboratory Tests":
  distinct{
    ["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"]
    union ["Laboratory Test, Performed": "HEDIS; FOBT"]
  }

define "Initial Patient Population":
AgeInYearsAt(start of "Measurement Period") >= 50
and AgeInYearsAt(start of "Measurement Period") < 75
and exists(["Encounter, Performed": "113 Encounter"] E where E.performanceTime during "Measurement Period")

define "Denominator":
  "Initial Patient Population"

define "Denominator Exclusions":
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "HEDIS; Total Colectomy"] P where P.relevantPeriod starts before end "Measurement Period")
  or exists (["Procedure, Performed": "MIPS; History of Total Colectomy or Colorectal Cancer"] P where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Encounter, Performed": "Hospice Service"] E where E.performanceTime during "Measurement Period")

define "Numerator Success 3017F":
  "Denominator"
  and not "Denominator Exclusions"
  and (
    exists(["Valid Procedures"] P where P.relevantPeriod ends before end "Measurement Period")
    or exists(["Valid Laboratory Tests"] L where L.resultDateTime during "Measurement Period")
    )

define "Numerator Failure 3017F-8P":
  "Denominator"
  and not "Denominator Exclusions"
  and not "Numerator 3017F"
