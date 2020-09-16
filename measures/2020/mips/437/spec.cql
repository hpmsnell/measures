library MIPS_437_2020 version '1'

/*
 * Source: MIPS
 * ID: 437
 * Year: 2020
 * Version: 1
 * Written By: Patrick Clark
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 437 Procedure"
valueset "MIPS; MIPS 437 Denominator Exclusion G9640"
valueset "MIPS; Performance Met: G9641"
valueset "MIPS; Performance Not Met: G9639"


// VSAC value sets

parameter "Measurement Period" Interval<DateTime>

context Patient
//Inverse Measurement



define "Denominator Encounter":
  ["Procedure, Performed": "MIPS; MIPS 437 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "Denominator" P
    with ["Procedure, Performed": "MIPS; MIPS 437 Denominator Exclusion G9640"] P1
      where P1.prevalencePeriod starts same day as start of P.relevantPeriod)

define "Numerator Performance Met: G9641":
  /*
   * config_link_id: G9641
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9641"] P
      such that P1.relevantPeriod starts during[ start of E.relevantPeriod, 2 days after end of E.relevantPeriod]

define "Numerator Performance Not Met: G9639":
  /*
   * config_link_id: G9639
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9641"
