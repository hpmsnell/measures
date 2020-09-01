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

define "Outpatient EncounterSet":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]) E1
      where E1.code.modifier != "HEDIS; Telehealth Modifier"
        and E1.placeOfService != "HEDIS; Telehealth POS"

define "Fracture":
  ["Diagnosis": "HEDIS; Fractures"]
  union ["Procedure, Performed": "HEDIS; Fractures"]

define "Outpaient Encounter With Fracture":
  "Outpatient EncounterSet" E
    with "Fracture" D
      such that D.prevalencePeriod starts during E.relevantPeriod
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E.relevantPeriod

define "Outpatient Encounter With Fracture Resulted in Inpatient Stay":
  "Outpatient EncounterSet" E
    with "Fracture" D
      such that D.prevalencePeriod starts during E.relevantPeriod
    with ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E.relevantPeriod

define "Inpatient Stay with Fracture":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] E
    with "Fracture" D
      where E.claimId = D.claimId

define "Fracture During Index Period Outpaient EncounterSet":
  "Outpaient Encounter With Fracture" E
    where E.relevantPeriod starts during [18 months before end of "Measurement Period", 6 months before end of "Measurement Period"]

define "Fracture During Index Period Inpatient EncounterSet":
  "Inpatient Stay with Fracture" E
    where E.dischargeDate during [18 months before end of "Measurement Period", 6 months before end of "Measurement Period"]

define "Fracture During Index Period":
    ["Fracture During Index Period Outpatient EncounterSet"]
    union ["Fracture During Index Period Inpatient EncounterSet"]

define "Fracture During Index Period Exists":
  exists("Fracture During Index Period")

  //negative diagnoses Outpatient Valueset

define "Negative Diagnoses Outpatient EncounterSet with Fracture":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]) E1
    with "Fracture" D
      such that D.prevalencePeriod starts during E1.relevantPeriod

define "First Fracture During Index Period Outpatient EncounterSet Date":
  First("Fracture During Index Period Outpatient EncounterSet" E
    sort by start of E.relevantPeriod asc
    return start of E.relevantPeriod)

define "First Fracture During Index Period Inpatient EncounterSet Date":
  First("Fracture During Index Period Inpatient EncounterSet" E
    sort by E.dischargeDate asc
    return E.dischargeDate)

define "First Fracture Date":
  Min(
    "First Fracture During Index Period Outpatient EncounterSet Date"
    union "First Fracture During Index Period Inpatient EncounterSet Date"
  )

define "First Fracture During Index Period Has Prior Diagnosis Outpatient Encounterset":
  exists("Negative Diagnoses Outpatient EncounterSet with Fracture" E
    where E.relevantPeriod starts 60 days or less before "First Fracture Date")

//negative diagnosis Inpatient Valueset
define "First Fracture During Index Period Has Prior Diagnosis Inpatient Stay":
  exists("Inpatient Stay with Fracture" E
    where E.relevantPeriod starts 60 days or less before "First Fracture During Index Period Inpatient EncounterSet Date")

define "Direct Transfer Inpatient Stay Inpatient EncounterSet":
  "Inpatient Stay with Fracture" E
    with ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during [1 days before end of E.relevantPeriod, end of E.relevantPeriod]

define "First Fracture During Index Period Has Prior Diagnosis Direct Transfer":
      "Direct Transfer Inpatient Stay Inpatient EncounterSet" E
        where E.relevantPeriod starts 60 days or less before  "First Fracture During Index Period Inpatient EncounterSet Date")

define "Encounter With Fracture Resulted in Inpatient Stay Prior Diagnosis Outpatient Online":
      "Outpatient Encounter With Fracture Resulted in Inpatient Stay" E2
        where E2.relevantPeriod starts 60 days or less before "First Fracture During Index Period Inpatient EncounterSet Date")

define "First Fracture During Index Period Has Prior Diagnosis":
    "First Fracture During Index Period Has Prior Diagnosis Outpatient Encounterset"
    union "First Fracture During Index Period Has Prior Diagnosis Inpatient Stay"
    union "First Fracture During Index Period Has Prior Diagnosis Direct Transfer"
    union "Encounter With Fracture Resulted in Inpatient Stay Prior Diagnosis Outpatient Online"


/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and AgeInYearsAt(end of "Measurement Period") < 86
  and "Patient Characteristic Sex" = "Female"
  and "Fracture During Index Period Exists"
  and not exists("First Fracture During Index Period Has Prior Diagnosis")

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
   /*
    * config_link_id: exclusion_required_frailty
    */
    AgeInYearsAt(end of "Measurement Period") >= 67
     and ("LTI During Period"("Measurement Period")
           or "SNP"("Measurement Period")
           or (
              AgeInYearsAt(end of "Measurement Period") <= 80
              and "Advanced Illness"("Measurement Period and Year Prior")
              and "Frailty: Claim During Period"("Measurement Period")
             )
             or (
                AgeInYearsAt(end of "Measurement Period") > 80

               )
       )

define "Denominator Exclusion: Prior Treatment":
    /*
     * config_link_id: exclusion_1
     */
     exists("Bone Density Tests" T
              where T.relevantDate 730 days or less before "First Fracture Date")
     or exists(["Procedure, Performed": "HEDIS; Osteoporosis Medications"] M
              where M.relevantPeriod starts 365 days or less before "First Fracture Date")
     or exists(["Medication, Dispensed": "NCQA; Osteoporosis Medications List"] M
              where M.relevantPeriod starts during [365 days before "First Fracture Date", 1 day before "First Fracture Date"])

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Inpatient Stay with Fracture") Inpatient
    where "First Fracture Date" during [Inpatient.admissionDate,Inpatient.dischargeDate]
    with ["Medication, Dispensed": "NCQA; Long-Acting Osteoporosis Medications"] M
      such that M.relevantPeriod starts during  [Inpatient.admissionDate,Inpatient.dischargeDate])
  or exists("Inpatient Stay with Fracture") Inpatient
    where "First Fracture Date" during [Inpatient.admissionDate,Inpatient.dischargeDate]
    with ["Assessment, Performed": "HEDIS; Bone Mineral Density Tests"] Test
      such that Test.relevantDate during  [Inpatient.admissionDate,Inpatient.dischargeDate])
  or exists("Bone Density Tests" T
        where T.relevantDate on or 180 days or less after "First Fracture Date")
  or exists(["Procedure, Performed": "HEDIS; Osteoporosis Medications"] P
        where P.relevantPeriod starts on or 180 days after "First Fracture Date")
  or exists(["Medication, Dispensed": "NCQA; Osteoporosis Medications"] M
        where M.relevantPeriod starts on or 180 days after "First Fracture Date")


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Prior Treatment"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Exclusion: Hospice"
  and not "Numerator Performance Met"
