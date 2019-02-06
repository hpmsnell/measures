library MIPS_008Rate2_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 008Rate1
 * Year: 2018
 * Version: 1
 * Written by: Becky Weber
 *
  */

using QDM

// ABLE value sets

valueset "ABLE; Moderate or Severe LVSD"

// MIPS value sets

valueset "MIPS; MIPS 008 Discharge"
valueset "MIPS; Heart Failure"
valueset "MIPS; Cardiac Surgery"
valueset "MIPS; LVEF <40%"
valueset "MIPS; Performance Met: G8450"
valueset "MIPS; Denominator Exception: G8451"
valueset "MIPS; Performance Not Met: G8452"

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
    union ["Assessment, Performed": "ABLE; Moderate or Severe LVSD"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 008 Discharge"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Heart Failure"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with "LVEF <40%" P
      such that P.relevantPeriod starts on or before end of E.relevantPeriod

define "Medical Exception":
  ["Allergy": "VSAC; Beta Blocker Therapy Ingredient"]
  union ["Diagnosis": "VSAC; Allergy To Beta-Blocker Therapy"]
  union ["Diagnosis": "VSAC; Intolerance To Beta-Blocker Therapy"]
  union ["Diagnosis": "VSAC; Arrhythmia"]
  union ["Diagnosis": "VSAC; Hypotension"]
  union ["Diagnosis": "VSAC; Asthma"]
  union ["Diagnosis": "VSAC; Bradycardia"]

/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8450":
  /*
   * config_link_id: G8450
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8450"] P
    with "Denominator Encounter with Diagnosis" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists(["Medication, Order": "VSAC; Beta Blocker Therapy"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod starts during E.relevantPeriod)
  or exists(["Medication, Active": "VSAC; Beta Blocker Therapy"] M
    with "Denominator Encounter with Diagnosis" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: G8451":
  /*
   * config_link_id: G8451
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8451"] P
    with "Denominator Encounter with Diagnosis" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Medical Exception" D
    with "Denominator Encounter with Diagnosis" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: G8452":
  /*
   * config_link_id: G8452
   */
  not "Numerator Performance Met: G8450"
  and not "Denominator Exception: G8451"
