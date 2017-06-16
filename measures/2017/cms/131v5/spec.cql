library MIPS_131v5_2017 version '1'

/*
 * Source: MIPS
 * ID: 131v5
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

valueset "VSAC; Annual Wellness Visit": '2.16.840.1.113883.3.526.3.1240'
valueset "VSAC; Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "VSAC; Home Healthcare Services": '2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "VSAC; Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001)'
valueset "VSAC; Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "VSAC; Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "VSAC; Ophthalmological Services": '2.16.840.1.113883.3.526.3.1285'
valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Retinal or Dilated Eye Exam": '2.16.840.1.113883.3.464.1003.115.12.1088'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "VSAC; Annual Wellness Visit"]
  union ["Encounter, Performed": "VSAC; Face-to-Face Interaction"]
  union ["Encounter, Performed": "VSAC; Home Healthcare Services"]
  union ["Encounter, Performed": "VSAC; Office Visit"]
  union ["Encounter, Performed": "VSAC; Preventive Care Services - Established Office Visit, 18 and Up"]
  union ["Encounter, Performed": "VSAC; Preventive Care Services-Initial Office Visit, 18 and Up"]
  union ["Encounter, Performed": "VSAC; Ophthalmological Services"]

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists("Denominator Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true)
  and exists(["Diagnosis": "MIPS; Diabetes"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
    where P.relevantPeriod starts 1 year or less before start of "Measurement Period"
      and result = 'negative')

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
   not "Numerator Performance Met"
