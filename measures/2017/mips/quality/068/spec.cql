library MIPS_068_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 068
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 068 Encounter"
valueset "MIPS; Myelodysplastic Syndrome (MDS)"
valueset "MIPS; Erythropoietin Therapy"
valueset "MIPS; Performance Met: 3160F"
valueset "MIPS; Denominator Exception: 3160F-3P"
valueset "MIPS; Performance Not Met: 3160F-8P"

// Able value sets

valueset "Able; Erythropoietin Therapy"
valueset "Able; Documentation of Iron Stores"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 068 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Myelodysplastic Syndrome (MDS)"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Erythropoietin Therapy Exists":
  exists(["Procedure, Performed": "MIPS; Erythropoietin Therapy"] P
    where P.relevantPeriod starts during "Denominator Period"])
  or exists(["Medication": "Able; Erythropoietin Therapy"] M
    where M.relevantPeriod starts during "Denominator Period"])

define "First Erythropoietin Therapy":
  First(["Medication": "Able; Erythropoietin Therapy"] M
    where M.relevantPeriod starts during "Measurement Period")

define "Denominator":
  exists("Denominator Encounter")
  and "Erythropoietin Therapy Exists"

define "Numerator Performance Met: 3160F":
  /*
   * config_link_id: 3160F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3160F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Documentation of Iron Stores"] P
    with "First Erythropoietin Therapy" M
      such that P.relevantPeriod starts at or 60 days or less before start of M.relevantPeriod)

define "Denominator Exception: 3160F-3P":
  /*
   * config_link_id: 3160F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3160F-3P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3160F-8P":
  /*
   * config_link_id: 3160F-8P
   */
  not "Numerator Performance Met: 3160F"
  and not "Denominator Exception: 3160F-3P"
