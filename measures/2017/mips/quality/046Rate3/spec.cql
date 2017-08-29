library MIPS_046Rate3_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 046Rate3
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 046 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 1111F"
valueset "MIPS; Performance Not Met: 1111F-8P"

// VSAC value sets

valueset "VSAC; Hospital Inpatient Visit - Initial": '2.16.840.1.113883.3.464.1003.101.12.1004'
valueset "VSAC; Hospital Inpatient Visit - Subsequent": '2.16.840.1.113883.3.464.1003.101.11.1025'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Discharge Services - Hospital Inpatient Same Day Discharge": '2.16.840.1.113883.3.464.1003.101.12.1006'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; HbA1c Laboratory Test": '2.16.840.1.113883.3.464.1003.198.12.1013'

// Able value sets

valueset "Able; Medication Reconiliation"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Visit":
  ["Encounter, Performed": "VSAC; Hospital Inpatient Visit - Initial"]
  union ["Encounter, Performed": "VSAC; Hospital Inpatient Visit - Subsequent"]
  union ["Encounter, Performed": "VSAC; Nursing Facility Visit"]
  union ["Encounter, Performed": "VSAC; Discharge Services - Hospital Inpatient Same Day Discharge"]

define "MIPS 046 Encounter":
  ["Encounter, Performed": "MIPS; MIPS 046 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Inpatient Visit within 30 days of MIPS 046 Encounter"
  "Inpatient Visit" E1
    with "MIPS 046 Encounter" E2
      such that E1.relevantPeriod ends 30 days or less before start of E2.relevantPeriod

define "Denominator Encounter":
  "MIPS 046 Encounter" E1
    with "Inpatient Visit" E2
      such that E1.relevantPeriod ends 30 days or less after start of E2.relevantPeriod
    without "MIPS 046 Encounter" E3
      such that E3.relevantPeriod starts after start of "Inpatient Visit within 30 days of MIPS 046 Encounter"
        and E.relevantPeriod starts before E1.relevantPeriod


define "Medication Reconciliation":
  ["Procedure, Performed": "MIPS; Performance Met: 1111F"]
  union ["Procedure, Performed": "Able; Medication Reconciliation"]

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 1111F":
  /*
   * config_link_id: 1111F
   */
  exists("Medication Reconciliation" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: 1111F-8P":
  /*
   * config_link_id: 1111F-8P
   */
  not "Numerator Performance Met: 1111F"
