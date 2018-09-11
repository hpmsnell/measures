library MIPS_415_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 415
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 415 Encounter"
valueset "MIPS; Minor Blunt Head Trauma"
valueset "MIPS; GCS of 15 and CT Ordered"
valueset "MIPS; Denominator Exclusion: G9531"
valueset "MIPS; Performance Met: G9529"
valueset "MIPS; Performance Not Met: G9533"

// VSAC value sets

valueset "VSAC; Ventricular Shunt": '2.16.840.1.113883.17.4077.3.1010'
valueset "VSAC; Brain Tumor": '	2.16.840.1.113883.17.4077.3.1011'
valueset "VSAC; Pregnancy": '2.16.840.1.113883.3.600.1622'
valueset "VSAC; Trauma Other Than Head": '2.16.840.1.113883.17.4077.3.1030'
valueset "VSAC; Aspirin and Other Antiplatelets": '2.16.840.1.113883.3.464.1003.196.12.1211'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 415 Encounter"] E
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
  union ["Diagnosis": "VSAC; Pregnancy"]
  union ["Diagnosis": "VSAC; Trauma Other Than Head"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  // config_link_id: exclusion_1
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9531"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Excluded Diagnosis" D
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  or exists("Denominator Encounter" E
    with ["Medication": "VSAC; Aspirin and Other Antiplatelets"] M
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G9529":
  // config_link_id: G9529
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9529"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9533":
  // config_link_id: G9533
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9529"
