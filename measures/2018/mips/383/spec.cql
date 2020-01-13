library MIPS_383_2017 version '1'

/*
 * Source: MIPS
 * ID: 383
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 383 Encounter Outpatient Option 1"
valueset "MIPS; MIPS 383 Encounter Outpatient Option 2"
valueset "MIPS; MIPS 383 Encounter ED Option 1"
valueset "MIPS; MIPS 383 Encounter ED Option 2"
valueset "MIPS; MIPS 383 Encounter Non-Acute Inpatient Option 1"
valueset "MIPS; MIPS 383 Encounter Non-Acute Inpatient Option 2"
valueset "MIPS; MIPS 383 Encounter Acute Inpatient"
valueset "MIPS; Schizophrenia"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: G9512"
valueset "MIPS; Performance Not Met: G9811"

// NCQA value Sets

valueset "NCQA; Oral Antipsychotic Medications"
valueset "NCQA; Long-Acting Injections 14 Days Supply Medications"
valueset "NCQA; Long-Acting Injections 28 Days Supply Medications"
valueset "NCQA; Long-Acting Injections 14 Days Supply"
valueset "NCQA; Long-Acting Injections 28 Days Supply"

// VSAC value sets

valueset "VSAC; Antipsychotic Medications"

// Able value sets

valueset "Able; Antipsychotic Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounters for 2 Encounters":
  ["Encounter, Performed": "MIPS; MIPS 383 Encounter Outpatient Option 1"]
  union ["Encounter, Performed": "MIPS; MIPS 383 Encounter Outpatient Option 2"] E
    where E.placeOfService in ['03', '05', '07', '09', '11', '12', '13', '14', '15', '20', '22', '24', '33', '49', '50', '52', '53', '71', '72']
  union ["Encounter, Performed": "MIPS; MIPS 383 Encounter ED Option 1"]
  union ["Encounter, Performed": "MIPS; MIPS 383 Encounter ED Option 2"] E
    where E.placeOfService in ['23']
  union ["Encounter, Performed": "MIPS; MIPS 383 Encounter Non-Acute Inpatient Option 1"]
  union ["Encounter, Performed": "MIPS; MIPS 383 Encounter Non-Acute Inpatient Option 2"] E
    where E.placeOfService in ['31', '32', '56']

define "Denominator Encounters Exist":
  exists("Encounters for 2 Encounters" E1
    where E1.relevantPeriod starts during "Measurement Period"
      and E1.signingProvider.hasMeasureMembership = true
    with "Encounters for 2 Encounters" E2
      such that start of E1.relevantPeriod != start of E2.relevantPeriod
    with ["Diagnosis": "MIPS; Schizophrenia"] D
      such that D.prevalencePeriod overlaps E1.relevantPeriod
        and D.prevalencePeriod overlaps E2.relevantPeriod)
  or exists(["Encounter, Performed": "MIPS; MIPS 383 Encounter Acute Inpatient"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and E.placeOfService in ['21', '51']
    with ["Diagnosis": "MIPS; Schizophrenia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Antipsychotic Medication":
  ["Medication": "NCQA; Oral Antipsychotic Medications"]
  union ["Medication": "NCQA; Long-Acting Injections 14 Days Supply Medications"]
  union ["Medication": "NCQA; Long-Acting Injections 28 Days Supply Medications"]
  union ["Procedure, Performed": "NCQA; Long-Acting Injections 14 Days Supply"]
  union ["Procedure, Performed": "NCQA; Long-Acting Injections 28 Days Supply"]
  union ["Medication": "VSAC; Antipsychotic Medications"]
  union ["Medication": "Able; Antipsychotic Medications"]

define "Antipsychotic Medication in Measurement Period":
  "Antipsychotic Medication" M
    where M.relevantPeriod starts during "Measurement Period"

define "Prescription Start Date":
  "Antipsychotic Medication in Measurement Period" M
    return start of M.relevantPeriod

define "Prescription Stop Date":
  "Antipsychotic Medication in Measurement Period" M
    return end of M.relevantPeriod

define "Prescription Duration":
  Min(
    {
      days between "Prescription Start Date" and "Prescription Stop Date",
      days between "Prescription Start Date" and end of "Measurement Period" // Default to this if Stop Date is null
    }
  )

define "Sum of Prescription Durations":
  Sum("Prescription Duration")

define "First Prescription Start Date":
  First("Prescription Start Date")

define "Treatment Period":
  days between "First Prescription Start Date" and end of "Measurement Period"

// Populations

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and "Denominator Encounters Exist"
  and "Medication Exists"

define "Denominator Exclusion: Dementia"
  /*
  * config_link_id: exclusion_1
  */
  exists(["Diagnosis": "MIPS; MIPS 383 Dementia"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9512":
  /*
   * config_link_id: G9512
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9512"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Sum of Prescription Durations" / "Treatment Period" >= 0.8

define "Numerator Performance Not Met: G9811":
  /*
   * config_link_id: G9811
   */
  not "Denominator Exclusion: Dementia"
  and not "Numerator Performance Met: G9512"
