library MIPS_044_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 044
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 044 CABG"
valueset "MIPS; MIPS 044 Anesthesia"
valueset "MIPS; Performance Met: 4115F"
valueset "MIPS; Denominator Exception: 4115F-1P"
valueset "MIPS; Performance Not Met: 4115F-8P"

// VSAC value sets

valueset "VSAC; Beta Blocker Therapy"
valueset "VSAC; Beta Blocker Therapy Ingredient"
valueset "VSAC; Allergy to Beta Blocker Therapy"
valueset "VSAC; Intolerance to Beta Blocker Therapy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 044 CABG"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'51', '80'}
    with ["Procedure, Performed": "MIPS; MIPS 044 Anesthesia"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Allergy to Beta Blocker":
  ["Diagnosis": "VSAC; Allergy to Beta Blocker Therapy"]
  union ["Diagnosis": "VSAC; Intolerance to Beta Blocker Therapy"]
  union ["Allergy": "VSAC; Beta Blocker Therapy Ingredient"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 4115F":
  // config_link_id: 4115F
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 4115F"] P
      such that P.relevantPeriod starts on or 1 day or less before start of E.relevantPeriod)
  or exists("Denominator Encounter" E
    with ["Medication": "VSAC; Beta Blocker Therapy"] M
      such that M.relevantPeriod starts on or 1 day or less before start of E.relevantPeriod)

define "Denominator Exception: 4115F-1P":
  // config_link_id: 4115F-1P
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: 4115F-1P"] P
      such that P.relevantPeriod starts on or 1 day or less before start of E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Allergy to Beta Blocker" A
      such that A.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: 4115F-8P":
  // config_link_id: 4115F-8P
  not "Numerator Performance Met: 4115F"
  and not "Denominator Exception: 4115F-1P"
