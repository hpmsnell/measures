library HEDIS_OMW_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: OMW
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: 3095F" //Bone Mineral Density Tests
valueset "MIPS; Performance Met: G8633" //Osteoporosis Medication
valueset "MIPS; Performance Met: G8399" //DXA

// HEDIS value sets

valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Bone Mineral Density Tests": '2.16.840.1.113883.3.464.1004.1047'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Fractures": '2.16.840.1.113883.3.464.1004.1103'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1531'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1532'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1533'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Long-Acting Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1396'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1197'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'


// NCQA medication list value sets

valueset "NCQA; Long-Acting Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1396'
valueset "NCQA; Osteoporosis Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"] E1
      where E1.code.modifier != "HEDIS; Telehealth Modifier"
        and E1.placeOfService != "HEDIS; Telehealth POS"


  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]

define "Fracture":
  ["Diagnosis": "HEDIS; Fractures"]
  union ["Procedure, Performed": "HEDIS; Fractures"]

define "Encounter With Fracture":
  "Encounter" E
    with "Fracture" D
      such that D.prevalencePeriod starts during E.relevantPeriod
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E.relevantPeriod


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
  and "Fracture During Index Period Exists"
  and not "First Fracture During Index Period Has Prior Diagnosis"

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

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
     with ["Medication, Dispensed": "NCQA; Osteoporosis Medications List"] M
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
     with ["Procedure, Performed": "HEDIS; Osteoporosis Medications"] P
       such that P.relevantPeriod starts on or 180 days after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication, Dispensed": "NCQA; Osteoporosis Medications"] M
       such that M.relevantPeriod starts on or 180 days after start of E.relevantPeriod)
   or exists("First Fracture During Index Period" E
     with ["Medication, Dispensed": "NCQA; Long-Acting Osteoporosis Medications"] M
       such that M.relevantPeriod starts during E.relevantPeriod)


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Exclusion: Hospice"
  and not "Numerator Performance Met"
