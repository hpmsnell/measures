library MIPS_374_2018 version '1'

/*
 * Source: MIPS
 * ID: 374
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 374 Encounter"
valueset "MIPS; Referral"
valueset "MIPS; Performance Met: G9969"
valueset "MIPS; Performance Not Met: G9970"

// VSAC value Sets

valueset "VSAC; Referral"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 374 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true

define "Referral":
  ["Procedure, Performed": "MIPS; Referral"]
  union ["Procedure, Performed": "VSAC; Referral"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")
  and exists("Referral" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9969":
  /*
   * config_link_id: G9969
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9969"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9970":
  /*
   * config_link_id: G9970
   */
  not "Numerator Performance Met: G9969"
