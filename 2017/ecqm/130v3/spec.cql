library eCQM_130v3 version '1'

/*
 * Source: CMS
 * ID: 130v3
 * Year: 2017
 * Version: 1
 */

using QDM

valueset "VSAC; Malignant Neoplasm of Colon": '2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "VSAC; Fecal Occult Blood Test (FOBT)": '2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "VSAC; Colonoscopy": '2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "VSAC; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "VSAC; Total Colectomy": '2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "Annual Wellness Visit": '2.16.840.1.113883.3.526.3.1240'
valueset "Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Home Healthcare Services": '2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001)'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "Annual Wellness Visit"]
  union ["Encounter, Performed": "Face-to-Face Interaction"]
  union ["Encounter, Performed": "Home Healthcare Services"]
  union ["Encounter, Performed": "Office Visit"]
  union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
  union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 50
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists("Denominator Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
    and E.signingProvider.hasMeasure = true)

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists(["Diagnosis": "VSAC; Malignant Neoplasm of Colon"] D
    where D.prevalencePeriod starts before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Total Colectomy"] P
    where P.relevantPeriod starts before end "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "VSAC; Colonoscopy"] P where P.relevantPeriod starts 9 years or less before end "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Flexible Sigmoidoscopy"] P where P.relevantPeriod starts 4 years or less before end "Measurement Period")
  or exists(["Laboratory Test, Performed": "VSAC; Fecal Occult Blood Test (FOBT)"] L where L.resultDateTime during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  "Denominator"
  and not "Denominator Exclusion"
  and not "Numerator Performance Met"
