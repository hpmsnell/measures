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
valueset "Able; Opioid Evaluation"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>
parameter "Opioid Period" Interval[start of "Measurement Period", 91 days before end of "Measurement Period"]

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Opioid Exists":
  exists(["Procedure Performed": "MIPS; Opiates Prescribed for Longer than Six Weeks"] P
    where P.relevantPeriod starts during "Opioid Period"
      and P.relevantPeriod starts during "Denominator Period")
  or exists(["Medication": "Able; Opioids Used for Pain Control"] M
    where M.relevantPeriod overlaps "Opioid Period"
      and M.relevantPeriod overlaps "Denominator Period"
      and days between start of M.relevantPeriod and end of M.relevantPeriod > 42
        or end of M.relevantPeriod = null
      and days between start of M.relevantPeriod and end of "Opioid Period" > 42
      and days between start of M.relevantPeriod and end of "Denominator Period" > 42
      and days between start of "Denominator Period" and end of M.relevantPeriod > 42)

define "Follow-Up":
  "Able; Opioid Evaluation" P
      where P.relevantPeriod starts during "Measurement Period"

define "Follow-Up Every 3 Months Exists"
  exists("Follow-Up" P
    with ["Medication": "Able; Opioids Used for Pain Control"] M
      such that P.relevantPeriod starts during Interval[1 day after start of M.relevantPeriod, 90 days after start of M.relevantPeriod])
  and exists("Follow-Up" P
    with ["Medication": "Able; Opioids Used for Pain Control"] M
      such that P.relevantPeriod starts during Interval[91 days after start of M.relevantPeriod, 180 days after start of M.relevantPeriod]
        or days between start of M.relevantPeriod and end of M.relevantPeriod < 180
        or M.relevantPeriod ends during Interval[1 day after start of M.relevantPeriod, end of "Measurement Period"]
        or 180 days after start of M.relevantPeriod before end of "Measurement Period")
  and exists("Follow-Up" P
    with ["Medication": "Able; Opioids Used for Pain Control"] M
      such that P.relevantPeriod starts during Interval[181 days after start of M.relevantPeriod, 270 days after start of M.relevantPeriod]
        or days between start of M.relevantPeriod and end of M.relevantPeriod < 270
        or M.relevantPeriod ends during Interval[181 day after start of M.relevantPeriod, end of "Measurement Period"]
        or 270 days after start of M.relevantPeriod before end of "Measurement Period")
  and exists("Follow-Up" P
    with ["Medication": "Able; Opioids Used for Pain Control"] M
      such that P.relevantPeriod starts during Interval[271 days after start of M.relevantPeriod, 360 days after start of M.relevantPeriod]
        or days between start of M.relevantPeriod and end of M.relevantPeriod < 360
        or M.relevantPeriod ends during Interval[271 day after start of M.relevantPeriod, end of "Measurement Period"]
        or 360 days after start of M.relevantPeriod before end of "Measurement Period")

define "Denominator":
  exists("Denominator Encounter")
  and "Opioid Exists"

define "Numerator Performance Met: G9562":
  /*
   * config_link_id: G9562
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9562"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Follow-Up Every 3 Months Exists" // Not yet tested - need to verify implementation and need

define "Numerator Performance Not Met: G9563":
  /*
   * config_link_id: G9563
   */
  not "Numerator Performance Met: G9562"
