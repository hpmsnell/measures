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

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 414 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Opioid":
  ["Medication, Order": "Able; Opioids Used for Pain Control"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Opioid Procedure":
  ["Procedure Performed": "Opiates Prescribed for Longer than Six Weeks"] P
    where P. relevantPeriod starts during "Measurement Year"

define "Denominator Encounter with Opioid Procedure Exists":
  exists("Denominator Encounter")
  and exists("Opioid Procedure")

define "Denominator Encounter with Opioid Medication"
  "Denominator Encounter" E
    with "Opioid" M
      such that start of E.relevantPeriod during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 7 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 14 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 21 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 28 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 35 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 43 days during Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]

define "Denominator":
  "Denominator Encounter with Opioid Procedure Exists"
  or exists("Denominator Encounter with Opioid Medication")

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
