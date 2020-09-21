library HEDIS_AMR_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: AMR
 * Year: 2019
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

define "ED or Acute Inpatient No Telehealth - Current Year":
// At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth
  (["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]) Enc
    where Enc.relevantPeriod during "Measurement Period"]
      and not Enc.placeOfService in "HEDIS; Telehealth POS"
      and not Enc.code.modifier in "HEDIS; Telehealth Modifier"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; Asthma"
        )

define "ED or Acute Inpatient No Telehealth - Prior Year":
// At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth
  (["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Acute Inpatient"]) Enc
    where Enc.relevantPeriod in Interval [start of "Measurement Period" - 12 Months, start of "Measurement Period"]
      and not Enc.placeOfService in "HEDIS; Telehealth POS"
      and not Enc.code.modifier in "HEDIS; Telehealth Modifier"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; Asthma"
        )

define "Acute Inpatient, No Nonacute Inpatient - Current Year":
//•	At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth (exclude nonacute inpatient inpatient days, identify discharge date for the stay)
	["Encounter, Performed": "HEDIS; Inpatient Stay"] AcuteEnc
    where AcuteEnc.dischargeDate during "Measurement Period"
    and not "Nonacute Inpatient Visit"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; Asthma"
        )

define "Acute Inpatient, No Nonacute Inpatient - Prior Year":
//•	At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth (exclude nonacute inpatient inpatient days, identify discharge date for the stay)
	["Encounter, Performed": "HEDIS; Inpatient Stay"] AcuteEnc
    where AcuteEnc.dischargeDate during Interval [start of "Measurement Period" - 12 months, start of "Measurement Period"]
    and not "Nonacute Inpatient Visit"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; Asthma"
        )

define "Nonacute Inpatient Visit":
	exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
		with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
			such that Inpatient.claimId = Nonacute.claimId
	)

define "Outpatient Visit without Telehealth":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]) Enc
    where not Enc.placeOfService in "HEDIS; Telehealth POS"
			and not Enc.code.modifier in "HEDIS; Telehealth Modifier"

define "Outpatient Telehealth Visit":
  (["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]) Enc
    where Enc.placeOfService in "HEDIS; Telehealth POS"
			or Enc.code.modifier in "HEDIS; Telehealth Modifier"]

define "Outpatient Visits Current Year"
  "Outpatient Visit without Telehealth"
  union "Outpatient Telehealth Visit") OPVisit
    where OPVisit.relevantPeriod during during "Measurement Period"
    with(["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during OPVisit.relevantPeriod)

define "Outpatient Visits Prior Year":
  ("Outpatient Visit without Telehealth"
  union "Outpatient Telehealth Visit") OPVisit
    where OPVisit.relevantPeriod during during Interval [start of "Measurement Period" -12 months, start of "Measurement Period"]
    with(["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during OPVisit.relevantPeriod)

define "At Least Two Dispensing Events Current Year":
// Needed to ensure that outpatient encounters also have had 2 or more dispensing events
  count("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period") >=2

define "At Least Two Dispensing Events Prior Year":
// Needed to ensure that outpatient encounters also have had 2 or more dispensing events
  count("Asthma Medication" M
    where M.relevantPeriod starts during Interval [start of "Measurement Period" - 12 Months, start of "Measurement Period"]) >=2

define "At Least Four Dispensing Events - Current Year":
//to meet one definition of persistent asthma
  count("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period") >=4

define "At Least Four Dispensing Events - Prior Year":
//to meet one definition of persistent asthma
  count("Asthma Medication" M
    where M.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, start of "Measurement Period"]) >=4

define "Outpatient Asthma Visits and Dispensing Events - Current Year":
// on different dates of service; and at least two asthma medication dispensing events for any controller or reliever medication
  exists("Outpatient Visits Current Year" OPVisit1
    and exists "Outpatient Visits Current Year" OPVisit2
    and exists "Outpatient Visits Current Year" OPVisit3
    and exists "Outpatient Visits Current Year" OPVisit4
    where OPVisit1.relevantPeriod 1 day or more before OPVisit2.relevantPeriod
      and OPVisit2.relevantPeriod 1 day or more before OPVisit3.relevantPeriod
      and OPVisit3.relevantPeriod 1 day or more before OPVisit4.relevantPeriod
    and exists "Outpatient Visit without Telehealth"
    and exists "At Least Two Dispensing Events Current Year"

define "Outpatient Asthma Visits and Dispensing Events - Prior Year":
// on different dates of service; and at least two asthma medication dispensing events for any controller or reliever medication
  exists("Outpatient Visits Prior Year" OPVisit1
    and exists "Outpatient Visits Prior Year" OPVisit2
    and exists "Outpatient Visits Prior Year" OPVisit3
    and exists "Outpatient Visits Prior Year" OPVisit4
    where OPVisit1.relevantPeriod 1 day or more before OPVisit2.relevantPeriod
      and OPVisit2.relevantPeriod 1 day or more before OPVisit3.relevantPeriod
      and OPVisit3.relevantPeriod 1 day or more before OPVisit4.relevantPeriod
    and exists "Outpatient Visit without Telehealth"
    and exists "At Least Two Dispensing Events Prior Year"

define "Persistent Asthma Current Year":
  "ED or Acute Inpatient No Telehealth - Current Year"
  union "Acute Inpatient, No Nonacute Inpatient - Current Year"
  union "Outpatient Asthma Visits and Dispensing Events - Current Year"
  union "At Least Four Dispensing Events - Current Year"
  union "Four Leukotriene Modifiers or Antibody Inhibitors Medications in Current Year"

define "Persistent Asthma Prior Year"
    "ED or Acute Inpatient No Telehealth - Prior Year"
    union "Acute Inpatient, No Nonacute Inpatient - Prior Year"
    union "Outpatient Asthma Visits and Dispensing Events - Prior Year"
    union "At Least Four Dispensing Events - Prior Year"
    union "Four Leukotriene Modifiers or Antibody Inhibitors Medications in Prior Year"

define "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Current Year":
// A member identified as having persistent asthma because of at least four asthma medication dispensing events, where leukotriene modifiers or antibody inhibitors were the sole asthma medication dispensed in that year, must also have at least one diagnosis of asthma (Asthma Value Set), in any setting, in the same year as the leukotriene modifier or antibody inhibitor (i.e., the measurement year or the year prior to the measurement year).
  count("Controller Leukotriene Modifiers or Antibody Inhibitors" M
    where M.relevantPeriod starts during "Measurement Period"
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during "Measurement Period") >= 4

define "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Prior Year":
// A member identified as having persistent asthma because of at least four asthma medication dispensing events, where leukotriene modifiers or antibody inhibitors were the sole asthma medication dispensed in that year, must also have at least one diagnosis of asthma (Asthma Value Set), in any setting, in the same year as the leukotriene modifier or antibody inhibitor (i.e., the measurement year or the year prior to the measurement year).
  count("Controller Leukotriene Modifiers or Antibody Inhibitors" M
    where M.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period" - 12 months]
    without "Non-Leukotriene Modifiers or Antibody Inhibitors") >= 4
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period" - 12 months]) >= 4

define "Controller Leukotriene Modifiers or Antibody Inhibitors":
  ["Medication, Dispensed": "NCQA; Omalizumab Medications"]
  union ["Medication, Dispensed": "NCQA; Montelukast Medications"]
  union ["Medication, Dispensed": "NCQA; Zafirlukast Medications"]
  union ["Medication, Dispensed": "NCQA; Zileuton Medications"]

define "Other Controller Meds"
  ["Medication, Dispensed": "NCQA; Dyphylline Guaifenesin Medications"]
  union ["Medication, Dispensed": "NCQA; Budesonide Formoterol Medications"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Salmeterol Medications"]
  union ["Medication, Dispensed": "NCQA; Beclomethasone Medications"]
  union ["Medication, Dispensed": "NCQA; Ciclesonide Medications"]
  union ["Medication, Dispensed": "NCQA; Flunisolide Medications"]
  union ["Medication, Dispensed": "NCQA; Mometasone Medications"]
  union ["Medication, Dispensed": "NCQA; Theophylline Medications"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Vilanterol Medications"]
  union ["Medication, Dispensed": "NCQA; Formoterol Mometasone Medications"]
  union ["Medication, Dispensed": "NCQA; Budesonide Medications"]
  union ["Medication, Dispensed": "NCQA; Fluticasone Medications"]

define "Reliever Meds"
  ["Medication, Dispensed": "NCQA; Albuterol Medications"]
  union ["Medication, Dispensed": "NCQA; Levalbuterol Medications"]

define "Non-Leukotriene Modifiers or Antibody Inhibitors"
  "Other Controller Meds"
  and "Reliever Meds"

define "Asthma Medication"
  "Controller Leukotriene Modifiers or Antibody Inhibitors"
  union "Non-Leukotriene Modifiers or Antibody Inhibitors"

define "Excluded Condition":
  ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Other Emphysema"]
  union ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Obstructive Chronic Bronchitis"]
  union ["Diagnosis": "HEDIS; Chronic Respiratory Conditions Due to Fumes/Vapors"]
  union ["Diagnosis": "HEDIS; Cystic Fibrosis"]
  union ["Diagnosis": "HEDIS; Acute Respiratory Failure"]

define "Asthma Controller Quantity":
  ("Controller Leukotriene Modifiers or Antibody Inhibitors"
  union "Other Controller Meds") M
    where M.relevantPeriod starts during "Measurement Period"
    return M.quantity

define "All Asthma Medication Quantity":
// Captures all controller and reliever medications
  "Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period"
    return M.quantity

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 5
  and AgeInYearsAt(end of "Measurement Period") < 65
  and "Persistent Asthma Current Year"
  and "Persistent Asthma Prior Year"

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
  not exists("Asthma Medication" M
    where M.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  Round(Sum("Asthma Controller Quantity") / Sum("All Asthma Medication Quantity")) >= 0.5

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Hospice"
  and not "Denominator Exclusion: Condition"
  and not "Denominator Exclusion: No Medication"
  and not "Numerator Performance Met"
