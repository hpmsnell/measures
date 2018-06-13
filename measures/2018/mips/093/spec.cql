library MIPS_093_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 093
 * Year: 2018
 * Version: 1
 * Author: Becky Weber
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 093 Encounter"
valueset "MIPS; Acute Otitis Externa (AOE)"
valueset "MIPS; Performance Met: 4132F"
valueset "MIPS; Denominator Exception: 4131F-1P"
valueset "MIPS; Performance Not Met: 4131F"

// VSAC value sets

valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Immunodeficient Conditions": '2.16.840.1.113883.3.666.5.1726'

// Able value sets

valueset "Able; Systemic Antibiotics": '2.16.840.1.113762.1.4.1133.6'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "AOE":
  ["Diagnosis": "MIPS; Acute Otitis Externa (AOE)"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 093 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 2
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with "AOE" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Coexisting Diagnosis":
  ["Diagnosis": "VSAC; Diabetes"]
  union ["Diagnosis": "VSAC; Immunodeficient Conditions"]

define "Denominator":
  "Denominator Encounter" E1
    without "Denominator Encounter" E2
      such that E1.relevantPeriod starts 30 days or less after E2.relevantPeriod

define "Numerator Performance Met: 4132F":
  /*
   * config_link_id: 4132F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4132F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)
  or not exists(["Medication, Order": "Able; Systemic Antibiotics"] M
    where E.signingProvider.hasMeasureMembership = true
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Denominator Exception: 4131F-1P":
  /*
   * config_link_id: 4131F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4131F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists("Coexisting Conditions" D
    with "Denominator Encounter" E
      such that D.relevantPeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: 4131F":
  /*
   * config_link_id: 4131F
   */
  not "Numerator Performance Met: 4132F"
  and not "Denominator Exception: 4131F-1P"
