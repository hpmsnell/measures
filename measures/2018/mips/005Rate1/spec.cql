library MIPS_005Rate1_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 005Rate1
 * Year: 2018
 * Version: 1
 * Written by: Becky Weber
 *
  */

using QDM

// ABLE value sets

valueset "ABLE; Moderate or Severe LVSD"

// MIPS value sets

valueset "MIPS; MIPS 005 Outpatient Encounter"
valueset "MIPS; Heart Failure"
valueset "MIPS; Depressed Left Ventricular Systolic Function"
valueset "MIPS; LVEF <40%"
valueset "MIPS; Performance Met: 4010F"
valueset "MIPS; Denominator Exception: 4010F-1P"
valueset "MIPS; Denominator Exception: 4010F-2P"
valueset "MIPS; Denominator Exception: 4010F-3P"
valueset "MIPS; Performance Not Met: 4010F-8P"

// VSAC value sets

valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'
valueset "VSAC; ACE Inhibitor or ARB Ingredient": '2.16.840.1.113883.3.526.3.1489'
valueset "VSAC; Allergy to ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1211'
valueset "VSAC; Hypotension": '2.16.840.1.113883.3.526.3.370'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Depressed Left Ventricular Systolic Function":
    ["Assessment, Performed": "MIPS; Depressed Left Ventricular Systolic Function"]
    union ["Diagnosis": "VSAC; Moderate or Severe LVSD"]
    union ["Assessment, Performed": "ABLE; Moderate or Severe LVSD"]
    union ["Assessment, Performed": "MIPS; LVEF <40%"]

define "Denominator Encounter with Diagnosis":
  ["Encounter, Performed": "MIPS; MIPS 005 Outpatient Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Heart Failure"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with "Depressed Left Ventricular Systolic Function" P
      such that P.relevantPeriod starts during D.prevalencePeriod

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 005 Outpatient Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}

define "Denominator":
  exists("Denominator Encounter with Diagnosis")
  and count("Denominator Encounter") >= 2

define "Numerator Performance Met: 4010F":
  /*
   * config_link_id: 4010F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4010F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "VSAC; Ace Inhibitor or ARB"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: 4010F-1P":
  /*
   * config_link_id: 4010F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4010F-1P"] P
    with "Denominator Encounter with Diagnosis" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists(["Allergy": "VSAC; Ace Inhibitor or ARB Ingredient"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Hypotension"] D
    with "Denominator Encounter with Diagnosis" E
      such that D.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Allergy to Ace Inhibitor or ARB"] D
    with "Denominator Encounter with Diagnosis" E
      such that D.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: 4010F-2P":
  /*
   * config_link_id: 4010F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4010F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 4010F-3P":
  /*
   * config_link_id: 4010F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4010F-3P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 4010F-8P":
  /*
   * config_link_id: 4010F-8P
   */
  not "Numerator Performance Met: 4010F"
  and not "Denominator Exception: 4010F-1P"
  and not "Denominator Exception: 4010F-2P"
  and not "Denominator Exception: 4010F-3P"
