library MIPS_407_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 407
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 407 Encounter"
valueset "MIPS; Sepsis due to MSSA"
valueset "MIPS; Performance Met: G9558"
valueset "MIPS; Denominator Exception: G9559"
valueset "MIPS; Performance Not Met: G9560"

// Able value sets

valueset "Able; Beta-Lactam Antibiotic"
valueset "Able; Beta-Lactam Antibiotic Ingredient"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 407 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and AgeInYearsAt(start of E.relevantPeriod >= 18)
    with ["Diagnosis": "MIPS; Sepsis due to MSSA"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter" E1
    without "Denominator Encounter" E2
      such that E2.relevantPeriod starts 1 day before start of E1.relevantPeriod

define "Numerator Performance Met: G9558":
  // config_link_id: G9558
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9558"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with ["Medication": "Able; Beta-Lactam Antibiotic"] M
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: G9559":
  // config_link_id: G9559
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9559"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with ["Allergy": "Able; Beta-Lactam Antibiotic Ingredient"] A
      such that A.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: G9560":
  // config_link_id: G9560
  not "Numerator Performance Met: G9558"
  and not "Denominator Exception: G9559"
