library MIPS_416_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 416
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 416 Encounter"
valueset "MIPS; Minor Blunt Head Trauma"
valueset "MIPS; GCS of 15 and CT Ordered"
valueset "MIPS; Denominator Exclusion: G9595"
valueset "MIPS; Performance Met: G9593"
valueset "MIPS; Performance Not Met: G9597"

// VSAC value sets

valueset "VSAC; Ventricular Shunt": '2.16.840.1.113883.17.4077.3.1010'
valueset "VSAC; Brain Tumor": '	2.16.840.1.113883.17.4077.3.1011'
valueset "VSAC; Coagulopathies": '2.16.840.1.113883.17.4077.3.1002'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 416 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Minor Blunt Head Trauma"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; GCS of 15 and CT Ordered"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Excluded Diagnosis":
  ["Diagnosis": "VSAC; Ventricular Shunt"]
  union ["Diagnosis": "VSAC; Brain Tumor"]
  union ["Diagnosis": "VSAC; Coagulopathies"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  // config_link_id: exclusion_1
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9595"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Excluded Diagnosis" D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G9593":
  // config_link_id: G9593
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9593"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9597":
  // config_link_id: G9597
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9593"
