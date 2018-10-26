library MIPS_118Rate2_2018 version '1'

/*
 *
 * Source: MIPS
 * Measure ID: 118
 * Rate ID: 2
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 118 Encounter"
valueset "MIPS; MIPS 118 CAD"
valueset "MIPS; MIPS 118 Diabetes"
valueset "MIPS; Performance Met: G8935"
valueset "MIPS; Denominator Exception: G8936"
valueset "MIPS; Performance Not Met: G8937"
valueset "MIPS; Performance Met: G8473"
valueset "MIPS; Denominator Exception: G8474"
valueset "MIPS; Performance Not Met: G8475"

// VSAC value sets

valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'
valueset "VSAC; ACE Inhibitor or ARB Ingredient": '2.16.840.1.113883.3.526.3.1489'
valueset "VSAC; Allergy to ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1211'
valueset "VSAC; Pregnancy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 118 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Denominator Encounter with Diagnosis":
  "Denominator Encounter" E
    with ["Diagnosis": "MIPS; MIPS 118 CAD"] D1
      such that D1.prevalencePeriod overlaps E.relevantPeriod
    with ["Diagnosis": "MIPS; MIPS 118 CAD"] D2
      such that D2.prevalencePeriod overlaps E.relevantPeriod

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

define "Numerator Performance Met: G8473":
  /*
   * config_link_id: G8473
   */
  exists("Performance Met" P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "VSAC; Ace Inhibitor or ARB"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: G8474":
  /*
   * config_link_id: G8474
   */
  exists("Denominator Exception" P
    with "Denominator Encounter with Diagnosis" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists(["Allergy": "VSAC; Ace Inhibitor or ARB Ingredient"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    with "Denominator Encounter with Diagnosis" E
      such that D.relevantPeriod overlaps E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Allergy to Ace Inhibitor or ARB"] D
    with "Denominator Encounter with Diagnosis" E
      such that D.relevantPeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: G8475":
  /*
   * config_link_id: G8475
   */
  not "Numerator Performance Met: G8473"
  and not "Denominator Exception: G8474"
