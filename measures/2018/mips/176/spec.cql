library MIPS_176_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 176
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 176 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; First-Time Anti-Rheumatic Drug Therapy"
valueset "MIPS; Performance Met: 3455F"
valueset "MIPS; Denominator Exception: 3455F-1P"
valueset "MIPS; Performance Not Met: 3455F-8P"

// Able value sets

valueset "Able; Functional Status Assessment"
valueset "Able; Anti-Rheumatic Drug Therapy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "First Course of Anti-Rheumatic Drug Therapy":
  ["Medication": "Able; Anti-Rheumatic Drug Therapy"] M1
    where M1.relevantPeriod starts during "Measurement Period"
    without ["Medication": "Able; Anti-Rheumatic Drug Therapy"] M2
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

define "Numerator Performance Met: 3455F":
  /*
   * config_link_id: 3455F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3455F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 3455F-1P":
  /*
   * config_link_id: 3455F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3455F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3455F-8P":
  /*
   * config_link_id: 3455F-8P
   */
  not "Numerator Performance Met: 3455F"
  and not "Denominator Exception: 3455F-1P"
