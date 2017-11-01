library MIPS_332_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 332
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 332 Encounter"
valueset "MIPS; Acute Sinusitis"
valueset "MIPS; Bacterial Sinusitis"
valueset "MIPS; Antibiotic Prescribed"
valueset "MIPS; Performance Met: G9315"
valueset "MIPS; Denominator Exception: G9313"
valueset "MIPS; Performance Not Met: G9314"

// VSAC value sets

valueset "VSAC; Cystic Fibrosis": '2.16.840.1.113883.3.464.1003.102.12.1002'
valueset "VSAC; Immunodeficient Conditions": '2.16.840.1.113883.3.666.5.1726'

// Able value sets

valueset "Able; Systemic Antibiotics": '2.16.840.1.113762.1.4.1133.6'
valueset "Able; Amoxicillin"
valueset "Able; Bacterial Sinusitis"
valueset "Able; Chronic Sinusitis"
valueset "Able; Cilia Disorder"
valueset "Able; Sinus Surgery"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Bacterial Sinusitis":
  ["Procedure, Performed": "MIPS; Bacterial Sinusitis"]
  union ["Diagnosis": "Able; Bacterial Sinusitis"]

define "Antibiotic":
  ["Procedure, Performed": "MIPS; Antibiotic Prescribed"]
  union ["Medication, Order": "Able; Systemic Antibiotics"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 332 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with ["Diagnosis" "MIPS; Acute Sinusitis"] D1
      such that D1.prevalencePeriod starts during E.relevantPeriod
    with "Bacterial Sinusitis" D2
      such that D2.prevalencePeriod starts during E.relevantPeriod
    with "Antibiotic" M
      where E.signingProvider.hasMeasureMembership = true
      such that M.relevantPeriod starts 10 days or less after start of E.relevantPeriod

define "Coexisting Diagnosis":
  ["Diagnosis": "VSAC; Cystic Fibrosis"]
  union ["Diagnosis": "VSAC; Immunodeficient Conditions"]

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9315":
  /*
   * config_link_id: G9315
   */
  exists(["Procedure, Performed": "Performance Met: G9315"] P
    where P.relevantPeriod starts during "Measurement Period"
  or exists(["Medication, Order": "Able; Amoxicillin"] M
    where E.signingProvider.hasMeasureMembership = true
    with "Denominator Encounter" E
      such that M.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9313":
  /*
   * config_link_id: G9313
   */
  exists(["Procedure, Performed": "Performance Met: G9313"] P
    where P.relevantPeriod starts during "Measurement Period"
  or exists("Coexisting Conditions" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  or exists(["Allergy"; "Able; Amoxicillin"] A
    with "Denominator Encounter" E
      such that A.prevalencePeriod overlaps E.relevantPeriod)
  or exists(["Diagnosis": "Able; Chronic Sinusitis"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  or exists(["Procedure, Performed": "Able; Sinus Surgery"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 12 months or less before start of E.relevantPeriod)

define "Numerator Performance Not Met: G9314":
  /*
   * config_link_id: G9314
   */
  not "Numerator Performance Met: G9315"
  and not "Denominator Exception: G9313"
