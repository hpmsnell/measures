library MIPS_177_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 177
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 177 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; Performance Met: 3470F"
valueset "MIPS; Performance Met: 3471F"
valueset "MIPS; Performance Met: 3472F"
valueset "MIPS; Performance Not Met: 3470F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 177 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3470F":
  /*
   * config_link_id: 3470F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3470F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3471F":
  /*
   * config_link_id: 3471F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3471F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3472F":
  /*
   * config_link_id: 3472F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3472F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3470F-8P":
  /*
   * config_link_id: 3470F-8P
   */
  not "Numerator Performance Met: 3470F"
  and not "Numerator Performance Met: 3471F"
  and not "Numerator Performance Met: 3472F"
