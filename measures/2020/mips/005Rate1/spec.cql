library MIPS_005Rate1_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 005Rate1
 * Year: 2020
 * Version: 2
 * Written by: Steve Daniels
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
valueset "MIPS; Performance Met: G2092"
valueset "MIPS; Denominator Exception: G2093"
valueset "MIPS; Denominator Exception: G2094"
valueset "MIPS; Denominator Exception: G2095"
valueset "MIPS; Performance Not Met: G2092-8P"

// VSAC value sets

valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'
valueset "VSAC; ACE Inhibitor or ARB Ingredient": '2.16.840.1.113883.3.526.3.1489'
valueset "VSAC; Allergy to ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1211'
valueset "VSAC; Hypotension": '2.16.840.1.113883.3.526.3.370'

// NCQA value sets

valueset "NCQA; ACE Inhibitor/ARB Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Depressed Left Ventricular Systolic Function":
    ["Assessment, Performed": "MIPS; Depressed Left Ventricular Systolic Function"]
    union ["Diagnosis": "VSAC; Moderate or Severe LVSD"]
    union ["Assessment, Performed": "MIPS; LVEF <40%"]
    union ["Assessment, Performed": "Able; Moderate or Severe LVSD"]
    union ["Assessment, Performed": "Able; LVSD"] A
      where A.result < 40

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
      and not E.placeOfService in {'02'}

define "Denominator":
  exists("Denominator Encounter with Diagnosis")
  and count("Denominator Encounter") >= 2

define "Numerator Performance Met: G2092":
  /*
   * config_link_id: G2092
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2092"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "VSAC; Ace Inhibitor or ARB"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Medication": "HEDIS; Ace Inhibitor/ARB Medications"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: G2093":
  /*
   * config_link_id: G2093
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G2093"] P
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

define "Denominator Exception: G2094":
  /*
   * config_link_id: G2094
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G2094"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G2095":
  /*
   * config_link_id: G2095
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G2095"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G2092-8P":
  /*
   * config_link_id: G2092-8P
   */
  not "Numerator Performance Met: G2092"
  and not "Denominator Exception: G2093"
  and not "Denominator Exception: G2094"
  and not "Denominator Exception: G2095"
