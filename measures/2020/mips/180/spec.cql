library MIPS_180_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 180
 * Year: 2020
 * Version: 1
 * Written by: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 180 Encounter"
valueset "MIPS; Rheumatoid Arthritis"
valueset "MIPS; Performance Met: 4192F"
valueset "MIPS; Performance Met: G2112"
valueset "MIPS; Performance Met: G2113"
valueset "MIPS; Performance Met: 0540F"
valueset "MIPS; Denominator Exception: 0540F-1P"
valueset "MIPS; Performance Not Met: 4194F-8P"
valueset "MIPS; Performance Not Met: 0540F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 180 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Rheumatoid Arthritis"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 4192F":
  /*
   * config_link_id: 4192F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4192F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G2112":
  /*
   * config_link_id: G2112
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2112"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G2113/0540F":
  /*
   * config_link_id: G2113_0540F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2113"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists(["Procedure, Performed": "MIPS; Performance Met: 0540F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G2113/0540F-1P":
  /*
   * config_link_id: G2113_0540F-1P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2113"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists(["Procedure, Performed": "MIPS; Denominator Exception: 0540F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Performance Not Met: G2113/0540F-8P":
  /*
   * config_link_id: G2113_0540F-8P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2113"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists(["Procedure, Performed": "MIPS; Performance Not Met: 0540F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 4194F-8P":
  /*
   * config_link_id: 4194F-8P
   */
  not "Numerator Performance Met: 4192F"
  and not "Numerator Performance Met: G2112"
  and not "Numerator Performance Met: G2113/0540F"
  and not "Denominator Exception: G2113/0540F-1P"
  and not "Performance Not Met: G2113/0540F-8P"
