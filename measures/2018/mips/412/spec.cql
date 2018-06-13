library MIPS_412_2018 version '1'

/*
 * Source: MIPS
 * ID: 412
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 412 Encounter"
valueset "MIPS; Opiates Prescribed for Longer than Six Weeks"
valueset "MIPS; Performance Met: G9578"
valueset "MIPS; Performance Not Met: G9579"

// ABLE Value Sets

valueset "ABLE; Opioids Used for Pain Control": '1.3.6.1.4.1.6997.4.1.2.234.999.3.1'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
      where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Opioid Exists":
  exists(["Procedure Performed": "MIPS; Opiates Prescribed for Longer than Six Weeks"] P
  where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "Able; Opioids Used for Pain Control"] M
    where M.relevantPeriod overlaps "Measurement Period"
      and days between start of M.relevantPeriod and end of M.relevantPeriod > 42
        or end of M.relevantPeriod = null
      and days between start of M.relevantPeriod and end of "Measurement Period" > 42
      and days between start of "Measurement Period" and end of M.relevantPeriod > 42)

define "Denominator":
  exists("Denominator Encounter")
  and "Opioid Exists"

define "Numerator Performance Met: G9578":
  /*
   * config_link_id: G9578
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9578"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9579":
  /*
   * config_link_id: G9579
   */
  not "Numerator Performance Met: G9578"
