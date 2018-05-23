library MIPS_007Rate2_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 007Rate2
 * Year: 2018
 * Version: 1
 * Written by: Becky Weber
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 007 Encounter"
valueset "MIPS; MIPS 007 Coronary Artery Disease"
valueset "MIPS; Cardiac Surgery"
valueset "MIPS; Myocardial Infarction"
valueset "MIPS; Performance Met: G9189 or 4008F"
valueset "MIPS; Denominator Exception: G9190 or 4008F-1P"
valueset "MIPS; Denominator Exception: G9191 or 4008F-2P"
valueset "MIPS; Denominator Exception: G9192 or 4008F-3P"
valueset "MIPS; Performance Not Met: G9188 or 4008F-8P"

// VSAC value sets

valueset "VSAC; Moderate or Severe LVSD": '2.16.840.1.113883.3.526.3.1090'
valueset "VSAC; Beta Blocker Therapy": '2.16.840.1.113883.3.526.3.1174'
valueset "VSAC; Beta Blocker Therapy Ingredient": '2.16.840.1.113883.3.526.3.1493'
valueset "VSAC; Allergy to Beta Blocker Therapy": '2.16.840.1.113883.3.526.3.1177'
valueset "VSAC; Intolerance to Beta Blocker Therapy": '2.16.840.1.113883.3.526.3.1177'
valueset "VSAC; Arrhythmia": '2.16.840.1.113883.3.526.3.366'
valueset "VSAC; Hypotension": '2.16.840.1.113883.3.526.3.370'
valueset "VSAC; Asthma": '2.16.840.1.113883.3.526.3.362'
valueset "VSAC; Bradycardia": '2.16.840.1.113883.3.526.3.412'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter"
  ["Encounter, Performed": "MIPS; MIPS 007 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}

define "Denominator Encounter with Diagnosis":
  "Denominator Encounter"
    with ["Diagnosis": "MIPS; MIPS 007 Coronary Artery Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Diagnosis": "MIPS; Myocardial Infarction"] D
      such that D.prevalencePeriod starts on or 3 years or less before end of E.relevantPeriod

define "Denominator Encounter with Surgery":
  "Denominator Encounter"
    with ["Procedue, Performed": "MIPS; Cardiac Surgery"] D
      such that D.prevalencePeriod starts on or before end of E.relevantPeriod
    with ["Diagnosis": "MIPS; Myocardial Infarction"] D
      such that D.prevalencePeriod overlaps Interval[3 years before start of E.relevantPeriod, end of E.relevantPeriod]

define "Denominator Encounter Exists":
  exists("Denominator Encounter with Diagnosis")
  or exists("Denominator Encounter with Surgery")

define "Medical Exception":
  ["Allergy": "VSAC; Beta Blocker Therapy Ingredient"]
  union ["Diagnosis": "VSAC; Allergy To Beta Blocker Therapy"]
  union ["Diagnosis": "VSAC; Intolerance To Beta Blocker Therapy"]
  union ["Diagnosis": "VSAC; Arrhythmia"]
  union ["Diagnosis": "VSAC; Hypotension"]
  union ["Diagnosis": "VSAC; Asthma"]
  union ["Diagnosis": "VSAC; Bradycardia"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 007 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}

define "Denominator":
  "Denominator Encounter Exists"
  and count("Denominator Encounter") >= 2

define "Numerator Performance Met: 4008F":
  /*
   * config_link_id: 4008F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9189 or 4008F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Order": "VSAC; Beta Blocker Therapy"] M
    where M.relevantPeriod starts during "Measurement Year")
  or exists(["Medication, Active": "VSAC; Beta Blocker Therapy"] M
    where M.relevantPeriod overlaps "Measurement Year")

define "Denominator Exception: 4008F-1P":
  /*
   * config_link_id: 4008F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9190 or 4008F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists("Medical Exception" D
    where D.prevalencePeriod overlaps "Measurement Year")

define "Denominator Exception: 4008F-2P":
  /*
   * config_link_id: 4008F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9191 or 4008F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 4008F-3P":
  /*
   * config_link_id: 4008F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9192 or 4008F-3P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 4008F-8P":
  /*
   * config_link_id: 4008F-8P
   */
  not "Numerator Performance Met: 4008F"
  and not "Denominator Exception: 4008F-1P"
  and not "Denominator Exception: 4008F-2P"
  and not "Denominator Exception: 4008F-3P"
