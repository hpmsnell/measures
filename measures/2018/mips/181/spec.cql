library MIPS_181_2018 version '1'

/*
 * Source: MIPS
 * ID: 181
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 181 Encounter"
valueset "MIPS; Performance Met: G8734"
valueset "MIPS; Performance Met: G8733"
valueset "MIPS; Denominator Exception: G8735"
valueset "MIPS; Denominator Exception: G8941"
valueset "MIPS; Performance Not Met: G8535"
valueset "MIPS; Performance Not Met: G8536"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 181 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8734":
  /*
   * config_link_id: G8734
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8734"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G8733":
  /*
   * config_link_id: G8733
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8733"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G8941":
  /*
   * config_link_id: G8941
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8941"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G8535":
  /*
   * config_link_id: G8535
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8535"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8735":
  /*
   * config_link_id: G8735
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G8735"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8536":
  /*
   * config_link_id: G8536
   */
  not "Numerator Performance Met: G8734"
  and not "Numerator Performance Met: G8733"
  and not "Denominator Exception: G8941"
  and not "Denominator Exception: G8535"
  and not "Numerator Performance Not Met: G8735"
