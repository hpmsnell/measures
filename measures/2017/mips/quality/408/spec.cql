library MIPS_408_2017 version '1'

/*
 * Source: MIPS
 * ID: 408
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 408 Encounter"
valueset "MIPS; Opiates Prescribed for Longer than Six Weeks"
valueset "MIPS; Performance Met: G9562"
valueset "MIPS; Performance Not Met: G9563"

// Able Value Sets

valueset "Able; Opioids Used for Pain Control": '1.3.6.1.4.1.6997.4.1.2.234.999.3.1'

parameter "Measurement Period" Interval<DateTime>
parameter "Reduced Measurement Period" Interval[start of "Measurement Period", 90 days before end of "Measurement Period"]

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
    where E.relevantPeriod starts during "Reduced Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Opioid Procedure":
  ["Procedure Performed": "Opiates Prescribed for Longer than Six Weeks"] P
    where P. relevantPeriod starts during "Opioid Period"

define "Opioid":
  ["Medication, Order": "Able; Opioids Used for Pain Control"] M
    with "Denominator Encounter" E
      where M.relevantPeriod starts 1 year or less before start of E.relevantPeriod

define "Denominator Encounter with Opioid Procedure Exists":
  exists("Denominator Encounter")
  and exists("Opioid Procedure")

define "Denominator Encounter with Opioid Medication"
  "Denominator Encounter" E
    with "Opioid" M
      such that start of E.relevantPeriod in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 7 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 14 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 21 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 28 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 35 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]
        and start of E.relevantPeriod - 43 days in Interval[start of M.relevantPeriod, start of M.relevantPeriod + M.duration]

define "Denominator":
  "Denominator Encounter with Opioid Procedure Exists"
  or exists("Denominator Encounter with Opioid Medication")

define "Numerator Performance Met: G9562":
  /*
   * config_link_id: G9562
   * The intent is to identify patients with an assessment at least every 3 months
   * during the duration of the opioid prescription within the date bounds of 01-01 and 09-30
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9562"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9563":
  /*
   * config_link_id: G9563
   */
  not "Numerator Performance Met: G9562"
