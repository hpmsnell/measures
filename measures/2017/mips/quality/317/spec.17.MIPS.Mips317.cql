library MIPS_317 version '1'

/*
 * Source: MIPS
 * ID: 317
 * Year: 2017
 * Version: 1
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
valueset "VSAC; Referral to Alternative Provider / Primary Care Provider": '2.16.840.1.113883.3.600.1475'
valueset "VSAC; Anti-Hypertensive Pharmacologic Therapy": '2.16.840.1.113883.3.600.1476'
valueset "VSAC; Laboratory Tests for Hypertension": '2.16.840.1.113883.3.600.1482'
valueset "VSAC; ECG 12 lead or study order": '2.16.840.1.113883.3.600.2448'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 317 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.pqrsProvider = true

define "Normal Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
    and P.result < 80

define "Normal Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
    and P.result < 120

define "Pre-Hypertensive or Hypertensive Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
    and P.result >= 80

define "Pre-Hypertensive or Hypertensive Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    where P.relevantPeriod starts during E.relevantPeriod
    and P.result >= 120

define "Normal Blood Pressure Exists"
  exists("Normal Systolic Blood Pressure")
  and exists ("Normal Diastolic Blood Pressure")

define "Pre-Hypertensive or Hypertensive Blood Pressure Exists"
  exists("Pre-Hypertensive or Hypertensive Systolic Blood Pressure")
  or exists("Pre-Hypertensive or Hypertensive Diastolic Blood Pressure")

define "Two Hypertensive Blood Pressures Exist"
  count("Hypertensive Systolic Blood Pressure") >= 2
  or count("Hypertensive Diastolic Blood Pressure") >= 2

define "Hypertensive Follow-Up":
  ["Procedure, Performed": "VSAC; Lifestyle Recommendation"]
  union ["Procedure, Performed": "VSAC; Weight Reduction Recommended"]
  union ["Procedure, Performed": "VSAC; Dietary Recommendations"]
  union ["Procedure, Performed": "VSAC; Physical Activity Recommendation"]
  union ["Procedure, Performed": "VSAC; Moderation of ETOH Consumption"]
  union ["Procedure, Performed": "VSAC; Referral to Alternative Provider / Primary Care Provider"]

define "Hypertensive Laboratory Test"
  ["Laboratory Test, Performed": "VSAC; Laboratory Tests for Hypertension"]

define "Hypertensive Procedure"
  ["Procedure, Performed": "VSAC; Laboratory Tests for Hypertension"]
  ["Procedure, Performed": "VSAC; ECG 12 lead or study order"]

define "Hypertensive Medication"
  ["Medication, Order": "Anti-Hypertensive Pharmacologic Therapy"]
  ["Medication, Active": "Anti-Hypertensive Pharmacologic Therapy"]

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
 exists(["Procedure, Performed": "MIPS; Hypertension Exclusion"] P
   where P.relevantPeriod starts during "Measurement Period")
 or exists(["Diagnosis": "VSAC; Diagnosis of Hypertension"] D
   where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8783":
  /*
   * config_link_id: G8783
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8783"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Normal Blood Pressure Exists"

define "Numerator Performance Met: G8950":
  /*
   * config_link_id: G8950
   */
  (
    exists(["Procedure, Performed": "MIPS; Performance Met: G8950"] P
      where P.relevantPeriod starts during "Measurement Period")
  ) or (
    "Pre-Hypertensive or Hypertensive Blood Pressure Exists"
    and not "Two Hypertensive Blood Pressures Exist"
    and exists("Hypertensive Follow-Up" P
      where P.relevantPeriod starts during "Measurement Period")
  ) or (
    "Two Hypertensive Blood Pressures Exist"
    and exists("Hypertensive Follow-Up" P
      where P.relevantPeriod starts during "Measurement Period")
    and (
      exists("Hypertentive Laboratory Test" L
        where L.resultDateTime during "Measurement Period")
      or exists("Hypertensive Medication" M
        where M.relevantPeriod starts during "Measurement Period")
      or exists("Hypertensive Procedure" P
        where P.relevantPeriod starts during "Measurement Period")
    )
)

define "Denominator Exception: G9745":
  /*
   * config_link_id: G9745
   */
   exists(["Procedure, Performed": "MIPS; Performance Met: G9745"] P
     where P.relevantPeriod starts during "Measurement Period")

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
