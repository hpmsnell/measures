library MIPS_279_2017 version '1'

/*
 * Source: MIPS
 * ID: 279
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 279 Encounter"
valueset "MIPS; Sleep Apnea"
valueset "MIPS; Positive Airway Pressure Therapy Prescribed"
valueset "MIPS; Performance Met: G8851"
valueset "MIPS; Denominator Exception: G8854"
valueset "MIPS; Performance Not Met: G8855"

// Able value sets

valueset "Able; Positive Airway Pressure Therapy"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Positive Airway Pressure Therapy":
  ["Procedure, Performed": "MIPS; Positive Airway Pressure Therapy Prescribed"]
  union ["Procedure, Performed": "Able; Positive Airway Pressure Therapy"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 279 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.code.modifier not in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Sleep Apnea"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and exists("Positive Airway Pressure Therapy"
    where P.relevantPeriod starts during D.prevalencePeriod)

define "Numerator Performance Met: G8851":
  /*
   * config_link_id: G8851
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8851"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G8854":
  /*
   * config_link_id: G8854
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8854"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8855":
  /*
   * config_link_id: G8855
   */
  not "Numerator Performance Met: G8851"
  and not "Denominator Exception: G8854"
