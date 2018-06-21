library MIPS_410_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 410
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 410 Encounter"
valueset "MIPS; MIPS 410 Psoriasis"
valueset "MIPS; Medication for Psoriasis"
valueset "MIPS; Performance Met: G9649"
valueset "MIPS; Denominator Exception: G9765"
valueset "MIPS; Performance Not Met: G9651"

// Able value sets

valueset "Able; Biologic Medication for Psoriasis"
valueset "Able; Oral Systemic Medication for Psoriasis"
valueset "Able; Dermatology Life Quality Index"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 410 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; MIPS 410 Psoriasis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Psoriasis Medication":
  ["Medication": "Able; Biologic Medication for Psoriasis"]
  union ["Medication": "Able; Oral Systemic Medication for Psoriasis"]

define "Psoriasis Medication Exists":
  exists(["Procedure, Performed": "MIPS; Medication for Psoriasis"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Psoriasis Medication" M
    where M.relevantPeriod overlaps "Measurement Period")

define "Denominator":
  exists("Denominator Encounter")
  and "Psoriasis Medication Exists"

define "Numerator Performance Met: G9649":
  /*
   * config_link_id: G9649
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9649"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Dermatology Life Quality Index"] A
    where E.relevantPeriod starts during "Measurement Period"
      and E.result <= 5)

define "Denominator Exception: G9765":
  /*
   * config_link_id: G9765
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9765"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met: G9651":
  /*
   * config_link_id: G9651
   */
  not "Numerator Performance Met: G9649"
  and not "Denominator Exception: G9765"
