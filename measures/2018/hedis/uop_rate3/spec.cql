library HEDIS_UOP_RATE2_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: UOP Rate 2
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice"
valueset "NCQA; Opioid Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Opioid":
  ["Medication, Ordered": "HEDIS; Opioid Medication"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Opioid Start Date":
  "Opioid" M
    return start of M.relevantPeriod

define "Opioid Stop Date":
  "Opioid" M
    return end of M.relevantPeriod

define "Opioid Period End Date":
  Min(["Opioid Stop Date", end of "Measurement Period"])

define "Opioid Days Supplied":
  "Opioid Period End Date" - "Opioid Start Date"

/* Populations */

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and exists("Opioid" M1
    with "Opioid" M2
      where M2.relevantPeriod starts 1 day or more after start of M1.relevantPeriod)
  and Sum("Opioid Days Supplied") >= 15
  and not exists(["Intervention, Performed": "HEDIS; Hospice"] I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "UOP Rate 1: Numerator Performance Met"
  and "UOP Rate 2: Numerator Performance Met"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
