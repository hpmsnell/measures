library HEDIS_BCS_2020

/*
 *
 * Source: HEDIS
 * ID: BCS
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared" called HedisShared

// HEDIS value sets

valueset "HEDIS; BILATERAL_MASTECTOMY": '2.16.840.1.113883.3.464.1004.1042'
valueset "HEDIS; HISTORY OF BILATERAL_MASTECTOMY": '2.16.840.1.113883.3.464.1004.1331'
valueset "HEDIS; UNILATERAL MASTECTOMY": '2.16.840.1.113883.3.464.1004.1256'
valueset "HEDIS; LEFT_MODIFIER": '2.16.840.1.113883.6.12'
valueset "HEDIS; RIGHT_MODIFIER": '2.16.840.1.113883.6.12'
valueset "HEDIS; ABSENCE_OF_LEFT_BREAST": '2.16.840.1.113883.3.464.1004.1329'
valueset "HEDIS; ABSENCE_OF_RIGHT_BREAST": '2.16.840.1.113883.3.464.1004.1330'
valueset "HEDIS; UNILATERAL_MASTECTOMY_LEFT": '2.16.840.1.113883.3.464.1004.1334'
valueset "HEDIS; UNILATERAL_MASTECTOMY_RIGHT": '2.16.840.1.113883.3.464.1004.1335'
valueset "HEDIS; MAMMOGRAPHY": '2.16.840.1.113883.3.464.1004.1168'
valueset "HEDIS; OUTPATIENT": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; OBSERVATION": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; NONACUTE_INPATIENT": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; NONACUTE_INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; ACUTE_INPATIENT": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; CLINICAL_BILATERAL_MODIFIER": '2.16.840.1.113883.3.464.1004.1951'
valueset "HEDIS; CLINICAL_LEFT_MODIFIER": '2.16.840.1.113883.3.464.1004.1949'
valueset "HEDIS; CLINICAL_RIGHT_MODIFIER": '2.16.840.1.113883.3.464.1004.1950'
valueset "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY": '2.16.840.1.113883.3.464.1004.1948'
valueset "HEDIS; INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1395'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Populations
define "Initial Population"
  AgeInYearsAt(end of "Measurement Period") >= 52
  and AgeInYearsAt(end of "Measurement Period") < 75
  "Sex" = "Female"

define "Denominator":
  "Initial Population"

define "Exclusion: Hospice":
  /*
  * Option ID: exclusion_required_hospice
  */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Palliative Care":
 /*
  * Option Id: exclusion_palliative_care
  */
   exists("Palliative Care"("Measurement Period"))

define "Denominator Exclusion: Mastectomy":
  /*
   * Option ID: exclusion_1
   */
  exists "Bilateral Mastectomy Procedure"
    or exists "Bilateral Mastectomy Clinical Info"
    or exists "Absence of Left and Right Breast Confirmed"

define "Denominator Exclusion: Frailty and Advanced Illness":
   /*
    * Option ID: exclusion_required_frailty
    */
      AgeInYearsAt(end of "Measurement Period") >= 66
      and ("LTI During Period"("Measurement Period")
         or "SNP"("Measurement Period")
         or ("Advanced Illness"("Measurement Period and Year Prior")
              and "Frailty: Claim During Period"("Measurement Period")
            )

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  (["Clinical Activity": "HEDIS; Mammography"]) Mammogram
    where Mammogram.end_date 27 months or less before end of "Measurement Period"

//Definitions

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

define "Visit":
  ["Clinical Activity": "HEDIS; Outpatient"]
  union ["Clinical Activity": "HEDIS; Observation"]
  union ["Clinical Activity": "HEDIS; ED"]
  union ((["Clinical Activity": "HEDIS; NONACUTE_INPATIENT"])NonacuteIP
    with (["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"])NonacuteIPFlag
    such that NonacuteIP.claim_id = NonacuteIPFlag.claim_id)
  union ((["Clinical Activity": "HEDIS; InpatientStay"])Inpatient
    with (["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"])NonacuteIPFlag
    such that Inpatient.claim_id = NonacuteIPFlag.claim_id)

define "Absence of Left Breast":
  ["Diagnosis": "HEDIS; ABSENCE_OF_LEFT_BREAST"]
  union (["Diagnosis": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] DiagClinicalUnilateralMast
    where DiagClinicalUnilateralMast.code_modifiers in "HEDIS; CLINICAL_LEFT_MODIFIER")
  union ["Clinical Activity": "HEDIS; UNILATERAL_MASTECTOMY_LEFT"]
  union (["Clinical Activity": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] ClinicalUnilateralMast
    where ClinicalUnilateralMast.code_modifiers in "HEDIS; CLINICAL_LEFT_MODIFIER")
  union (["Clinical Activity": "HEDIS; Unilateral Mastectomy"] UnilateralMast
    where UnilateralMast.code_modifiers in "HEDIS; LEFT_MODIFIER")

define "Absence of Left Breast Confirmed":
   "Absence of Left Breast" AbsentLt
    where (
      AbsentLt.start_date on or before end of "Measurement Period"
      or AbsentLt.start_date on or before end of "Measurement Period"
    )
      and AbsentLt.place_of_service != '81'

define "Absence of Right Breast":
  ["Diagnosis": "HEDIS; ABSENCE_OF_RIGHT_BREAST"]
  union (["Diagnosis": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] DiagClinicalUnilateralMast
    where DiagClinicalUnilateralMast.code_modifiers in "HEDIS; CLINICAL_RIGHT_MODIFIER")
  union ["Clinical Activity": "HEDIS; UNILATERAL_MASTECTOMY_RIGHT"]
  union (["Clinical Activity": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] ClinicalUnilateralMast
    where ClinicalUnilateralMast.code_modifiers in "HEDIS; CLINICAL_RIGHT_MODIFIER")
  union (["Clinical Activity": "HEDIS; UNILATERAL_MASTECTOMY"] UnilateralMast
    where UnilateralMast.code_modifiers in "HEDIS; RIGHT_MODIFIER")

define "Absence of Right Breast Confirmed":
  "Absence of Right Breast" AbsentRt
    where (
      AbsentRt.start_date on or before end of "Measurement Period"
      or AbsentRt.start_date on or before end of "Measurement Period"
    )
      and AbsentRt.place_of_service != '81'

define "Bilateral Mastectomy Procedure":
  (["Clinical Activity": "HEDIS; BILATERAL_MASTECTOMY"]
  union (["Clinical Activity": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] PClinUni
    where PClinUni.code_modifiers in "HEDIS; CLINICAL_BILATERAL_MODIFIER")
  union (["Clinical Activity": "HEDIS; UNILATERAL_MASTECTOMY"] PUniMast
    where PUniMast.code_modifiers in "HEDIS; Bilateral Modifier")
  union ["Clinical Activity": "HEDIS; HISTORY_OF_BILATERAL_MASTECTOMY"])PBilatMast
  where PBilatMast.start_date on or before end of "Measurement Period"
    and PBilatMast.place_of_service != '81'

define "Bilateral Mastectomy Clinical Info":
  (["Diagnosis": "HEDIS; CLINICAL_UNILATERAL_MASTECTOMY"] DxClinUni
    where DxClinUni.code_modifiers in "HEDIS; CLINICAL_BILATERAL_MODIFIER")
  union (["Diagnosis": "HEDIS; HISTORY_OF_BILATERAL_MASTECTOMY"])DxBilatMast
    where DxBilatMast.start_date on or before end of "Measurement Period"
      and DxBilatMast.place_of_service != '81'

define "Absence of Left and Right Breast Confirmed":
  exists "Absence of Left Breast Confirmed"
  and exists "Absence of Right Breast Confirmed"
