library HEDIS_AMR5_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: AMR5
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
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

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Acute Inpatient No Telehealth":
// At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth
  ["Encounter, Performed": "HEDIS; Acute Inpatient"] Enc
    where Enc.relevantPeriod in Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"
      and not Enc.placeOfService in "HEDIS; Telehealth POS"
      and not Enc.code.modifier in "HEDIS; Telehealth Modifier"

define "Acute Inpatient, No Nonacute Inpatient":
//•	At least one acute inpatient encounter (Acute Inpatient Value Set), with a principal diagnosis of asthma (Asthma Value Set) without telehealth (exclude nonacute inpatient inpatient days, identify discharge date for the stay)
	["Encounter, Performed": "HEDIS; Inpatient Stay"] AcuteEnc
    where AcuteEnc.dischargeDate during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"
    and not "Nonacute Inpatient Visit"

define "Nonacute Inpatient Visit":
	exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] Inpatient
		with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
			such that Inpatient.claimId = Nonacute.claimId
		where Inpatient.dischargeDate during "Measurement Period"
		)

define "All Acute Inpatient Encounters":
  "Acute Inpatient No Telehealth"
  union "Acute Inpatient, No Nonacute Inpatient"

define "Inpatient or ED Visit":
  (["Encounter, Performed": "HEDIS; ED"]
  union "All Inpatient Encounters") IpEDEnc
    where IpEDEnc.relevantPeriod ends during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"

define "All Inpatient or ED Visits with Principal Diagnosis Asthma During Qualifying Period":
// Intended to capture encounter-specific diagnosis that is of highest of importance (i.e., principal diagnosis) during the encounter types detailed
  ("Inpatient or ED Visit"
  union "All Acute Inpatient Encounters") E
    where exists(E.Diagnosis Dx
      where Dx.rank = 1
        and (Dx.code in "HEDIS; Asthma"
        )
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

define "Outpatient Visit without Telehealth: >=4 Qualifying Visits":
  count("Outpatient Visit without Telehealth" NonTelehealthEnc
    where NonTelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during NonTelehealthEnc.relevantPeriod) >= 4

define "Outpatient Visit without Telehealth: >=3 Qualifying Visits":
  count("Outpatient Visit without Telehealth" NonTelehealthEnc
    where NonTelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during NonTelehealthEnc.relevantPeriod) >= 3

define "Outpatient Visit without Telehealth: >=2 Qualifying Visits":
  count("Outpatient Visit without Telehealth" NonTelehealthEnc
    where NonTelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during NonTelehealthEnc.relevantPeriod) >= 2

define "Outpatient Visit without Telehealth: >=1 Qualifying Visit":
  count("Outpatient Visit without Telehealth" NonTelehealthEnc
    where NonTelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during NonTelehealthEnc.relevantPeriod) >= 1

define "Outpatient Telehealth Visit: >= 3 Qualifying Visits"
  count("Outpatient Telehealth Visit" TelehealthEnc
    where TelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during TelehealthEnc.relevantPeriod) >= 3

define "Outpatient Telehealth Visit: >=2 Qualifying Visits"
  count("Outpatient Telehealth Visit" TelehealthEnc
    where TelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during TelehealthEnc.relevantPeriod) >= 2

define "Outpatient Telehealth Visit: >=1 Qualifying Visit"
  count("Outpatient Telehealth Visit" TelehealthEnc
    where TelehealthEnc.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Asthma"] D
      such that D.prevalencePeriod starts during TelehealthEnc.relevantPeriod) >= 1

define "Qualifying Outpatient Visits":
// Only three of the min of four visits may be an outpatient telehealth visit, a telephone visit or an online assessment
  "Outpatient Visit without Telehealth: >=4 Qualifying Visits"
  or ("Outpatient Visit without Telehealth: >=3 Qualifying Visits"
    and "Outpatient Telehealth Visit: >=1 Qualifying Visit")
  or ("Outpatient Visit without Telehealth: >=2 Qualifying Visits"
    and "Outpatient Telehealth Visit: >=2 Qualifying Visits")
  or ("Outpatient Visit without Telehealth: >=1 Qualifying Visits"
    and "Outpatient Telehealth Visit: >=3 Qualifying Visits")

define "At Least Two Dispensing Events":
// Needed to ensure that outpatient encounters also have had 2 or more dispensing events within two year window
  count("Asthma Medication" M
    where M.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]) >=2

define "At Least Four Dispensing Events":
//to meet one definition of persistent asthma
  count("Asthma Medication" M
    where M.relevantPeriod starts during Interval [start of "Measurement Period" - 12 months, end of "Measurement Period"]) >=4

define "Qualifying Outpatient Visits with Different Days":
// on different dates of service; and at least two asthma medication dispensing events for any controller or reliever medication
  exists("Qualifying Outpatient Visits" OPVisit1
    and exists "Qualifying Outpatient Visits" OPVisit2
    and exists "Qualifying Outpatient Visits" OPVisit3
    and exists "Qualifying Outpatient Visits" OPVisit4
    where OPVisit1.relevantPeriod 1 day or more before OPVisit2.relevantPeriod
      and OPVisit2.relevantPeriod 1 day or more before OPVisit3.relevantPeriod
      and OPVisit3.relevantPeriod 1 day or more before OPVisit4.relevantPeriod)
    and exists "At Least Two Dispensing Events"

define "Persistent Asthma Criteria":
  "Qualifying Outpatient Visits with Different Days"
  union "All Inpatient or ED Visits with Principal Diagnosis Asthma During Qualifying Period"
  union "At Least Four Dispensing Events"
  union "Four Leukotriene Modifiers or Antibody Inhibitors Medications: Persistent"

define "Persistent Asthma"
  exists ("Persistent Asthma Criteria" PAsthma1
    and exists "Persistent Asthma Criteria" PAsthma2
    where PAsthma1.relevantPeriod during "Measurement Period"
    and PAsthma2.relevantPeriod during Interval [start of "Measurement Period" - 12 months, end of end of "Measurement Period" - 12 months])

define "Four Leukotriene Modifiers or Antibody Inhibitors Medications: Persistent":
  "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Measurement Period"
  union "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Prior Year"

define "Four Asthma Medications: Leukotriene Modifiers or Antibody Inhibitors in Measurement Period":
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
  and "Persistent Asthma"

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
   * config_link_id: exclusion_1
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
