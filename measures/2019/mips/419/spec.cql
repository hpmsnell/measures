library MIPS_419_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 419
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 419 Encounter"
valueset "MIPS; Primary Headache"
valueset "MIPS; No Indications for Imaging of Head"
valueset "MIPS; Performance Met: M1027"
valueset "MIPS; Denominator Exception: M1028"
valueset "MIPS; Denominator Exception: G9537"
valueset "MIPS; Performance Not Met: M1029"

// VSAC value sets

valueset "VSAC; Seizure"
valueset "VSAC; Anticoagulant Medications"
valueset "VSAC; Aspirin and Other Antiplatelets"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 419 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifiers in ['GQ','GT','95']
      and not E.placeOfService = '02'
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Primary Headache"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; No Indications for Imaging of Head"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Excluded Medication":
  ["Medication": "VSAC; Anticoagulant Medications"]
  union ["Medication": "VSAC; Aspirin and Other Antiplatelets"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: M1027":
  // config_link_id: M1027
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: M1027"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  and not "Denominator Exception: M1028"
  and not "Denominator Exception: G9537"

define "Denominator Exception: M1028":
  // config_link_id: M1028
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: M1028"] P
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

define "Numerator Performance Not Met: M1029":
  // config_link_id: M1029
  not "Numerator Performance Met: M1027"
  and not "Denominator Exception: M1028"
  and not "Denominator Exception: G9537"
