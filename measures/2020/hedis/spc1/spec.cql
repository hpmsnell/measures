library HEDIS_SPC1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPC1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared


// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Inpatient Stay":
valueset "HEDIS; Telephone Visits":
valueset "HEDIS; Online Assessments":
valueset "HEDIS; IVD":
valueset "HEDIS; CABG":
valueset "HEDIS; PCI":
valueset "HEDIS; Other Revascularization":
valueset "HEDIS; ESRD":
valueset "HEDIS; Cirrhosis":
valueset "HEDIS; Pregnancy":
valueset "HEDIS; IVF":
valueset "HEDIS; MI":
valueset "HEDIS; Muscular Pain and Disease":
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"

// NCQA medication list value sets

valueset "NCQA; High and Moderate-Intensity Statin Medications"
valueset "NCQA; Estrogen Agonists Medications":

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

define "IVD Encounter":
  ["Encounter, Performed": "HEDIS: Outpatient"]
  union ["Encounter, Performed": "HEDIS: Telephone Visits"]
  union ["Encounter, Performed": "HEDIS: Online Assessments"]
  union ["Encounter, Performed": "HEDIS: Acute Inpatient"] E
    where E.placeOfService not in ['02']
      and E.code.modifier not in ['95', 'GT']

define "Non-TelehealthIVD Encounter":
  ["Encounter, Performed": "HEDIS: Outpatient"]
  union ["Encounter, Performed": "HEDIS: Acute Inpatient"] E

define "IVD Exists":
  exists("IVD Encounter" E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  and exists("IVD Encounter" E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  and exists("Non-Telehealth IVD Encounter" E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", end of "Measurement Period"]
      and E.placeOfService not in ['02']
      and E.code.modifier not in ['95', 'GT']
    with ["Diagnosis": "HEDIS; IVD"] D
      such that D.prevalencePeriod starts during E.relevantPeriod))

define "Cardiovascular Procedure":
  ["Procedure, Performed": "HEDIS; PCI"]
  union ["Procedure, Performed": "HEDIS; CABG"]
  union ["Procedure, Performed": "HEDIS; Other Revascularization"]

define "Cardiovascular Event Exists":
  exists("Cardiovascular Procedure" P
    where P.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"])
  or exists(["Encounter, Performed": "Inpatient Stay"] E
    where E.relevantPeriod starts during [12 months before start of "Measurement Period", 12 months before end of "Measurement Period"]
    with ["Diagnosis": "HEDIS: MI"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Kidney/Liver Disease":
  ["Diagnosis": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Diagnosis": "HEDIS; Cirrhosis"]


/* Populations */


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
     AgeInYearsAt(end of "Measurement Period") >= 66
     and (
        "LTI During Period"("Measurement Period")
        or "SNP"
     )
   )
   or (
     AgeInYearsAt(end of "Measurement Period") >= 66
     and (
        "LTI During Period"("Measurement Period")
        or "SNP"
        or ("Advanced Illness"("Measurement Period and Year Prior")
             and ("Frailty: Claim During Period"("Measurement Period")))
     )
   )

define "Denominator":
  (
    (
      "Patient Characteristic Sex" = 'Female'
      and AgeInYearsAt(end of "Measurement Period") >= 40
      and AgeInYearsAt(end of "Measurement Period") < 75
    or (
      "Patient Characteristic Sex" = 'Male'
      and AgeInYearsAt(end of "Measurement Period") >= 21
      and AgeInYearsAt(end of "Measurement Period") < 75
    )
  )
  and (
    "Cardiovascular Event Exists"
    or "IVD Exists"
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


define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Medication, Dispensed": "NCQA; High and Moderate-Intensity Statin Medications"] M
    where M.relevantPeriod starts during "Measurment Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Frailty and Advanced Illness"
  and not "Numerator Performance Met"
