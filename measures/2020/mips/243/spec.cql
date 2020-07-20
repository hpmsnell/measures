library MIPS_243_2020 version '1'

/*
 * Source: MIPS
 * ID: 243
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 243 Encounter"
valueset "MIPS; MIPS 243 Chronic Stable Angina"
valueset "MIPS; MIPS 243 Acute Myocardial Infarction"
valueset "MIPS; MIPS 243 CABG"
valueset "MIPS; MIPS 243 Percutaneous Coronary Intervention"
valueset "MIPS; MIPS 243 Cardiac Valve Surgery"
valueset "MIPS; MIPS 243 Cardiac Transplantation"
valueset "MIPS; MIPS 243 Cardiac Event"
valueset "MIPS; Performance Met: 4500F"
valueset "MIPS; Denominator Exception: 4500F-1P"
valueset "MIPS; Denominator Exception: 4500F-2P"
valueset "MIPS; Denominator Exception: 4500F-3P"
valueset "MIPS; Denominator Exception: 4510F"
valueset "MIPS; Performance Not Met: 4500F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Diagnosis":
  ["Diagnosis": "MIPS: MIPS 243 Chronic Stable Angina"]
  union ["Diagnosis": "MIPS: MIPS 243 Acute Myocardial Infarction"]

define "Qualifying Event":
  ["Procedure, Performed": "MIPS: MIPS 243 CABG"]
  union ["Procedure, Performed": "MIPS: MIPS 243 Percutaneous Coronary Intervention"]
  union ["Procedure, Performed": "MIPS: MIPS 243 Cardiac Valve Surgery"]
  union ["Procedure, Performed": "MIPS: MIPS 243 Cardiac Transplantation"]
  union ["Procedure, Performed": "MIPS: MIPS 243 Cardiac Event"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 243 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter")
  and (
    exists "Qualifying Diagnosis" D
      with "Denominator Encounter" E
        such that D.prevalencePeriod overlaps [12 months before start of E.relevantPeriod, start of E.relevantPeriod]
    or exists "Qualifying Event" P
      with "Denominator Encounter" E
        such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod
  )

define "Numerator Performance Met: 4500F":
  /*
   * config_link_id: 4500F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4500F"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Denominator Exception: 4500F-1P":
  /*
   * config_link_id: 4500F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4500F-1P"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Denominator Exception: 4500F-2P":
  /*
   * config_link_id: 4500F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4500F-2P"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Denominator Exception: 4500F-3P":
  /*
   * config_link_id: 4500F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4500F-3P"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Denominator Exception: 4510F":
  /*
   * config_link_id: 4510F
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4510F"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Numerator Performance Not Met: 4500F-8P":
 /*
  * config_link_id: 4500F-8P
  */
 not "Numerator Performance Met: 4500F"
 and not "Denominator Exception: 4500F-1P"
 and not "Denominator Exception: 4500F-2P"
 and not "Denominator Exception: 4500F-3P"
 and not "Denominator Exception: 4510F"
