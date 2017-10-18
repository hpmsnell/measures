library MIPS_66v5_2017 version '1'

/*
 * Source: MIPS
 * ID: 66v5
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

valueset "VSAC; Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "VSAC; Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001)'
valueset "VSAC; Outpatient Consultation": '2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "VSAC; Postoperative Visit": '2.16.840.1.113883.3.464.1003.101.12.1070'
valueset "VSAC; Primary TKA Procedure": '2.16.840.1.113883.3.464.1003.198.12.1007'
valueset "VSAC; Functional Status Assessment for Knee Replacement": '2.16.840.1.113883.3.464.1003.118.12.1030'
valueset "VSAC; Fracture - Lower Body": '2.16.840.1.113883.3.464.1003.113.12.1037'
valueset "VSAC; Severe Dementia": '2.16.840.1.113883.3.526.3.1025'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Visit":
  ["Encounter, Performed": "VSAC; Outpatient Consultation"]
  union ["Encounter, Performed": "VSAC; Face-to-Face Interaction"]
  union ["Encounter, Performed": "VSAC; Postoperative Visit"]
  union ["Encounter, Performed": "VSAC; Office Visit"]

define "Denominator Encounter":
  "Denominator Visit"
    where E.signingProvider.hasMeasureMembership = true

define "TKA Procedure":
  ["Procedure, Performed": "VSAC; TKA Procedure"] P
    where P.relevantPeriod ends during Interval[180 days before start of "Measurement Period", 185 days after start of "Measurement Period"]

define "TKA Procedure with Encounters":
  "TKA Procedure" P
    with "Denominator Encounter" E1
      such that P.relevantPeriod starts 180 days or less after end of E1.relevantPeriod)
    with "Denominator Encounter" E2
      such that P.relevantPeriod ends during Interval[180 days before end of P.relevantPeriod, 60 days before end of P.relevantPeriod]

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and exists("TKA Procedure with Encounters")

define "Denominator Exclusion: Fracture":
  /*
   * config_link_id: exclusion_1
   */
  count(["Diagnosis": "VSAC; Fracture - Lower Body"] D
    with "TKA Procedure" P
      such that D.prevalencePeriod starts 1 day or less before start of P.relevantPeriod
        and D.prevalencePeriod overlaps P.relevantPeriod) >= 2

define "Denominator Exclusion: Dementia":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "VSAC; Severe Dementia"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("TKA Procedure with Encounters" P
    with ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"] A1
      such that A1.authorDateTime 180 days or less before start of P.relevantPeriod
    with ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"] A2
      such that A2.authorDateTime during Interval[60 days after end of P.relevantPeriod, 180 days after end of P.relevantPeriod])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Fracture"
  and not "Denominator Exclusion: Dementia"
  and not "Numerator Performance Met"
