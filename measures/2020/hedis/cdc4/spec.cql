library HEDIS_CDC4_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC4
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Lab Test": '2.16.840.1.113883.3.464.1004.1755'
valueset "HEDIS; HbA1c Test Result or Finding": '2.16.840.1.113883.3.464.1004.1756'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; HbA1c Level Less Than 7.0": '2.16.840.1.113883.3.464.1004.1115'
valueset "HEDIS; HbA1c Level 7.0-9.0": '2.16.840.1.113883.3.464.1004.1113'
valueset "HEDIS; HbA1c Level Greater Than 9.0": '2.16.840.1.113883.3.464.1004.1114'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; CABG": '2.16.840.1.113883.3.464.1004.1048'
valueset "HEDIS; PCI": '2.16.840.1.113883.3.464.1004.1204'
valueset "HEDIS; Chronic Heart Failure": '2.16.840.1.113883.3.464.1004.1051'
valueset "HEDIS; MI ": '2.16.840.1.113883.3.464.1004.1157'
valueset "HEDIS; ESRD Diagnosis": '2.16.840.1.113883.3.464.1004.1747'
valueset "HEDIS; CKD Stage 4": '2.16.840.1.113883.3.464.1004.1052'
valueset "HEDIS; Dementia": '2.16.840.1.113883.3.464.1004.1074'
valueset "HEDIS; Frontotemporal Dementia": '2.16.840.1.113883.3.464.1004.1263'
valueset "HEDIS; Blindness": '2.16.840.1.113883.3.464.1004.1045'
valueset "HEDIS; Lower Extremity Amputation": '2.16.840.1.113883.3.464.1004.1154'
valueset "HEDIS; IVD": '2.16.840.1.113883.3.464.1004.1137'
valueset "HEDIS; Thoracic Aortic Aneurysm": '2.16.840.1.113883.3.464.1004.1248'

valueset "NCQA; Diabetes Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "HbA1c Lab Test":
  (["Assessment, Performed": "HEDIS; HbA1c Test Result or Finding"]
  union ["Laboratory Test, Performed": "HEDIS; HbA1c Lab Test"] HbA1cLab
    where HbA1cLab.result != null) HbA1cTest
    where HbA1cTest.relevantDatetime during "Measurement Period"

define "Last HbA1c Test":
  Last("HbA1c Lab Test" LastHbA1cTest
    sort by LastHbA1cTest.relevantDateTime asc)

define "HbA1C Result Greater or Equal to 7.0 ":
  ["Assessment, Performed": "HEDIS; HbA1c Level Greater Than 9.0"
  union ["Assessment, Performed": "HEDIS; HbA1c Level 7.0-9.0"]

define "Recent Excluded Procedure":
  ["Diagnosis": "HEDIS; CABG"]
  union ["Diagnosis": "HEDIS; PCI"]

define "Historical Excluded Diagnosis":
  ["Diagnosis": "HEDIS; Chronic Heart Failure"]
  union ["Diagnosis": "HEDIS; MI"]
  union ["Diagnosis": "HEDIS; ESRD Diagnosis"]
  union ["Diagnosis": "HEDIS; CKD Stage 4"]
  union ["Diagnosis": "HEDIS; Dementia"]
  union ["Diagnosis": "HEDIS; Frontotemporal Dementia"]
  union ["Diagnosis": "HEDIS; Blindness"]
  union ["Diagnosis": "HEDIS; Lower Extremity Amputation"]

define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]

define "IVD Encounter No Telehealth":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]
  union "Other Acute Inpatient Visit") E
    where not E.code.modifier in {'GT','95'}
      and not E.placeOfService in {'02'}

define "Other Acute Inpatient Visit":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
    without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that Inpatient.claimId != Nonacute.claimId
      and Inpatient.placeOfService != 81
      and Nonacute.placeOfService != 81

define "IVD Encounter Telehealth":
  (["Encounter, Performed": "Online Assessments"
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Outpatient"]
    where Outpt.code.modifier in {'GT','95'}
      or Outpt.placeOfService in {'02'}) TelehealthEnc

define "IVD Telehealth Encounter - Measurement Period"
  "IVD Encounter Telehealth" IVDTelehealth
    where IVDTelehealth.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps IVDTelehealth.relevantPeriod
      and IVDTelehealth.claimId = D.claimId

define "IVD Telehealth Encounter - Year Prior"
  "IVD Encounter Telehealth" IVDTelehealthPrior
    where IVDTelehealthPrior.relevantPeriod starts during [24 months before end of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps IVDTelehealthPrior.relevantPeriod)
      and IVDTelehealthPrior.claimId = D.claimId

define "IVD No Telehealth Encounter - Measurement Year"
  "IVD Encounter No Telehealth" NoTelehealth
    where NoTelehealth.dischargeDate during "Measurement Period"
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps NoTelehealth.relevantPeriod)
      and NoTelehealth.claimId = D.claimId

define "IVD No Telehealth Encounter - Year Prior"
  "IVD Encounter No Telehealth" NoTelehealthPrior
    where NoTelehealthPrior.dischargeDate during [24 months before end of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod overlaps NoTelehealthPrior.relevantPeriod)
      and NoTelehealthPrior.claimId = D.claimId

define "IVD Exists During Measurement Period and Year Prior":
  // Members who met at least one of the following criteria during both the measurement year and the year prior to the measurement year.
  // Only one of the two visits may be an outpatient telehealth visit, a telephone visit or an online assessment
  exists("IVD No Telehealth Encounter - Measurement Year"
    with "IVD No Telehealth Encounter - Year Prior")
  or exists("IVD No Telehealth Encounter - Year Prior"
    with "IVD Telehealth Encounter - Measurement Period")
  or exists("IVD Telehealth Encounter - Year Prior"
    with "IVD No Telehealth Encounter - Measurement Year")

define "Aneurysm Exists During Measurement Period and Year Prior":
  exists("Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Thoracic Aortic Aneurysm"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  and exists("Encounter" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", start of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Thoracic Aortic Aneurysm"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

/* Populations */

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Denominator Exclusion: Frailty or Advanced Illness"
  /*
  * config_link_id: exclusion_2
  */
  "HEDIS CDC1: Denominator Exclusion: Frailty or Advanced Illness"

define "Denominator Exclusion: Selected Population"
  /*
  * config_link_id: exclusion_2
  */
  AgeInYearsAt(end of "Measurement Period") >= 65
  or exists("Recent Excluded Procedure" P
    where P.prevalencePeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists("Historical Excluded Diagnosis" D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Encounter"] E
    where E.prevalencePeriod starts before end of "Measurement Period"
    and E.placeOfService = '65')
  or "IVD Exists During Measurement Period and Year Prior"
  or "Aneurysm Exists During Measurement Period and Year Prior"

define "Numerator Performance Met: Controlled HbA1c":
  /*
   * config_link_id: hba1c_controlled
   */
   exists("Last HbA1c Test" HbA1C
      where HbA1C.result < 8
        or HbA1C.code in "HEDIS; HbA1c Level Less Than 7.0")

define "Numerator Performance Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  exists("Last HbA1c Test" HbA1C
    where HbA1C.result >= 7
      or HbA1C.code in "HbA1C Result Greater or Equal to 7.0")

define "Numerator Performance Not Met: No HbA1c":
  /*
   * config_link_id: hba1c_none
   */
  not exists("HbA1c Lab Test")

define "Numerator Performance Not Met: Uncontrolled HbA1c":
  /*
  * config_link_id: hba1c_uncontrolled
  */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met: Controlled HbA1c"
  and not "Numerator Performance Not Met: High HbA1c"
  and not "Numerator Performance Not Met: No HbA1c"
