library MIPS_398Rate1_2020 version '1'

/*
 * Source: MIPS
 * ID: 398
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 398 Encounter"

valueset "HEDIS; Asthma"
valueset "MIPS; Competing Conditions for Persistent Asthma"
valueset "MIPS; No Asthma Controller Medication Dispensed"
valueset "MIPS; Hospice Service"
valueset "MIPS; Performance Met: G9810"
valueset "MIPS; Performance Not Met: G9811"

// NCQA value Sets

valueset "NCQA; Asthma Controller Medications"

// VSAC value sets

valueset "VSAC; Preferred Asthma Therapy": '2.16.840.1.113883.3.464.1003.196.12.1212'

// Able value sets

valueset "Able; Expired"

parameter "Measurement Period" Interval<DateTime>

context Patient



define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 398 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 5
      and AgeInYearsAt(start of E.relevantPeriod) < 17
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Diagnosis Asthma"
 ["Diagnosis": "HEDIS; Asthma"] D
    where D.prevalencePeriod during [12 months before start of "Measurement Period", end of "Measurement Period"]
 or ["Diagnosis": "HEDIS; Asthma"] D2
    where D2.prevalencePeriod during [12 months before start of "Measurement Period", end of "Measurement Period"]

define "Denominator"
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Diabetes"] D
      where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Denominator Exclusion: Long Term Care"
      FrailtyLTIShared."Long Term Care Periods During Measurement Period"

define "Denominator Exclusion: Patient Died"
exists(["Diagnosis": "MIPS; Expired"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Competing Diagnoses"
  /*
  * config_link_id: exclusion_1
  */
  exists(["Diagnosis": "MIPS; Competing Conditions for Persistent Asthma"] D
    where D.prevalencePeriod starts before end of "Denominator Period")


define "Asthma Medication":
  ["Medication": "NCQA; Asthma Controller Medications"]
  union ["Medication": "VSAC; Preferred Asthma Therapy"]
  union ["Medication": "Able; Preferred Asthma Therapy Branded"]

define "No Medication Exists":
  not exists("Asthma Medication" M
    where M.relevantPeriod overlaps "Denominator Period")

define "Asthma Medication in Measurement Period":
  "Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period"

define "Prescription Start Date":
  "Asthma Medication in Measurement Period" M
    return start of M.relevantPeriod

define "Prescription Stop Date":
  "Asthma Medication in Measurement Period" M
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

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion: Competing Diagnoses"
  /*
  * config_link_id: exclusion_1
  */
  exists(["Diagnosis": "MIPS; Competing Conditions for Persistent Asthma"] D
    where D.prevalencePeriod starts before end of "Denominator Period")

define "Denominator Exclusion: Hospice Service":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: G9810":
  /*
   * config_link_id: G9810
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9810"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Sum of Prescription Durations" / "Treatment Period" >= 0.75

define "Numerator Performance Not Met: G9811":
  /*
   * config_link_id: G9811
   */
  not "Denominator Exclusion: Competing Diagnoses"
  and not "Denominator Exclusion: No Medication Dispensed"
  and not "Denominator Exclusion: Hospice Service"
  and not "Numerator Performance Met: G9810"
