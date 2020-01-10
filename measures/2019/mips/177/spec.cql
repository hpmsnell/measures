library MIPS_177_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 177
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 177 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; Performance Met: M1007"
valueset "MIPS; Performance Not Met: M1008"
valueset "MIPS; Performance Not Met: M1006"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 177 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: M1007":
  /*
   * config_link_id: M1007
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: M1007"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: M1008":
  /*
   * config_link_id: M1008
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: M1008"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: M1006":
  /*
   * config_link_id: M1006
   */
  not "Numerator Performance Met: M1007"
  and not "Numerator Performance Not Met: M1008"
