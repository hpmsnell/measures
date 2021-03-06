library HEDIS_OMW_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: OMW
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 3095F" //Bone Mineral Density Tests
valueset "MIPS; Performance Met: G8633" //Osteoporosis Medication
valueset "MIPS; Performance Met: G8399" //DXA

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Fractures": '2.16.840.1.113883.3.464.1004.1103'
valueset "HEDIS; Bone Mineral Density Tests": '2.16.840.1.113883.3.464.1004.1047'
valueset "HEDIS; Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1197'
valueset "HEDIS; Long-Acting Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1396'
valueset "HEDIS; Osteoporosis Medications List"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]

define "Fracture":
  ["Diagnosis": "HEDIS; Fractures"]
  union ["Procedure, Performed": "HEDIS; Fractures"]

define "Encounter With Fracture":
  "Encounter" E
    with "Fracture" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Fracture During Index Period"
  "Encounter With Fracture" E
    where E.relevantPeriod starts during [18 months before end of "Measurement Period", 6 months before end of "Measurement Period"]

define "Fracture During Index Period Exists":
  exists("Fracture During Index Period")

define "First Fracture During Index Period":
  First("Encounter With Fracture" E
    sort by E.relevantPeriod asc)

define "First Fracture During Index Period Has Prior Diagnosis":
  exists("First Fracture During Index Period" E1
    with "Encounter With Fracture" E2
      such that E2.relevantPeriod starts 60 days or less before start of E1.relevantPeriod

define "Bone Density Tests":
  ["Assessment, Performed": "HEDIS; Bone Mineral Density Tests"]
  union ["Procedure, Performed": "MIPS; Performance Met: 3095F"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8399"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and AgeInYearsAt(end of "Measurement Period") < 86
  and "Patient Characteristic Sex" = "Female"
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and "Fracture During Index Period Exists"
  and not "First Fracture During Index Period Has Prior Diagnosis"

define "Denominator Exclusion: Prior Treatment":
  /*
   * config_link_id: exclusion_1
   */
   exists("First Fracture During Index Period" E
     with "Bone Density Tests" T
       such that T.authorDateTime 730 days or less before start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Procedure, Performed": "MIPS; Performance Met: G8633"] P
       such that P.relevantPeriod starts 365 days or less before start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Procedure, Performed": "HEDIS; Osteoporosis Medications"] M
       such that M.relevantPeriod starts 365 days or less before start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication": "HEDIS; Osteoporosis Medications List"] M
       such that M.relevantPeriod overlaps [365 days before start of E.relevantPeriod, 1 day before start of E.relevantPeriod])

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First Fracture During Index Period" E
     with "Bone Density Tests" T
       such that T.authorDateTime on or 180 days or less after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Procedure, Performed": "MIPS; Performance Met: G8633"] P
       such that P.relevantPeriod starts on or 180 days after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication": "HEDIS; Osteoporosis Medications"] M
       such that M.relevantPeriod starts on or 180 days after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication": "HEDIS; Osteoporosis Medications List"] M
       such that M.relevantPeriod starts on or 180 days after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication": "HEDIS; Long-Acting Osteoporosis Medications"] M
       such that M.relevantPeriod starts during E.relevantPeriod)


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
