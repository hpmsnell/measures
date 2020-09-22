library HEDIS_ART_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: ART
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Rheumatoid Arthritis": '2.16.840.1.113883.3.464.1004.1229'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
valueset "HEDIS; HIV Type 2": '2.16.840.1.113883.3.464.1004.1406'
valueset "HEDIS; DMARD": '2.16.840.1.113883.3.464.1004.1070'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// NCQA value sets

valueset "HEDIS; DMARD Medications"

// Able value sets

valueset "Able; DMARD Medication"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Visit with Arthritis":
  "Outpatient Visit with Arthritis"
  union "Discharge With Arthritis"

define "Outpatient Visit with Arthritis":
  ["Encounter, Performed": "HEDIS; Outpatient"] E
    where E.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
    with ["Diagnosis": "Rheumatoid Arthritis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Discharge with Arthritis":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
    where E1.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
    with ["Encounter, Performed": "Nonacute Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E1.relevantPeriod
    with ["Diagnosis": "Rheumatoid Arthritis"] D
      such that D.prevalencePeriod starts during E1.relevantPeriod

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "HIV":
  ["Diagnosis": "HEDIS; HIV"]
  union ["Diagnosis": "HEDIS; HIV Type 2"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  count("Visit with Arthritis") >= 2 // Should have different start dates
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: HIV":
  /*
   * config_link_id: exclusion_1
   */
  exists("HIV" D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis"; "HEDIS; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Intervention, Performed": "HEDIS; DMARD"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Order": "NCQA; DMARD Medications"] M
    where M.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Order": "Able; DMARD Medication"] M
    where M.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: HIV"
  and not "Denominator Exclusion: Pregnancy"
  and not "Numerator Performance Met"
