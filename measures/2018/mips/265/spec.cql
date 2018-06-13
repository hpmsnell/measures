library MIPS_265_2018 version '1'

/*
 * Source: MIPS
 * ID: 265
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 265 Encounter"
valueset "MIPS; Biopsy"
valueset "MIPS; Performance Met: G8883"
valueset "MIPS; Denominator Exception: G8884"
valueset "MIPS; Performance Not Met: G8885"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 265 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Biopsy":
  ["Procedure, Performed": "MIPS; Biopsy"] E
    where E.relevantPeriod starts during "Measurement Period"

define "Denominator":
  exists("Denominator Encounter")
  and exists("Biopsy")

define "Numerator Performance Met: G8883":
  /*
   * config_link_id: G8883
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8883"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G8884":
  /*
   * config_link_id: G8884
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8884"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8885":
  /*
   * config_link_id: G8885
   */
  not "Numerator Performance Met: G8883"
  and not "Denominator Exception: G8884"
