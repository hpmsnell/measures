library HEDIS_OMW_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: OMW
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: 3095F" //Bone Mineral Density Tests
valueset "MIPS; Performance Met: G8633" //Osteoporosis Medication
valueset "MIPS; Performance Met: G8399" //DXA

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Fractures": '2.16.840.1.113883.3.464.1004.1103'
valueset "HEDIS; Bone Mineral Density Tests": '2.16.840.1.113883.3.464.1004.1047'
valueset "HEDIS; Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1197'

// NCQA medication list value sets

valueset "NCQA; Long-Acting Osteoporosis Medications": '2.16.840.1.113883.3.464.1004.1396'
valueset "NCQA; Osteoporosis Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
  A 12-month (1 year) window that...
    - begins on July 1 of the year prior to the measurement year and
    - ends on June 30 of the measurement year.
*/
define "Intake Period":
  (year from start of "Measurement Period")IntakeYear
  return Interval[Date(IntakeYear -1, 7, 1), Date(IntakeYear, 6, 30)]

/*
  intake period through the end of the measurement year
*/
define "Intake Period Through End of Measurement Period":
  Interval[start of "Intake Period", end of "Measurement Period"]

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]


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

define "Fracture During Index Period":
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


define "Denominator Exclusion: Frailty and Advanced Illness":
  /*
   * config_link_id: exclusion_frailty_advanced_illness
   */
   (
     AgeInYearsAt(end of "Measurement Period") >= 67
     and (
        "LTI During Period"("Intake Period Through End of Measurement Period")
        or "SNP"
     )
   )
   or (
     AgeInYearsAt(end of "Measurement Period") between 67 and 80
     and (
        "LTI During Period"("Measurement Period")
        or "SNP"
        or ("Advanced Illness"("Measurement Period and Year Prior")
             and ("Frailty: Claim During Period"("Intake Period Through End of Measurement Period")))
     )
   )
   or (
     AgeInYearsAt(end of "Measurement Period") >= 81
     and ("Frailty: Claim During Period"("Intake Period Through End of Measurement Period"))
   )


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
  and not "Numerator Performance Met"
