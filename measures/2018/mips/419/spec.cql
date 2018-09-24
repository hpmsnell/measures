library MIPS_419_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 419
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 419 Encounter"
valueset "MIPS; Primary Headache"
valueset "MIPS; Normal Neurological Examination"
valueset "MIPS; Performance Met: G9534"
valueset "MIPS; Denominator Exception: G9536"
valueset "MIPS; Denominator Exception: G9537"
valueset "MIPS; Performance Not Met: G9538"

// VSAC value sets

valueset "VSAC; Seizure"
valueset "VSAC; Anticoagulant Medications"
valueset "VSAC; Aspirin and Other Antiplatelets"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 419 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Primary Headache"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Normal Neurological Examination"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Excluded Medication":
  ["Medication": "VSAC; Anticoagulant Medications"]
  union ["Medication": "VSAC; Aspirin and Other Antiplatelets"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9534":
  // config_link_id: G9534
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9534"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9536":
  // config_link_id: G9536
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9536"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with ["Diagnosis": "VSAC; Seizure"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Excluded Medication" M
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: G9537":
  // config_link_id: G9537
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9537"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9538":
  // config_link_id: G9538
  not "Numerator Performance Met: G9534"
  and not "Denominator Exception: G9536"
  and not "Denominator Exception: G9537"
