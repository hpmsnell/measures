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

// VSAC Value Sets

valueset "VSAC; Functional Status Assessment for Knee Replacement": '2.16.840.1.113883.3.464.1003.118.11.1040'
valueset "VSAC; Functional Status Assessment for Hip Replacement": '2.16.840.1.113883.3.464.1003.118.11.1039'
valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'
valueset "VSAC; Pain Assessments": '2.16.840.1.113762.1.4.1047.152'

// ABLE Value Sets

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

define "Opioid Start Time":
  "Opioid" M
    return start of M.relevantPeriod

define "Opioid Duration":
  "Opioid" M
    return M.duration

define "Opioid Interval":
  return Interval["Opioid Start Time", "Opioid Start Time" + "Opioid Duration"]

define "Opioid Super Interval":
  /*
   * The intent is to combine any overlapping opioid intervals by summing the duration (days_supplied)
   * and adding them to the start date of the first prescription
   */
  if("Opioid Interval" overlaps "Opioid Interval") // If any opioid intervals overlap
    return Interval["Opioid Start Time", "Opioid Start Time" + sum("Opioid Duration")] // Sum the durations and add to the start of the first prescription to get the new interval

define "Denominator Encounter and Opioid Procedure Exists":
  exists("Denominator Encounter")
  and exists("Opioid Procedure")

define "Denominator Encounter with Opioid Medication Exists"
  exists("Denominator Encounter" E
    where E.relevantPeriod starts before or on end of "Opioid Super Interval"
      and E.relevantPeriod starts more than 42 days after start of "Opioid Super Interval")

define "Expected Number of Assessments":
  /*
   * This is the super interval from the denominator
   */
  return Floor(end of "Opioid Super Interval" - start of "Opioid Super Interval") / 90)

define "Functional Status Assessment":
  ["Assessment, Performed": "VSAC; Functional Status Assessment for Knee Replacement"]
  union ["Assessment, Performed": "VSAC; Functional Status Assessment for Hip Replacement"]

define "Functional Status Assessment in Super Interval":
  /*
   * The intent is to identify assessments less than 90 days after the start of the interval or another assessment
   * AND 90 days before the end of the interval or another assessment
   */
  "Functional Status Assessment" A1
    with "Functional Status Assessment" A2
      such that A1.authorDateTime is less than 90 days after start of "Opioid Super Interval"
        or A1.authorDateTime is less than 90 days after start A2.authorDateTime
      such that A1.authorDateTime is less than 90 days before end of "Opioid Super Interval" //I'm using "such that" twice (probably incorrectly) to indicate an AND separating two sets of ORs
        or A1.authorDateTime is less than 90 days before start A2.authorDateTime

define "Functional Status Assessments Exist Every 3 Months"
  count("Functional Status Assessment in Super Interval") >= "Expected Number of Assessments"

define "Pain Assessment":
  ["Assessment, Performed": "VSAC; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "VSAC; Pain Assessments"]

define "Pain Assessment in Super Interval":
  /*
   * The intent is to identify assessments less than 90 days after the start of the interval or another assessment
   * AND 90 days before the end of the interval or another assessment
   */
  "Pain Assessment" A1
    with "Pain Assessment" A2
      such that A1.authorDateTime is less than 90 days after start of "Opioid Super Interval"
        or A1.authorDateTime is less than 90 days after start A2.authorDateTime
      such that A1.authorDateTime is less than 90 days before end of "Opioid Super Interval" //I'm using "such that" twice (probably incorrectly) to indicate an AND separating two sets of ORs
        or A1.authorDateTime is less than 90 days before start A2.authorDateTime

define "Pain Assessments Exist Every 3 Months"
  count("Pain Assessment in Super Interval") >= "Expected Number of Assessments"

define "Assessments Exist Every 3 Months"
  "Pain Assessments Exist Every 3 Months"
  and "Functional Status Assessments Exist Every 3 Months"

define "Denominator":
  "Denominator Encounter and Opioid Procedure Exists"
  or "Denominator Encounter with Opioid Medication Exists"

define "Numerator Performance Met: G9562":
  /*
   * config_link_id: G9562
   * The intent is to identify patients with an assessment at least every 3 months
   * during the duration of the opioid prescription from the denominator
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9562"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Assessments Exist Every 3 Months"

define "Numerator Performance Not Met: G9563":
  /*
   * config_link_id: G9563
   */
  not "Numerator Performance Met: G9562"
