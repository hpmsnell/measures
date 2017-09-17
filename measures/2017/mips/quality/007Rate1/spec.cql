library MIPS_007Rate1_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 007Rate1
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 007 Encounter"
valueset "MIPS; MIPS 007 Coronary Artery Disease"
valueset "MIPS; Cardiac Surgery"
valueset "MIPS; LVEF <40%"
valueset "MIPS; Performance Met: G9189 or 4008F"
valueset "MIPS; Denominator Exception: G9190 or 4008F-1P"
valueset "MIPS; Denominator Exception: G9191 or 4008F-2P"
valueset "MIPS; Denominator Exception: G9192 or 4008F-3P"
valueset "MIPS; Performance Not Met: G9188 or 4008F-8P"

// VSAC value sets

valueset "VSAC; Moderate or Severe LVSD": '2.16.840.1.113883.3.526.3.1090'
valueset "VSAC; Beta Blocker Therapy": '2.16.840.1.113883.3.526.3.1174'
valueset "VSAC; Beta Blocker Therapy Ingredient": '2.16.840.1.113883.3.526.3.1493'
valueset "VSAC; Allergy to Beta-Blocker Therapy": '2.16.840.1.113883.3.526.3.1177'
valueset "VSAC; Intolerance to Beta-Blocker Therapy": '2.16.840.1.113883.3.526.3.1177'
valueset "VSAC; Arrhythmia": '2.16.840.1.113883.3.526.3.366'
valueset "VSAC; Hypotension": '2.16.840.1.113883.3.526.3.370'
valueset "VSAC; Asthma": '2.16.840.1.113883.3.526.3.362'
valueset "VSAC; Bradycardia": '2.16.840.1.113883.3.526.3.412'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "LVEF <40%":
    ["Assessment, Performed": "MIPS; LVEF <40%"]
    union ["Diagnosis": "VSAC; Moderate or Severe LVSD"]

define "Denominator Encounter with Diagnosis":
  ["Encounter, Performed": "MIPS; MIPS 007 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; MIPS 007 Coronary Artery Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with "LVEF <40%" P
      such that P.relevantPeriod starts on or before end of E.relevantPeriod

define "Denominator Encounter with Surgery":
  ["Encounter, Performed": "MIPS; MIPS 007 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Procedue, Performed": "MIPS; Cardiac Surgery"] D
      such that D.prevalencePeriod starts on or before end of E.relevantPeriod
    with "LVEF <40%" P
      such that P.relevantPeriod starts on or before end of E.relevantPeriod

define "Denominator Encounter Exists":
  exists("Denominator Encounter with Diagnosis")
  or exists("Denominator Encounter with Surgery")

define "Medical Exception":
  ["Allergy": "VSAC; Beta Blocker Therapy"]
  union ["Allergy": "VSAC; Beta Blocker Therapy Ingredient"]
  union ["Diagnosis": "VSAC; Allergy To Beta-Blocker Therapy"]
  union ["Diagnosis": "VSAC; Intolerance To Beta-Blocker Therapy"]
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

define "Numerator Performance Met: G9189":
  /*
   * config_link_id: G9189
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9189 or 4008F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Order": "VSAC; Beta Blocker Therapy"] M
    where M.relevantPeriod starts during "Measurement Year")
  or exists(["Medication, Active": "VSAC; Beta Blocker Therapy"] M
    where M.relevantPeriod overlaps "Measurement Year")

define "Denominator Exception: G9190":
  /*
   * config_link_id: G9190
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9190 or 4008F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Medical Exception" D
    where D.prevalencePeriod overlaps "Measurement Year")

define "Denominator Exception: G9191":
  /*
   * config_link_id: G9191
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9191 or 4008F-2P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G9192":
  /*
   * config_link_id: G9192
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9192 or 4008F-3P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9188":
  /*
   * config_link_id: G9188
   */
  not "Numerator Performance Met: G9189"
  and not "Denominator Exception: G9190"
  and not "Denominator Exception: G9191"
  and not "Denominator Exception: G9192"
