library MIPS_SEM_2017 version '1'

/*
 * Source: MIPS
 * ID: SEM
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// VSAC Value Sets

valueset "VSAC; Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "VSAC; Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "VSAC; Preventive Care - Established Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "VSAC; Preventive Care- Initial Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1022'
valueset "VSAC; Outpatient Consultation": '2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "VSAC; Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "VSAC; Preventive Care Services - Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "VSAC; Annual Wellness Visit": '2.16.840.1.113883.3.526.3.1240'

// Able Value Sets

valueset "Able; Performance Met: ACI_TRANS_SM_1"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator-Eligible Encounter":
  ["Encounter, Performed": "VSAC; Office Visit"]
  union ["Encounter, Performed": "VSAC; Face-to-Face Interaction"]
  union ["Encounter, Performed": "VSAC; Preventive Care - Established Office Visit, 0 to 17"]
  union ["Encounter, Performed": "VSAC; Preventive Care- Initial Office Visit, 0 to 17"]
  union ["Encounter, Performed": "VSAC; Outpatient Consultation"]
  union ["Encounter, Performed": "VSAC; Preventive Care Services - Established Office Visit, 18 and Up"]
  union ["Encounter, Performed": "VSAC; Preventive Care Services - Initial Office Visit, 18 and Up"]
  union ["Encounter, Performed": "VSAC; Annual Wellness Visit"]

define "Denominator Encounter":
  exists("Denominator-Eligible Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = 1)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "Able; Performance Met: ACI_TRANS_SM_1"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
