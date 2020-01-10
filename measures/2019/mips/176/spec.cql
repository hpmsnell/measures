library MIPS_176_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 176
 * Year: 2019
 * Version: 2
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 176 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; First-Time Anti-Rheumatic Drug Therapy"
valueset "MIPS; Performance Met: M1003"
valueset "MIPS; Denominator Exception: M1004"
valueset "MIPS; Performance Not Met: M1005"

// Able value sets

valueset "Able; DMARD Medication"

// NCQA value sets

valueset "NCQA; DMARD Medications"

// HEDIS value sets

valueset "HEDIS; DMARD"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication":
  ["Medication": "Able; DMARD Medication"]
  union ["Medication": "NCQA; DMARD Medications"]
  union ["Procedure, Performed": "HEDIS; DMARD"]

define "First Course of Anti-Rheumatic Drug Therapy":
  "Medication" M1
    where M1.relevantPeriod starts during "Measurement Period"
    without "Medication" M2
      such that M2.relevantPeriod starts before start of M1.relevantPeriod

define "Medication Exists"
  exists(["Procedure, Performed": "MIPS; First-Time Anti-Rheumatic Drug Therapy"] P
     where P.relevantPeriod starts during "Measurement Period"])
  or with "First Course of Anti-Rheumatic Drug Therapy"

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 176 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and "Medication Exists"

define "Numerator Performance Met: M1003":
  /*
   * config_link_id: M1003
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: M1003"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: M1004":
  /*
   * config_link_id: M1004
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: M1004"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: M1005":
  /*
   * config_link_id: M1005
   */
  not "Numerator Performance Met: M1003"
  and not "Denominator Exception: M1004"
