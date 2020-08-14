library HEDIS_SPD1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPD1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; CABG": '2.16.840.1.113883.3.464.1004.1048'
valueset "HEDIS; Cirrhosis": '2.16.840.1.113883.3.464.1004.1379'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
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

valueset "NCQA; Estrogen Agonists Medications"
valueset "NCQA; High and Moderate-Intensity Statin Medications"
valueset "NCQA; Low-Intensity Statin Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient
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

define "Kidney/Liver Disease":
  ["Diagnosis": "HEDIS; ESRD Diagnosis"]
  union ["Procedure, Performed": "HEDIS; ESRD Diagnosis"]
  union ["Diagnosis": "HEDIS; Cirrhosis"]

define "Statin":
  ["Medication, Dispensed": "NCQA; High and Moderate-Intensity Statin Medications"]
  union ["Medication, Dispensed": "NCQA; Low-Intensity Statin Medications"]

  define "Nonacute Visit No Telehealth":
    (["Encounter, Performed": "HEDIS; Outpatient"]
    union ["Encounter, Performed": "HEDIS; Observation"]
    union ["Encounter, Performed": "HEDIS; ED"]
    union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
    union "Nonacute Inpatient Visit")E
      where E1.code.modifier != "HEDIS; Telehealth Modifier"
            and E1.placeOfService != "HEDIS; Telehealth POS"

  define "Nonacute Inpatient Visit":
    ["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
      with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
        such that Inpatient.claimId = Nonacute.claimId
        and Inpatient.placeOfService != 81
        and Nonacute.placeOfService != 81

  define "Nonacute Visit Telehealth":
    ["Encounter, Performed": "HEDIS; Telephone Visits"]
    union ["Encounter, Performed": "HEDIS Online Assessments"]
    union "Nonacute Inpatient Visit" Nonacute
      where Nonacute.code.modifier in "HEDIS; Telehealth Modifier"
        or Nonacute.placeOfService in "HEDIS; Telehealth POS"

  define "Nonacute Visit with Diabetes":
    "Nonacute Visit No Telehealth" E
      where E.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod

  define "Nonacute Visit Telehealth with Diabetes":
    "Nonacute Visit Telehealth" E
      where E.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod

  define "Patient Has Diabetes":
  // only 1 of 2 "Nonacute Visit with Diabetes" can be outpatient telehealth
    exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
      where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
        and not E.code.modifier in "HEDIS; Telehealth Modifier"
        and not E.placeOfService in "HEDIS; Telehealth POS")
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during E.relevantPeriod)
    or exists(["Encounter, Performed": "HEDIS; Inpatient Stay"])InpatientE
      where InpatientE.dischargeDate during [24 months before end of "Measurement Period", end of "Measurement Period"]
      with ["Diagnosis": "HEDIS; Diabetes"] D
        such that D.prevalencePeriod starts during InpatientE.relevantPeriod
          and InpatientE.claimId = D.claimId)
    or exists("Nonacute Visit with Diabetes" E1
      with "Nonacute Visit with Diabetes" E2
        such that start of E2.relevantPeriod != start of E1.relevantPeriod
    or exists("Nonacute Visit with Diabetes" E1
      with "Nonacute Visit Telehealth with Diabetes" E2
        such that start of E2.relevantPeriod != start of E1.relevantPeriod)
    or exists(["Medication, Dispensed": "NCQA; Diabetes Medications"] M
      where M.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

  /* Populations */

  define "Denominator":
    AgeInYearsAt(end of "Measurement Period") >= 40
    and AgeInYearsAt(end of "Measurement Period") < 76
    and "Patient Has Diabetes" //The definition of a patient with diabetes is the same as CDC1.

define "Denominator Exclusion: Condition"
  /*
  * config_link_id: exclusion_1
  */
  "IVD Exists During Measurement Period and Year Prior" // This definition of IVD is is the same as CDC3.
  or exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"]
      and E.diagnoses D
        where D.code in "HEDIS; MI")
  or exists(["Diagnosis": "HEDIS; Muscular Pain and Disease"] D
    where D.prevalencePeriod starts during "Measurement Period")
  or exists("Cardiovascular Procedure" P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"])
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


define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Statin" M
    where M.relevantPeriod starts during "Measurment Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Exclusion: Hospice"
  and not "Numerator Performance Met"
