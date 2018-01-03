library MIPS_414_2017 version '1'

/*
 * Source: MIPS
 * ID: 414
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 414 Encounter"
valueset "MIPS; Opiates Prescribed for Longer than Six Weeks"
valueset "MIPS; Performance Met: G9584"
valueset "MIPS; Performance Not Met: G9585"

// Able Value Sets

valueset "Able; Opioids Used for Pain Control": '1.3.6.1.4.1.6997.4.1.2.234.999.3.1'
valueset "Able; Opioid Risk Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Opioid Exists":
  exists(["Procedure Performed": "MIPS; Opiates Prescribed for Longer than Six Weeks"] P
  where P.relevantPeriod starts during "Denominator Period")
  or exists(["Medication": "Able; Opioids Used for Pain Control"] M
    where M.relevantPeriod overlaps "Denominator Period"
      and days between start of M.relevantPeriod and end of M.relevantPeriod > 42
        or end of M.relevantPeriod = null
      and days between start of M.relevantPeriod and end of "Denominator Period" > 42
      and days between start of "Denominator Period" and end of M.relevantPeriod > 42)

define "Denominator":
  exists("Denominator Encounter")
  and "Opioid Exists"

define "Numerator Performance Met: G9584":
  /*
   * config_link_id: G9584
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9584"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Opioid Risk Assessment"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9585":
  /*
   * config_link_id: G9585
   */
  not "Numerator Performance Met: G9584"
