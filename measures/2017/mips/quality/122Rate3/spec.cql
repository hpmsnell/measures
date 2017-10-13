library MIPS_122Rate3 version '1'

/*
 * Source: MIPS
 * ID: 122
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 122 Encounter"
valueset "MIPS; Chronic Kidney Disease Stage 3, 4, or 5"
valueset "MIPS; Performance Met: G8476"
valueset "MIPS; Performance Met: 0513F"
valueset "MIPS; Performance Not Met: G8477"
valueset "MIPS; Performance Not Met: 0513F-8P"
valueset "MIPS; Performance Not Met: G8478"

// VSAC Value Sets

valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'
valueset "VSAC; Lifestyle Recommendation": '2.16.840.1.113883.3.600.1508'
valueset "VSAC; Weight Reduction Recommended": '2.16.840.1.113883.3.600.1510'
valueset "VSAC; Dietary Recommendations": '2.16.840.1.113883.3.600.1515'
valueset "VSAC; Physical Activity Recommendation": '	2.16.840.1.113883.3.600.1518'
valueset "VSAC; Moderation of ETOH Consumption": '2.16.840.1.113883.3.600.823'
valueset "VSAC; Anti-Hypertensive Pharmacologic Therapy": '2.16.840.1.113883.3.600.1476'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Denominator Encounter

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 122 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Chronic Kidney Disease Stage 3, 4, or 5"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

// Blood Pressure Screenings

define "Normal Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
        and P.result < 90

define "Normal Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
        and P.result < 140

define "Hypertensive Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
      and P.result >= 90

define "Hypertensive Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
      and P.result >= 140

define "Normal Blood Pressure Exists"
  exists("Normal Systolic Blood Pressure")
  and exists ("Normal Diastolic Blood Pressure")

define "Hypertensive Blood Pressure Exists":
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G8477"] P
    where P.relevantPeriod starts during "Measurement Period")
    or exists("Hypertensive Systolic")
    or exists("Hypertensive Diastolic")

// Follow-Ups

define "Recommended Lifestyle Modification":
  ["Procedure, Performed": "VSAC; Lifestyle Recommendation"]
  union ["Procedure, Performed": "VSAC; Weight Reduction Recommended"]
  union ["Procedure, Performed": "VSAC; Dietary Recommendations"]
  union ["Procedure, Performed": "VSAC; Physical Activity Recommendation"]
  union ["Procedure, Performed": "VSAC; Moderation of ETOH Consumption"]

define "Hypertensive Medication":
  ["Medication": "Anti-Hypertensive Pharmacologic Therapy"]

define "Lifestyle Modification Exists":
  exists("Recommended Lifestyle Modification" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Hypertensive Modification Exists":
  exists("Hypertensive Medication" M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Re-Screening Exists":
  exists("Blood Pressure Screening" P
    with "Denominator Encounter" E
      such that P.authorDateTime less than 90 days after E.relevantPeriod
        and P.authorDateTime more than 1 day after E.relevantPeriod)

define "Follow-Up Exists":
  exists(["Procedure, Performed": "MIPS; Performance Met: 0513F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Lifestyle Modification Exists"
  or "Hypertensive Re-Screening Exists"
  or "Hypertensive Medication Exists"

// Screening + Follow-Up

define "Hypertensive Blood Pressure with Follow-Up Exists":
  "Hypertensive Blood Pressure Exists"
  and "Hypertensive Follow-Up Exists"

// Statuses

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8476":
  /*
   * config_link_id: G8476
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8476"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Normal Blood Pressure Exists"

define "Numerator Performance Met: G8477 and 0513F":
  /*
   * config_link_id: G8477_0513F
   */
  "Hypertensive Blood Pressure with Follow-Up Exists"

define "Numerator Performance Not Met: G8477 and 0513F-8P":
  /*
   * config_link_id: G8477_0513F-8P
   */
  "Hypertensive Blood Pressure Exists"

define "Numerator Performance Not Met: G8478":
  /*
   * config_link_id: G8478
   */
  not "Numerator Performance Met: G8476"
  and not "Numerator Performance Met: G8477 and 0513F"
  and not "Numerator Performance Not Met: G8477 and 0513F-8P"
