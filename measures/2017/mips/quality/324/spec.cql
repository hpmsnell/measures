library MIPS_324_2017 version '1'

/*
 * Source: MIPS
 * ID: 324
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 324 Procedure"
valueset "MIPS; Performance Met: G8965"
valueset "MIPS; Performance Not Met: G8966"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 324 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8965":
  /*
   * config_link_id: G8965
   */
  not exists(["Procedure, Performed": "MIPS; Performance Not Met: G8966"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8966":
  /*
   * config_link_id: G8966
   */
  not "Numerator Performance Met: G8965"
