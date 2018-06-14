library MIPS_388_2018 version '1'

/*
 * Source: MIPS
 * ID: 388
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 388 Procedure"
valueset "MIPS; Performance Met: G9389"
valueset "MIPS; Performance Not Met: G9390"

// Able value sets

valueset "Able; Posterior Capsule Rupture"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 388 Procedure"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not P.code.modifier in {55, 56}
      and P.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9389":
  /*
   * config_link_id: G9389
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9389"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists(["Diagnosis": "Able; Posterior Capsule Rupture"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists(["Assessment, Performed": "Able; Posterior Capsule Rupture"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9390":
  /*
   * config_link_id: G9390
   */
  not "Numerator Performance Met: G9389"
