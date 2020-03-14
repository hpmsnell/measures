library HEDIS_BCS_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: BCS
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G9899"

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1042'
valueset "HEDIS; History of Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1331'
valueset "HEDIS; Unilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1256'
valueset "HEDIS; Absence of Left Breast": '2.16.840.1.113883.3.464.1004.1329'
valueset "HEDIS; Absence of Right Breast": '2.16.840.1.113883.3.464.1004.1330'
valueset "HEDIS; Unilateral Mastectomy Left": '2.16.840.1.113883.3.464.1004.1334'
valueset "HEDIS; Unilateral Mastectomy Right": '2.16.840.1.113883.3.464.1004.1335'
valueset "HEDIS; Mammography": '2.16.840.1.113883.3.464.1004.1168'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Clinical Bilateral Modifier": '2.16.840.1.113883.3.464.1004.1951'
valueset "HEDIS; Clinical Left Modifier": '2.16.840.1.113883.3.464.1004.1949'
valueset "HEDIS; Clinical Right Modifier": '2.16.840.1.113883.3.464.1004.1950'
valueset "HEDIS; Clinical Unilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1948'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'

// NCQA medication list value sets

valueset "NCQA; Dementia Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Exclusion Age":
AgeInYearsAt(end of "Measurement Period") >= 66

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ((["Encounter, Performed": "HEDIS; Nonacute Inpatient"])NonacuteIP
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that NonacuteIP.relevantPeriod = NonacuteIPFlag.relevantPeriod)
  union ((["Encounter, Performed": "HEDIS; Inpatient Stay"])Inpatient
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that Inpatient.relevantPeriod = NonacuteIPFlag.relevantPeriod)

define "Visit with Advanced Illness":
"Visit" ExcludeQualVisit
  where exists (ExcludeQualVisit.diagnoses Diagnosis
    where Diagnosis.code in "HEDIS; Advanced Illness"
    )
     and ExcludeQualVisit.relevantPeriod starts 2 years or less before end of "Measurement Period"

define "Advanced Illness Exists":
"Qualifying Exclusion Age"
  and (Count("Visit with Advanced Illness")>=2
    or exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
      with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.prevalencePeriod starts during E.relevantPeriod)
    or exists(["Medication, Dispensed": "NCQA; Dementia Medications"] M
      where M.relevantPeriod starts during "Measurement Period"))

define "Absence of Left Breast":
  ["Diagnosis": "HEDIS; Absence of Left Breast"]
  union ["Procedure, Performed": "HEDIS; Unilateral Mastectomy Left"]
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Left Modifier")

define "Absence of Left Breast Confirmed":
  "Absence of Left Breast" AbsentLt
    where AbsentLt.prevalencePeriod starts before end of "Measurement Period"
      or AbsentLt.relevantPeriod starts before end of "Measurement Period"

define "Absence of Right Breast":
  ["Diagnosis": "HEDIS; Absence of Right Breast"]
  union ["Procedure, Performed": "HEDIS; Unilateral Mastectomy Right"]
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Right Modifier")

define "Absence of Right Breast Confirmed":
  "Absence of Right Breast" AbsentRt
    where AbsentRt.prevalencePeriod starts before end of "Measurement Period"
      or AbsentRt.relevantPeriod starts before end of "Measurement Period"

define "Bilateral Mastectomy Procedure":
  (["Procedure, Performed": "HEDIS; Bilateral Mastectomy"]
  union (["Procedure, Performed": "HEDIS; Clinical Unilateral Mastectomy"] PClinUni
    where PClinUni.code.modifier in "HEDIS; Clinical Bilateral Modifier")
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] PUniMast
    where PUniMast.code.modifier in "HEDIS; Bilateral Modifier")
  union ["Procedure, Performed": "HEDIS; History of Bilateral Mastectomy"])PBilatMast
  where PBilatMast.relevantPeriod starts before end of "Measurement Period"

define "Bilateral Mastectomy Clinical Info":
  ((["Diagnosis": "HEDIS; Clinical Unilateral Mastectomy"] DxClinUni
    where DxClinUni.code.modifier in "HEDIS; Clinical Bilateral Modifier")
  union (["Diagnosis": "HEDIS; History of Bilateral Mastectomy"])DxBilatMast
    where DxBilatMast.prevalencePeriod starts before end of "Measurement Period")

define "Absence of Left and Right Breast Confirmed":
  exists "Absence of Left Breast Confirmed"
  and exists "Absence of Right Breast Confirmed"

  define "Frailty Diagnosis or Symptoms":
    ((["Diagnosis": "HEDIS; Frailty Diagnosis"]
    union ["Diagnosis": "HEDIS; Frailty Symptom"])FrailDxSx
      where FrailDxSx.prevalencePeriod overlaps "Measurement Period")

  define "Frailty Encounter":
    ["Encounter, Performed": "HEDIS; Frailty Encounter"]FrailEnc
        where FrailEnc.relevantPeriod overlaps "Measurement Period"

  define "Frailty Device":
    ((["Device, Applied": "HEDIS; Frailty Device"]
    union ["Device, Order": "HEDIS; Frailty Device"]
    union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
      where FrailDevice.relevantPeriod overlaps "Measurement Period"
        or FrailDevice.authorDatetime during "Measurement Period")

  define "Frailty":
    "Frailty Diagnosis or Symptoms"
    union "Frailty Encounter"
    union "Frailty Device"

// Populations

define "Denominator":
  "Patient Characteristic Sex" = "Female"
  and AgeInYearsAt(end of "Measurement Period") >= 52
  and AgeInYearsAt(end of "Measurement Period") < 75
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Mastectomy":
  /*
   * config_link_id: exclusion_1
   */
  exists "Bilateral Mastectomy Procedure"
    or exists "Bilateral Mastectomy Clinical Info"
    or exists "Absence of Left and Right Breast Exists"

define "Denominator Exclusion: Frailty and Advanced Illness":
  /*
   * config_link_id: exclusion_2
   */
   "Advanced Illness Exists"
     and exists("Frailty")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  (["Procedure, Performed": "HEDIS; Mammography"]
  union ["Procedure, Performed": "MIPS; Performance Met: G9899"]) Mammogram
    where Mammogram.relevantPeriod ends 27months or less before end of "Measurement Period"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Mastectomy"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
