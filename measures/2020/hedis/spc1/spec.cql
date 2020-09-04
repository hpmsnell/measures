library HEDIS_SPC1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPC1
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; CABG": '2.16.840.1.113883.3.464.1004.1048'
valueset "HEDIS; Cirrhosis": '2.16.840.1.113883.3.464.1004.1379'
valueset "HEDIS; Dialysis Procedure": '2.16.840.1.113883.3.464.1004.1952'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; ESRD Diagnosis": '2.16.840.1.113883.3.464.1004.1747'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IVD": '2.16.840.1.113883.3.464.1004.1137'
valueset "HEDIS; IVF": '2.16.840.1.113883.3.464.1004.1392'
valueset "HEDIS; MI": '2.16.840.1.113883.3.464.1004.1157'
valueset "HEDIS; Muscular Pain and Disease": '2.16.840.1.113883.3.464.1004.1381'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Other Revascularization": '2.16.840.1.113883.3.464.1004.1388'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; PCI": '2.16.840.1.113883.3.464.1004.1204'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'


// NCQA medication list value sets

valueset "NCQA; Estrogen Agonists Medications":

valueset "NCQA; Atorvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1801'
valueset "NCQA; Amlodipine Atorvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1805'
valueset "NCQA; Rosuvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1803'
valueset "NCQA; Simvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1798'
valueset "NCQA; Ezetimibe Simvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1807'
valueset "NCQA; Atorvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1800'
valueset "NCQA; Amlodipine Atorvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1804'
valueset "NCQA; Rosuvastatin High Intensity Medications": '2.16.840.1.113883.3.464.1004.1803'
valueset "NCQA; Simvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1797'
valueset "NCQA; Ezetimibe Simvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1806'
valueset "NCQA; Pravastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1796'
valueset "NCQA; Lovastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1795'
valueset "NCQA; Fluvastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1799'
valueset "NCQA; Pitavastatin Moderate Intensity Medications": '2.16.840.1.113883.3.464.1004.1808'



parameter "Measurement Period" Interval<DateTime>

context Patient

define "High Intensity Statin":
  ["Medication, Dispensed": "Atorvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Amlodipine Atorvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Rosuvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Simvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Ezetimibe Simvastatin High Intensity Medications"]

define "Medium Intensity Statin":
  ["Medication, Dispensed": "Atorvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Amlodipine Atorvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Rosuvastatin High Intensity Medications"]
  union ["Medication, Dispensed": "Simvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Ezetimibe Simvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Pravastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Lovastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Fluvastatin Moderate Intensity Medications"]
  union ["Medication, Dispensed": "Pitavastatin Moderate Intensity Medications"]

define "Statin":
  ["High Intensity Statin"]
  union ["Medium Intensity Statin"]

define "IVD Encounter No Telehealth":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]
  union "Other Acute Inpatient Visit") E
    where not E.code.modifier in {'GT','95'}
      and not E.placeOfService in {'02'}


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


define "Cardiovascular Procedure":
  ["Procedure, Performed": "HEDIS; PCI"]
  union ["Procedure, Performed": "HEDIS; CABG"]
  union ["Procedure, Performed": "HEDIS; Other Revascularization"]

define "Cardiovascular Event Exists":
  exists("Cardiovascular Procedure" P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"])
  or exists(["Encounter, Performed": "Inpatient Stay"] E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"]
    and E.diagnoses D
        where D.code in "HEDIS; MI")

define "Kidney/Liver Disease":
  ["Diagnosis": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Diagnosis": "HEDIS; Cirrhosis"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Visit with Advanced Illness":
  "Visit" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Advanced Illness Exists":
  exists("Visit with Advanced Illness" E1
    with "Visit with Advanced Illness" E2
      such that E1.relevantPeriod starts after E2.relevantPeriod)
  or exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    with ["Diagnosis": "HEDIS; Advanced Illness"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or exists(["Medication, Dispensed": "NCQA; Dementia Medications"] M
    where M.relevantPeriod starts during "Measurement Period")

/* Populations */

define "Denominator":
  (
    (
      "Patient Characteristic Sex" = 'Female'
      and AgeInYearsAt(end of "Measurement Period") >= 40
      and AgeInYearsAt(end of "Measurement Period") < 75
    )
    or (
      "Patient Characteristic Sex" = 'Male'
      and AgeInYearsAt(end of "Measurement Period") >= 21
      and AgeInYearsAt(end of "Measurement Period") < 75
    )
  )
  and (
    "Cardiovascular Event Exists"
    or "IVD Exists During Measurement Period and Year Prior"
  )

define "Denominator Exclusion: Condition"
  /*
  * config_link_id: exclusion_1
  */
  exists(["Diagnosis": "HEDIS; Muscular Pain and Disease"] D
    where D.prevalencePeriod starts during "Measurement Period")
  or exists("Kidney/Liver Disease" D
    where D.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion: Pregnancy"
  /*
  * config_link_id: exclusion_2
  */
  exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])
  or exists(["Procedure, Performed": "HEDIS; IVF"] P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])
  or exists(["Medication, Dispensed": "NCQA; Estrogen Agonists Medications"] M
    where M.relevantPeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"])

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
 /*
  * config_link_id: exclusion_required_frailty
  */
  AgeInYearsAt(end of "Measurement Period") >= 66
   and ("LTI During Period"("Measurement Period")
         or "SNP"("Measurement Period")
         or ("Advanced Illness"("Measurement Period and Year Prior")
             and "Frailty: Claim During Period"("Measurement Period")
           )
     )

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Statin"] M
    where M.relevantPeriod starts during "Measurment Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Exclusion: Hospice"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
