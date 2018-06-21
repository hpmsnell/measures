library MIPS_317_2018 version '1'

/*
 * Source: MIPS
 * ID: 317
 * Year: 2018
 * Version: 2
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 317 Encounter"
valueset "MIPS; Hypertension Exclusion"
valueset "MIPS; Performance Met: G8783"
valueset "MIPS; Performance Met: G8950"
valueset "MIPS; Denominator Exception: G9745"
valueset "MIPS; Performance Not Met: G8785"
valueset "MIPS; Performance Not Met: G8952"

// VSAC Value Sets

valueset "VSAC; Diagnosis of Hypertension": '2.16.840.1.113883.3.600.263'
valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'
valueset "VSAC; Lifestyle Recommendation": '2.16.840.1.113883.3.600.1508'
valueset "VSAC; Weight Reduction Recommended": '2.16.840.1.113883.3.600.1510'
valueset "VSAC; Dietary Recommendations": '2.16.840.1.113883.3.600.1515'
valueset "VSAC; Physical Activity Recommendation": '	2.16.840.1.113883.3.600.1518'
valueset "VSAC; Moderation of ETOH Consumption": '2.16.840.1.113883.3.600.823'
valueset "VSAC; Anti-Hypertensive Pharmacologic Therapy": '2.16.840.1.113883.3.600.1476'
valueset "VSAC; Laboratory Tests for Hypertension": '2.16.840.1.113883.3.600.1482'
valueset "VSAC; ECG 12 lead or study order": '2.16.840.1.113883.3.600.2448'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Denominator Encounter

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 317 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

// Blood Pressure Screenings

define "Blood Pressure Screening":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"]
  union ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"]

define "Normal Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result < 80

define "Normal Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result < 120

define "Pre-Hypertensive Diastolic":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result >= 80
        and P.result < 90

define "Pre-Hypertensive Systolic":
  ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result >= 120
        and P.result < 140

define "Hypertensive Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result >= 90

define "Hypertensive Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result >= 140

define "Normal Blood Pressure Exists"
  exists("Normal Systolic Blood Pressure" S
    with "Normal Diastolic Blood Pressure" D
      such that S.authorDateTime equals D.authorDateTime)

define "Encounter with Results":
  "Denominator Encounter" E
    with ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] S
      such that S.authorDateTime during E.relevantPeriod
    with ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] D
      such that D.authorDateTime during E.relevantPeriod

define "Ordered Encounter with Results":
  "Encounter with Results" E
    sort by start of E.relevantPeriod ASC

define "Pre-Hypertensive Blood Pressure Exists":
  exists("Pre-Hypertensive Systolic")
  or exists("Pre-Hypertensive Diastolic")

define "Hypertensive Blood Pressure Exists":
  exists("Hypertensive Systolic")
  or exists("Hypertensive Diastolic")

define "Pre-Hypertensive or Hypertensive Blood Pressure Exists"
  "Pre-Hypertensive Blood Pressure Exists"
  or "Hypertensive Blood Pressure Exists"

define "Two Hypertensive Blood Pressures Exist"
  count("Hypertensive Systolic Blood Pressure") >= 2
  or count("Hypertensive Diastolic Blood Pressure") >= 2

// Follow-Ups

define "Recommended Lifestyle Modification":
  ["Procedure, Performed": "VSAC; Lifestyle Recommendation"]
  union ["Procedure, Performed": "VSAC; Weight Reduction Recommended"]
  union ["Procedure, Performed": "VSAC; Dietary Recommendations"]
  union ["Procedure, Performed": "VSAC; Physical Activity Recommendation"]
  union ["Procedure, Performed": "VSAC; Moderation of ETOH Consumption"]

define "Hypertensive Lab Test":
  ["Laboratory Test, Performed": "VSAC; Laboratory Tests for Hypertension"]

define "Hypertensive Procedure":
  ["Procedure, Performed": "VSAC; Laboratory Tests for Hypertension"]
  ["Procedure, Performed": "VSAC; ECG 12 lead or study order"]

define "Hypertensive Medication":
  ["Medication": "Anti-Hypertensive Pharmacologic Therapy"]

define "Pre-Hypertensive Lifestyle Modification Exists":
  exists("Recommended Lifestyle Modification" P
    with "Pre-Hypertensive Systolic" E
      such that P.relevantPeriod starts on or 1 day or less after E.authorDateTime)
  or exists("Recommended Lifestyle Modification" P
    with "Pre-Hypertensive Diastolic" E
      such that P.relevantPeriod starts on or 1 day or less after E.authorDateTime)

define "Pre-Hypertensive Re-Screening Exists":
  exists("Blood Pressure Screening" P1
    with "Pre-Hypertensive Systolic" E
      such that P1.authorDateTime 1 year or less after P2.authorDateTime
        and P1.authorDateTime more than 1 day after P2.authorDateTime)
  or exists("Blood Pressure Screening" P1
    with "Pre-Hypertensive Diastolic" P2
      such that P1.authorDateTime 1 year or less after P2.authorDateTime
        and P1.authorDateTime more than 1 day after P2.authorDateTime)

define "Hypertensive Lifestyle Modification Exists":
exists("Recommended Lifestyle Modification" P
  with "Hypertensive Systolic" E
    such that P.relevantPeriod starts on or 1 day or less after E.authorDateTime)
or exists("Recommended Lifestyle Modification" P
  with "Hypertensive Diastolic" E
    such that P.relevantPeriod starts on or 1 day or less after E.authorDateTime)

define "Hypertensive Re-Screening Exists":
  exists("Blood Pressure Screening" P1
    with "Hypertensive Systolic" P2
      such that P1.authorDateTime less than 4 weeks after P2.authorDateTime
        and P1.authorDateTime more than 1 day after P2.authorDateTime)
  or exists("Blood Pressure Screening" P1
    with "Hypertensive Diastolic" P2
      such that P1.authorDateTime less than 4 weeks after P2.authorDateTime
        and P1.authorDateTime more than 1 day after P2.authorDateTime)

define "Second Hypertensive Intervention Exists":
  or exists("Hypertensive Medication" M
    where M.relevantPeriod overlaps "Measurement Year")
  or exists("Hypertensive Lab Test" L
    where L.resultDateTime during "Measurement Year")
  or exists("Hypertensive Procedure" P
    where P.relevantPeriod during "Measurement Year")

define "Pre-Hypertensive Follow-Up Exists":
  "Pre-Hypertensive Lifestyle Modification Exists"
  and "Pre-Hypertensive Re-Screening Exists"

define "Hypertensive Follow-Up Exists":
  "Hypertensive Lifestyle Modification Exists"
  and "Hypertensive Re-Screening Exists"

define "Two Hypertensive Follow-Up Exists":
  "Hypertensive Lifestyle Modification Exists"
  and "Second Hypertensive Intervention Exists"

// Screening + Follow-Up

define "Pre-Hypertensive Blood Pressure with Follow-Up Exists":
  exists("Pre-Hypertensive Blood Pressure")
  and "Pre-Hypertensive Follow-Up Exists"

define "Hypertensive Blood Pressure with Follow-Up Exists":
  "Hypertensive Blood Pressure Exists"
  and "Hypertensive Follow-Up Exists"

define "Two Hypertensive Blood Pressures with Follow-Up Exist":
  "Two Hypertensive Blood Pressures Exist"
  and "Two Hypertensive Follow-Up Exists"

// Statuses

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
 exists(["Procedure, Performed": "MIPS; Hypertension Exclusion"] P
  where P.relevantPeriod starts during "Measurement Period")
 or exists(["Diagnosis": "VSAC; Diagnosis of Hypertension"] D
  with "Denominator Encounter" E
   such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G8783":
  /*
   * config_link_id: G8783
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8783"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Normal Blood Pressure Exists"

define "Numerator Performance Met: G8950_1":
  /*
   * config_link_id: G8950_1
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8950"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G8950_2":
  /*
   * config_link_id: G8950_2
   */
  "Two Hypertensive Blood Pressures with Follow-Up Exist"

define "Numerator Performance Met: G8950_3":
  /*
   * config_link_id: G8950_3
   */
  "Hypertensive Blood Pressure with Follow-Up Exists"

define "Numerator Performance Met: G8950_4":
  /*
   * config_link_id: G8950_4
   */
  "Pre-Hypertensive Blood Pressure with Follow-Up Exists"

define "Denominator Exception: G9745":
  /*
   * config_link_id: G9745
   */
   exists(["Procedure, Performed": "MIPS; Performance Not Met: G8952"] P
     with Last("Ordered Encounter with Results") E
        such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8952":
  /*
   * config_link_id: G8952
   */
   exists(["Procedure, Performed": "MIPS; Performance Not Met: G8952"] P
     where P.relevantPeriod starts during "Measurement Period")
   or "Pre-Hypertensive or Hypertensive Blood Pressure Exists"

define "Numerator Performance Not Met: G8785":
  /*
   * config_link_id: G8785
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8783"
  and not "Numerator Performance Met: G8950"
  and not "Denominator Exception: G9745"
  and not "Numerator Performance Not Met: G8952"
