library HEDIS_MMA1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: MMA1
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Asthma": '2.16.840.1.113883.3.464.1004.1025'
valueset "HEDIS; Emphysema": '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; Other Emphysema": '2.16.840.1.113883.3.464.1004.1200'
valueset "HEDIS; COPD": '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; Obstructive Chronic Bronchitis": '2.16.840.1.113883.3.464.1004.1193'
valueset "HEDIS; Chronic Respiratory Conditions Due to Fumes/Vapors": '2.16.840.1.113883.3.464.1004.1063'
valueset "HEDIS; Cystic Fibrosis": '2.16.840.1.113883.3.464.1004.1068'
valueset "HEDIS; Acute Respiratory Failure": '2.16.840.1.113883.3.464.1004.1019'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'

// NCQA medication list value sets

valueset "NCQA; Dyphylline Guaifenesin Medications"
valueset "NCQA; Budesonide Formoterol Medications"
valueset "NCQA; Fluticasone Salmeterol Medications"
valueset "NCQA; Beclomethasone Medications"
valueset "NCQA; Ciclesonide Medications"
valueset "NCQA; Flunisolide Medications"
valueset "NCQA; Mometasone Medications"
valueset "NCQA; Theophylline Medications"
valueset "NCQA; Fluticasone Vilanterol Medications"
valueset "NCQA; Formoterol Mometasone Medications"
valueset "NCQA; Budesonide Medications"
valueset "NCQA; Fluticasone Medications"
valueset "NCQA; Levalbuterol Medications"
valueset "NCQA; Albuterol Medications"
valueset "NCQA; Omalizumab Medications"
valueset "NCQA; Montelukast Medications"
valueset "NCQA; Zafirlukast Medications"
valueset "NCQA; Zileuton Medications"
valueset "NCQA; Benralizumab Medications"
valueset "NCQA; Mepolizumab Medications"
valueset "NCQA; Reslizumab Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Excluded Condition":
  ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Other Emphysema"]
  union ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Obstructive Chronic Bronchitis"]
  union ["Diagnosis": "HEDIS; Chronic Respiratory Conditions Due to Fumes/Vapors"]
  union ["Diagnosis": "HEDIS; Cystic Fibrosis"]
  union ["Diagnosis": "HEDIS; Acute Respiratory Failure"]

define "Asthma Controller Medication in Measurement Period":
  (["Medication, Dispensed": "NCQA; Dyphylline Guaifenesin Medications"]
  union ["Medication, Dispensed": "NCQA; Budesonide Formoterol Medications"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Salmeterol Medications"]
  union ["Medication, Dispensed": "NCQA; Beclomethasone Medications"]
  union ["Medication, Dispensed": "NCQA; Ciclesonide Medications"]
  union ["Medication, Dispensed": "NCQA; Flunisolide Medications"]
  union ["Medication, Dispensed": "NCQA; Mometasone Medications"]
  union ["Medication, Dispensed": "NCQA; Theophylline Medications"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Vilanterol Medications"]
  union ["Medication, Dispensed": "NCQA; Formoterol Mometasone Medications"]
  union ["Medication, Dispensed": "NCQA; Budesonide Medication"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Medications"]
  union ["Medication, Dispensed": "NCQA; Omalizumab Medications"]
  union ["Medication, Dispensed": "NCQA; Montelukast Medications"]
  union ["Medication, Dispensed": "NCQA; Zafirlukast Medications"]
  union ["Medication, Dispensed": "NCQA; Zileuton Medications"]
  union ["Medication, Dispensed": "NCQA; Benralizumab Medications"]
  union ["Medication, Dispensed": "NCQA; Mepolizumab Medications"]
  union ["Medication, Dispensed": "NCQA; Reslizumab Medications"]) ControllerMedication
    where ControllerMedication.relevantDatetime starts during "Measurement Period"

define "First Asthma Controller Medication in Measurement Period":
  First("Asthma Controller Medication in Measurement Period" FirstDispensed
    sort by start of FirstDispensed.relevantDatetime asc)
    return start of FirstDispensed.relevantPeriod

define "Treatment Period":
  ["First Asthma Controller Medication in Measurement Period", end of "Measurement Period"]

/* Populations */

define "Denominator":
  "HEDIS AMR: Denominator"

define "Exclusion: Hospice":
  /*
  * config_link_id: exclusion_required_hospice
  */
  exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Condition":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Excluded Condition"] D
    where D.prevalencePeriod starts before end of "Measurement Period")


define "Denominator Exclusion: No Medication":
  /*
   * config_link_id: exclusion_2
   */
  "HEDIS AMR: Denominator Exclusion: No Medication"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  ////CMD = Sum of each calculated interval returned based on relevantPeriods in "Controllers Dispensed Relevant Periods"

  Round("CumulativeDuration"("Asthma Controller Medication in Measurement Period","Measurement Period") / "Treatment Period") >= 0.5

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: No Medication"
  and not "Numerator Performance Met"
