library MIPS_118Rate1_2018 version '1'

/*
 *
 * Source: MIPS
 * Measure ID: 118
 * Rate ID: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 118 Encounter"
valueset "MIPS; MIPS 118 CAD"
valueset "MIPS; LVEF <40%"
valueset "MIPS; Performance Met: G8935"
valueset "MIPS; Denominator Exception: G8936"
valueset "MIPS; Performance Not Met: G8937"
valueset "MIPS; Performance Met: G8473"
valueset "MIPS; Denominator Exception: G8474"
valueset "MIPS; Performance Not Met: G8475"

// VSAC value sets

valueset "VSAC; Moderate or Severe LVSD": '2.16.840.1.113883.3.526.3.1090'
valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'
valueset "VSAC; ACE Inhibitor or ARB Ingredient": '2.16.840.1.113883.3.526.3.1489'
valueset "VSAC; Allergy to ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1211'
valueset "VSAC; Pregnancy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "LVEF <40%":
    ["Assessment, Performed": "MIPS; LVEF <40%"]
    union ["Diagnosis": "VSAC; Moderate or Severe LVSD"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 118 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Denominator Encounter with Diagnosis":
  "Denominator Encounter" E
    with ["Diagnosis": "MIPS; MIPS 118 CAD"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with "LVEF <40%" P
      such that P.relevantPeriod starts on or before end of E.relevantPeriod

define "Performance Met":
  ["Procedure, Performed": "MIPS; Performance Met: G8935"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8473"]

define "Denominator Exception":
  ["Procedure, Performed": "MIPS; Denominator Exception: G8936"]
  union ["Procedure, Performed": "MIPS; Denominator Exception: G8474"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter with Diagnosis")
  and count("Denominator Encounter") >= 2

define "Numerator Performance Met: G8935":
  /*
   * config_link_id: G8935
   */
  exists("Performance Met" P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "VSAC; Ace Inhibitor or ARB"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Denominator Exception: G8936":
  /*
   * config_link_id: G8936
   */
  exists("Denominator Exception" P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Allergy": "VSAC; Ace Inhibitor or ARB Ingredient"] M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "VSAC; Allergy to Ace Inhibitor or ARB"] D
    where D.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: G8937":
  /*
   * config_link_id: G8937
   */
  not "Numerator Performance Met: G8935"
  and not "Denominator Exception: G8936"
