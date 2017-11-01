library MIPS_122Rate1 version '1'

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
valueset "MIPS; Performance Not Met: G8477"
valueset "MIPS; Performance Not Met: G8478"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

// Denominator Encounter

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 122 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
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

define "Numerator Performance Not Met: G8477":
  /*
   * config_link_id: G8477
   */
  "Hypertensive Blood Pressure Exists"

define "Numerator Performance Not Met: G8478":
  /*
   * config_link_id: G8478
   */
  not "Numerator Performance Met: G8476"
  and not "Numerator Performance Not Met: G8477"
