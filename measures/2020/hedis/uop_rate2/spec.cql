library HEDIS_UOP_RATE2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: UOP Rate 2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'

// NCQA medication list value sets

valueset "NCQA; Opioid Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Opioid":
  ["Medication, Dispenseded": "NCQA; Opioid Medications"] M
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

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and exists("Opioid" M1
    with "Opioid" M2
      where M2.relevantPeriod starts 1 day or more after start of M1.relevantPeriod)
  and Sum("Opioid Days Supplied") >= 15
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Opioid" M1
    with "Opioid" M2
      such that M2.pharmacyNPI != M1.pharmacyNPI
    with "Opioid" M3
      such that M3.pharmacyNPI != M1.pharmacyNPI
        and M3.pharmacyNPI != M2.pharmacyNPI
    with "Opioid" M4
      such that M4.pharmacyNPI != M1.pharmacyNPI
        and M4.pharmacyNPI != M2.pharmacyNPI
        and M4.pharmacyNPI != M3.pharmacyNPI)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
