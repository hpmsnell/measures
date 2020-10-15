library HEDIS_AMR_2020

/*
 *
 * Source: HEDIS
 * ID: AMR
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using ADM v1

include "../shared/hedis_shared"  called HedisShared

// HEDIS value sets
valueset "HEDIS; ACUTE_INPATIENT":  '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; ACUTE_RESPIRATORY_FAILURE":  '2.16.840.1.113883.3.464.1004.1019'
valueset "HEDIS; ASTHMA":  '2.16.840.1.113883.3.464.1004.1025'
valueset "HEDIS; CHRONIC_RESPIRATORY_CONDITIONS_DUE_TO_FUMES_OR_VAPORS":  '2.16.840.1.113883.3.464.1004.1063'
valueset "HEDIS; COPD":  '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; CYSTIC_FIBROSIS":  '2.16.840.1.113883.3.464.1004.1068'
valueset "HEDIS; ED":  '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; EMPHYSEMA":  '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; HOSPICE_ENCOUNTER":  '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; HOSPICE_INTERVENTION":  '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; INPATIENT_STAY":  '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; NONACUTE_INPATIENT_STAY":  '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; OBSERVATION":  '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; OBSTRUCTIVE_CHRONIC_BRONCHITIS":  '2.16.840.1.113883.3.464.1004.1193'
valueset "HEDIS; ONLINE_ASSESSMENTS":  '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; OTHER_EMPHYSEMA":  '2.16.840.1.113883.3.464.1004.1200'
valueset "HEDIS; OUTPATIENT":  '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; TELEHEALTH_MODIFIER":  '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; TELEHEALTH_POS":  '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; TELEPHONE_VISITS":  '2.16.840.1.113883.3.464.1004.1246'


// NCQA medication list value sets

valueset "NCQA; DYPHYLLINE_GUAIFENESIN_MEDICATIONS"
valueset "NCQA; BUDESONIDE_FORMOTEROL_MEDICATIONS"
valueset "NCQA; FLUTICASONE_SALMETEROL_MEDICATIONS"
valueset "NCQA; BECLOMETHASONE_MEDICATIONS"
valueset "NCQA; CICLESONIDE_MEDICATIONS"
valueset "NCQA; FLUNISOLIDE_MEDICATIONS"
valueset "NCQA; MOMETASONE_MEDICATIONS"
valueset "NCQA; THEOPHYLLINE_MEDICATIONS"
valueset "NCQA; FLUTICASONE_VILANTEROL_MEDICATIONS"
valueset "NCQA; FORMOTEROL_MOMETASONE_MEDICATIONS"
valueset "NCQA; BUDESONIDE_MEDICATIONS"
valueset "NCQA; FLUTICASONE_MEDICATIONS"
valueset "NCQA; LEVALBUTEROL_MEDICATIONS"
valueset "NCQA; ALBUTEROL_MEDICATIONS"
valueset "NCQA; OMALIZUMAB_MEDICATIONS"
valueset "NCQA; MONTELUKAST_MEDICATIONS"
valueset "NCQA; ZAFIRLUKAST_MEDICATIONS"
valueset "NCQA; ZILEUTON_MEDICATIONS"

valueset "NCQA; Benralizumab Medications" // plcnotused
valueset "NCQA; Mepolizumab Medications" // plcnotused
valueset "NCQA; Reslizumab Medications" // plcnotused

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Inital Population":
AgeInYearsAt(end of "Measurement Period") >= 5
and AgeInYearsAt(end of "Measurement Period") < 65

define "Denominator":
  "Inital Population"
  and "Persistent Asthma Current Year"
  and "Persistent Asthma Prior Year"

define "Exclusion: Hospice":
  /*
  * Option ID: exclusion_required_hospice
  */
  exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Condition":
  /*
   * Option ID: exclusion_excluded_conditions
   */
  exists(["Excluded Condition"] D
    where D.start_date before end of "Measurement Period")

define "Denominator Exclusion: No Medication":
  /*
   * Option ID: exclusion_no_med
   */
  not exists("Asthma Medication" M
    where M.start_date during "Measurement Period")

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
  Round(Sum("Asthma Controller Quantity") / Sum("All Asthma Medication Quantity")) >= 0.5

// Definitions

define "ED or Acute Inpatient No Telehealth - Current Year":
// At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth
  (["Clinical Activity": "HEDIS; ED"]
  union ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"]) Enc
    where Interval[Enc.start_date, Enc.end_date] during "Measurement Period"]
      and not Enc.place_of_service in "HEDIS; TELEHEALTH_POS"
      and not Enc.code_modifier in "HEDIS; TELEHEALTH_MODIFIER"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; ASTHMA"
        )

define "ED or Acute Inpatient No Telehealth - Prior Year":
// At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth
  (["Clinical Activity": "HEDIS; ED"]
  union ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"]) Enc
    where Enc.relevantPeriod in Interval [start of "Measurement Period" - 12 Months, start of "Measurement Period"]
      and not Enc.place_of_service in "HEDIS; TELEHEALTH_POS"
      and not Enc.code_modifier in "HEDIS; TELEHEALTH_MODIFIER"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; ASTHMA"
        )

define "Acute Inpatient, No Nonacute Inpatient - Current Year":
//•	At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth (exclude nonacute inpatient inpatient days, identify discharge date for the stay)
	["Clinical Activity": "HEDIS; INPATIENT_STAY"] AcuteEnc
    where AcuteEnc.dischargeDate during "Measurement Period"
    and not "Nonacute Inpatient Visit"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; ASTHMA"
        )

define "Acute Inpatient, No Nonacute Inpatient - Prior Year":
//•	At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth (exclude nonacute inpatient inpatient days, identify discharge date for the stay)
	["Clinical Activity": "HEDIS; INPATIENT_STAY"] AcuteEnc
    where AcuteEnc.dischargeDate during Interval [start of "Measurement Period" - 12 months, start of "Measurement Period"]
    and not "Nonacute Inpatient Visit"
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; ASTHMA"
        )

define "Nonacute Inpatient Visit":
	exists(["Clinical Activity": "HEDIS; INPATIENT_STAY"] Inpatient
		with ["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"] Nonacute
			such that Inpatient.claimId = Nonacute.claimId
	)

define "Outpatient Visit without Telehealth":
  (["Clinical Activity": "HEDIS; OUTPATIENT"]
  union ["Clinical Activity": "HEDIS; OBSERVATION"]) Enc
    where not Enc.place_of_service in "HEDIS; TELEHEALTH_POS"
			and not Enc.code_modifier in "HEDIS; TELEHEALTH_MODIFIER"

define "Outpatient Telehealth Visit":
  (["Clinical Activity": "HEDIS; OUTPATIENT"]
  union ["Clinical Activity": "HEDIS; OBSERVATION"]
  union ["Clinical Activity": "HEDIS; TELEPHONE_VISITS"]
  union ["Clinical Activity": "HEDIS; ONLINE_ASSESSMENTS"]) Enc
    where Enc.place_of_service in "HEDIS; TELEHEALTH_POS"
			or Enc.code_modifier in "HEDIS; TELEHEALTH_MODIFIER"]

define "Outpatient Visits Current Year"
  "Outpatient Visit without Telehealth"
  union "Outpatient Telehealth Visit") OPVisit
    where Interval[OPVisit.start_date, OPVisit.end_date] during during "Measurement Period"
    with(["Diagnosis": "HEDIS; ASTHMA"] D
      such that D.start_date during OPVisit.relevantPeriod)

define "Outpatient Visits Prior Year":
  ("Outpatient Visit without Telehealth"
  union "Outpatient Telehealth Visit") OPVisit
    where Interval[OPVisit.start_date, OPVisit.end_date] during during Interval [start of "Measurement Period" -12 months, start of "Measurement Period"]
    with(["Diagnosis": "HEDIS; ASTHMA"] D
      such that D.start_date during OPVisit.relevantPeriod)

define "At Least Two Dispensing Events Current Year":
// Needed to ensure that outpatient encounters also have had 2 or more dispensing events
  count("Asthma Medication" M
    where M.start_date during "Measurement Period") >=2

define "At Least Two Dispensing Events Prior Year":
// Needed to ensure that outpatient encounters also have had 2 or more dispensing events
  count("Asthma Medication" M
    where M.start_date during Interval [start of "Measurement Period" - 12 Months, start of "Measurement Period"]) >=2

define "At Least Four Dispensing Events - Current Year":
//to meet one definition of persistent asthma
  count("Asthma Medication" M
    where M.start_date during "Measurement Period") >=4

define "At Least Four Dispensing Events - Prior Year":
//to meet one definition of persistent asthma
  count("Asthma Medication" M
    where M.start_date during Interval [start of "Measurement Period" - 12 months, start of "Measurement Period"]) >=4

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
    where M.start_date during "Measurement Period"
    with ["Diagnosis": "HEDIS; ASTHMA"] D
      such that D.start_date during "Measurement Period") >= 4

define "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Prior Year":
// A member identified as having persistent asthma because of at least four asthma medication dispensing events, where leukotriene modifiers or antibody inhibitors were the sole asthma medication dispensed in that year, must also have at least one diagnosis of asthma (Asthma Value Set), in any setting, in the same year as the leukotriene modifier or antibody inhibitor (i.e., the measurement year or the year prior to the measurement year).
  count("Controller Leukotriene Modifiers or Antibody Inhibitors" M
    where M.start_date during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period" - 12 months]
    without "Non-Leukotriene Modifiers or Antibody Inhibitors") >= 4
    with ["Diagnosis": "HEDIS; ASTHMA"] D
      such that D.start_date during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period" - 12 months]) >= 4

define "Controller Leukotriene Modifiers or Antibody Inhibitors":
  ["Medication": "NCQA; OMALIZUMAB_MEDICATIONS"]
  union ["Medication": "NCQA; MONTELUKAST_MEDICATIONS"]
  union ["Medication": "NCQA; ZAFIRLUKAST_MEDICATIONS"]
  union ["Medication": "NCQA; ZILEUTON_MEDICATIONS"]

define "Other Controller Meds"
  ["Medication": "NCQA; DYPHYLLINE_GUAIFENESIN_MEDICATIONS"]
  union ["Medication": "NCQA; BUDESONIDE_FORMOTEROL_MEDICATIONS"]
  union ["Medication": "NCQA; FLUTICASONE_SALMETEROL_MEDICATIONS"]
  union ["Medication": "NCQA; BECLOMETHASONE_MEDICATIONS"]
  union ["Medication": "NCQA; CICLESONIDE_MEDICATIONS"]
  union ["Medication": "NCQA; FLUNISOLIDE_MEDICATIONS"]
  union ["Medication": "NCQA; MOMETASONE_MEDICATIONS"]
  union ["Medication": "NCQA; THEOPHYLLINE_MEDICATIONS"]
  union ["Medication": "NCQA; FLUTICASONE_VILANTEROL_MEDICATIONS"]
  union ["Medication": "NCQA; FORMOTEROL_MOMETASONE_MEDICATIONS"]
  union ["Medication": "NCQA; BUDESONIDE_MEDICATIONS"]
  union ["Medication": "NCQA; FLUTICASONE_MEDICATIONS"]

define "Reliever Meds"
  ["Medication": "NCQA; ALBUTEROL_MEDICATIONS"]
  union ["Medication": "NCQA; LEVALBUTEROL_MEDICATIONS"]

define "Non-Leukotriene Modifiers or Antibody Inhibitors"
  "Other Controller Meds"
  and "Reliever Meds"

define "Asthma Medication"
  "Controller Leukotriene Modifiers or Antibody Inhibitors"
  union "Non-Leukotriene Modifiers or Antibody Inhibitors"

define "Excluded Condition":
  ["Diagnosis": "HEDIS; EMPHYSEMA"]
  union ["Diagnosis": "HEDIS; OTHER_EMPHYSEMA"]
  union ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; OBSTRUCTIVE_CHRONIC_BRONCHITIS"]
  union ["Diagnosis": "HEDIS; CHRONIC_RESPIRATORY_CONDITIONS_DUE_TO_FUMES_VAPORS"]
  union ["Diagnosis": "HEDIS; CYSTIC_FIBROSIS"]
  union ["Diagnosis": "HEDIS; ACUTE_RESPIRATORY_FAILURE"]

define "Asthma Controller Quantity":
  ("Controller Leukotriene Modifiers or Antibody Inhibitors"
  union "Other Controller Meds") M
    where M.start_date during "Measurement Period"
    return M.quantity

define "All Asthma Medication Quantity":
// Captures all controller and reliever medications
  "Asthma Medication" M
    where M.start_date during "Measurement Period"
    return M.quantity
