library MIPS_384_2018 version '1'

/*
 * Source: MIPS
 * ID: 384
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 384 Encounter"
valueset "MIPS; Procedures Using Silicone Oil"
valueset "MIPS; Performance Met: G9515"
valueset "MIPS; Performance Not Met: G9514"

// VSAC Value Sets

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 384 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt >= 18
      and E.signingProvider.hasMeasureMembership = true

/* Populations */

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Procedures Using Silicone Oil"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9515":
  /*
   * config_link_id: G9515
   */
  not exists(["Procedure, Performed": "MIPS; Performance Not Met: G9514"] P
    with "Denominator Procedure" E
      where P.relevantPeriod starts 30 days or less after end of E.relevantPeriod
  and not exists(["Procedure, Performed": "MIPS; MIPS 384 Procedure"]  P
    where P.code.modifier in {'78'}
    with "Denominator Procedure" E
      where P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: G9514":
  /*
   * config_link_id: 4175F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: G9515"
