library MIPS_125v5_2017 version '1'

/*
 * Source: MIPS
 * ID: 125v5
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

valueset "Annual Wellness Visit": '2.16.840.1.113883.3.526.3.1240'
valueset "Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Home Healthcare Services": '2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001)'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "VSAC; Left Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1069'
valueset "VSAC; Right Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1070'
valueset "VSAC; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1005'
valueset "VSAC; History of bilateral mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1068'
valueset "VSAC; Unilateral Mastectomy": '2.16.840.1.113883.3.464.1003.198.12.1020'
valueset "VSAC; Unilateral Mastectomy, Unspecified Laterality": '2.16.840.1.113883.3.464.1003.198.12.1071'
valueset "VSAC; Mammogram":'2.16.840.1.113883.3.464.1003.108.12.1018'
valueset "VSAC; Female": '2.16.840.1.113883.3.560.100.2'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "Annual Wellness Visit"]
  union ["Encounter, Performed": "Face-to-Face Interaction"]
  union ["Encounter, Performed": "Home Healthcare Services"]
  union ["Encounter, Performed": "Office Visit"]
  union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
  union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]

define "Left Mastectomy Exists":
  exists(["Diagnosis": "VSAC; Left Mastectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "VSAC; Unilateral Mastectomy, Unspecified Laterality"] D
    where D.prevalencePeriod starts before end of "Measurement Period"
      and D.anatomicalLocationSite = "Left")

define "Right Mastectomy Exists":
  exists(["Diagnosis": "VSAC; Right Mastectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "VSAC; Unilateral Mastectomy, Unspecified Laterality"] D
    where D.prevalencePeriod starts before end of "Measurement Period"
      and D.anatomicalLocationSite = "Right")

define "Left and Right Mastectomy Exist":
  "Left Mastectomy Exists"
  and "Right Mastectomy Exists"

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 51
  and AgeInYearsAt(start of "Measurement Period") < 74
  and "Patient Characteristic Sex" in "VSAC; Female"
  and exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists(["Procedure, Performed": "VSAC; Bilateral Mastectomy"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "VSAC; History of bilateral mastectomy"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or count(["Procedure, Performed": "VSAC; Unilateral Mastectomy"] P
    where P.relevantPeriod ends before end of "Measurement Period") = 2
  or "Left and Right Mastectomy Exist"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Diagnostic Study, Performed": "VSAC; Mammogram"] D
    where D.relevantPeriod starts 27 months or less before end of "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
