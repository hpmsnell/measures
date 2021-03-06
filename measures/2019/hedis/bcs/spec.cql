library HEDIS_BCS_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: BCS
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// MIPS value sets

valueset "MIPS; Performance Met: G9899"

// HEDIS value sets

valueset "HEDIS; Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1042'
valueset "HEDIS; History of Bilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1331'
valueset "HEDIS; Unilateral Mastectomy": '2.16.840.1.113883.3.464.1004.1256'
valueset "HEDIS; Left Modifier": '2.16.840.1.113883.6.12'
valueset "HEDIS; Right Modifier": '2.16.840.1.113883.6.12'
valueset "HEDIS; Absence of Left Breast": '2.16.840.1.113883.3.464.1004.1329'
valueset "HEDIS; Absence of Right Breast": '2.16.840.1.113883.3.464.1004.1330'
valueset "HEDIS; Unilateral Mastectomy Left": '2.16.840.1.113883.3.464.1004.1334'
valueset "HEDIS; Unilateral Mastectomy Right": '2.16.840.1.113883.3.464.1004.1335'
valueset "HEDIS; Mammography": '2.16.840.1.113883.3.464.1004.1168'
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

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ((["Encounter, Performed": "HEDIS; Nonacute Inpatient"])NonacuteIP
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that NonacuteIP.claimId = NonacuteIPFlag.claimId)
  union ((["Encounter, Performed": "HEDIS; InpatientStay"])Inpatient
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
    such that Inpatient.claimId = NonacuteIPFlag.claimId)

define "Absence of Left Breast":
  ["Diagnosis": "HEDIS; Absence of Left Breast"]
  union (["Diagnosis": "HEDIS; Clinical Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Left Modifier")
  union ["Procedure, Performed": "HEDIS; Unilateral Mastectomy Left"]
  union (["Procedure, Performed": "HEDIS; Clinical Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Left Modifier")
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Left Modifier")

define "Absence of Left Breast Confirmed":
   "Absence of Left Breast" AbsentLt
    where (
      AbsentLt.prevalencePeriod starts before end of "Measurement Period"
      or AbsentLt.relevantPeriod starts before end of "Measurement Period"
    )
      and AbsentLt.placeOfService != '81'

define "Absence of Right Breast":
  ["Diagnosis": "HEDIS; Absence of Right Breast"]
  union (["Diagnosis": "HEDIS; Clinical Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Right Modifier")
  union ["Procedure, Performed": "HEDIS; Unilateral Mastectomy Right"]
  union (["Procedure, Performed": "HEDIS; Clinical Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Clinical Right Modifier")
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] P
    where P.code.modifier in "HEDIS; Right Modifier")

define "Absence of Right Breast Confirmed":
  "Absence of Right Breast" AbsentRt
    where (
      AbsentRt.prevalencePeriod starts before end of "Measurement Period"
      or AbsentRt.relevantPeriod starts before end of "Measurement Period"
    )
      and AbsentRt.placeOfService != '81'

define "Bilateral Mastectomy Procedure":
  (["Procedure, Performed": "HEDIS; Bilateral Mastectomy"]
  union (["Procedure, Performed": "HEDIS; Clinical Unilateral Mastectomy"] PClinUni
    where PClinUni.code.modifier in "HEDIS; Clinical Bilateral Modifier")
  union (["Procedure, Performed": "HEDIS; Unilateral Mastectomy"] PUniMast
    where PUniMast.code.modifier in "HEDIS; Bilateral Modifier")
  union ["Procedure, Performed": "HEDIS; History of Bilateral Mastectomy"])PBilatMast
  where PBilatMast.relevantPeriod starts before end of "Measurement Period"
    and PBilatMast.placeOfService != '81'

define "Bilateral Mastectomy Clinical Info":
  (["Diagnosis": "HEDIS; Clinical Unilateral Mastectomy"] DxClinUni
    where DxClinUni.code.modifier in "HEDIS; Clinical Bilateral Modifier")
  union (["Diagnosis": "HEDIS; History of Bilateral Mastectomy"])DxBilatMast
    where DxBilatMast.prevalencePeriod starts before end of "Measurement Period"
      and DxBilatMast.placeOfService != '81'

define "Absence of Left and Right Breast Confirmed":
  exists "Absence of Left Breast Confirmed"
  and exists "Absence of Right Breast Confirmed"

// Populations

define "Denominator":
  "Patient Characteristic Sex" = "Female"
  and AgeInYearsAt(end of "Measurement Period") >= 52
  and AgeInYearsAt(end of "Measurement Period") < 75

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Mastectomy":
  /*
   * config_link_id: exclusion_1
   */
  exists "Bilateral Mastectomy Procedure"
    or exists "Bilateral Mastectomy Clinical Info"
    or exists "Absence of Left and Right Breast Confirmed"

define "Denominator Exclusion: Frailty and Advanced Illness":
   /*
    * config_link_id: exclusion_required_frailty
    */
      AgeInYearsAt(end of "Measurement Period") >= 66
      and ("LTI During Period"("Measurement Period")
         or "SNP"("Measurement Period")
         or ("Advanced Illness"("Measurement Period and Year Prior")
              and "Frailty: Claim During Period"("Measurement Period")
            )

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
