library MIPS_322_2017 version '1'

/*
 * Source: MIPS
 * ID: 322
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 322 Procedure"
valueset "MIPS; Performance Met: G8961"
valueset "MIPS; Performance Not Met: G8962"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 322 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8961":
  /*
   * config_link_id: G8961
   */
  not exists(["Procedure, Performed": "MIPS; Performance Not Met: G8962"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8962":
  /*
   * config_link_id: G8962
   */
  not "Numerator Performance Met: G8961"
