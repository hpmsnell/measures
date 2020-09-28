library hedis_shared

/*
 *
 * Source: HEDIS
 * ID:
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

/*
Supports:
  - Hospice
  - SNP: Enrolled in an Institutional SNP (I-SNP)
  - LTI: Living long-term in an institution
  - Frailty (general without age qualification)
  - Advanced Illness
*/

using ADM v1

valueset "HEDIS; OUTPATIENT": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; NONACUTE INPATIENT": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; ACUTE INPATIENT": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; OBSERVATION": '2.16.840.1.113883.3.464.1004.1191'

valueset "HEDIS; INPATIENT STAY": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; NONACUTE INPATIENT STAY": '2.16.840.1.113883.3.464.1004.1398'

valueset "HEDIS; HOSPICE ENCOUNTER": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; HOSPICE INTERVENTION": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; WELL-CARE": '2.16.840.1.113883.3.464.1004.1262'
valueset "HEDIS; TELEHEALTH POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; TELEHEALTH MODIFIER": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; TELEPHONE VISITS": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; ADVANCED ILLNESS": '2.16.840.1.113883.3.464.1004.1465'

valueset "NCQA; DEMENTIA MEDICATIONS": '' //FIXME: add OID

valueset "HEDIS; FRAILTY DEVICE": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; FRAILTY DIAGNOSIS": '2.16.840.1.113883.3.464.1004.1531'
valueset "HEDIS; FRAILTY ENCOUNTER": '2.16.840.1.113883.3.464.1004.1532'
valueset "HEDIS; FRAILTY SYMPTOM": '2.16.840.1.113883.3.464.1004.1533'
valueset "HEDIS; PALLIATIVE_CARE_ASSESSMENT": ''
valueset "HEDIS; PALLIATIVE_CARE_ENCOUNTER": ''
valueset "HEDIS; PALLIATIVE_CARE_INTERVENTION": ''


valueset "Able; MMDF LTI": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

/*--------------------------------------------------
HOSPICE
----------------------------------------------------*/
define "Hospice":
  (["Clinical Activity": "HEDIS; Hospice Intervention"]
  union ["Clinical Activity": "HEDIS; Hospice Encounter"]) Hospice
  where Hospice.place_of_service != '81'

define function "Hospice During Period"(Period Interval<DateTime>):
  exists(
    "Hospice" H
      where H.start_date during Period
  )

/*--------------------------------------------------
SNP
–	Enrolled in an Institutional SNP (I-SNP)
----------------------------------------------------*/
define "SNP"(Period Interval<DateTime>):
  exists
    ["Payer": "ALL PAYERS"] payer //ALL payers, don't restrict by value set
    where
      payer.value = 'SN2'
      and payer.start_date <= end of Period
      and (
          payer.end_date >= start of Period
          or payer.end_date is null
        )

/*--------------------------------------------------
LTI
–	Living long-term in an institution ... as identified by the LTI flag in the Monthly Membership Detail Data File.
  Use the run date of the file to determine if a member had an LTI flag (during requested period)
----------------------------------------------------*/
define function "LTI During Period"(Period Interval<DateTime>):
  exists(
    ["Clinical Activity": "Able; MMDF LTI"] LTI
      where LTI.start_date during Period
  )


/*--------------------------------------------------
FRAILTY
----------------------------------------------------*/

define function "Frailty: Diagnosis or Symptoms During Period"(Period Interval<DateTime>):
  ((["Diagnosis": "HEDIS; Frailty Diagnosis"]
  union ["Diagnosis": "HEDIS; Frailty Symptom"]
  union ["Clinical Activity": "HEDIS; Frailty Symptom"])FrailDxSx
    where FrailDxSx.start_date during Period)
      and FrailDxSx.supplemental = false
      and FrailDxSx.place_of_service != '81'


define function "Frailty: Encounter During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; Frailty Encounter"]FrailEnc
    where Interval[FrailEnc.start_date,FrailEnc.end_date] starts during Period
      and FrailEnc.supplemental = false
      and FrailEnc.place_of_service != '81'

define function "Frailty: Device During Period"(Period Interval<DateTime>):
  (["Device, Applied": "HEDIS; Frailty Device"]
  union ["Device, Order": "HEDIS; Frailty Device"]
  union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
    where FrailDevice.start_date during Period
      and FrailDevice.supplemental = false
      and FrailDevice.place_of_service != '81'

/*
  At least one claim/encounter for frailty (Frailty Device Value Set; Frailty Diagnosis Value Set; Frailty Encounter Value Set; Frailty Symptom Value Set)
  during specified period
*/
define function "Frailty: Claim During Period"(Period Interval<DateTime>) returns Boolean:
    exists "Frailty: Diagnosis or Symptoms During Period"(Period)
    or exists "Frailty: Encounter During Period"(Period)
    or exists "Frailty: Device During Period"(Period)



/*--------------------------------------------------
ADVANCED ILLNESS
--------------------------------------------------*/

/*
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonacute inpatient encounters (Nonacute Inpatient Value Set)
- or nonacute inpatient discharges (instructions below)
... with an advanced illness diagnosis (Advanced Illness Value Set)...

To identify a nonacute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the discharge date for the stay.
----------------------------------------------------*/
define function "Advanced Illness: Visit During Period"(Period Interval<DateTime>):
    ("Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acute Inpatient Encounters"(Period))Visits
    union ("Advanced Illness: Non-Acute Inpatient DISCHARGE During Period"(Period))Visits

/*
most visits - EXCLUDING non-acute inpatient DISCHARGES
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonacute inpatient encounters (Nonacute Inpatient Value Set)
... with an advanced illness diagnosis (Advanced Illness Value Set)...
*/
define function "Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acute Inpatient Encounters"(Period Interval<DateTime>):
    //outpatient visits (Outpatient Value Set)
    //observation visits (Observation Value Set)
    //ED visits (ED Value Set)
    //nonacute inpatient encounters (Nonacute Inpatient Value Set)
    (["Clinical Activity": "HEDIS; Outpatient"]
      union ["Clinical Activity": "HEDIS; Observation"]
      union ["Clinical Activity": "HEDIS; ED"]
      union ["Clinical Activity": "HEDIS; Nonacute Inpatient"]
    ) QualifyingEncounters
      with ["Diagnosis": "HEDIS; Advanced Illness"] AdvIllness
        such that AdvIllness.claim_id = QualifyingEncounters.claim_id
        or (
          AdvIllness.claim_id = null
          and QualifyingEncounters.claim_id = null
          and QualifyingEncounters.end_date != null
          and AdvIllness.start_date during Interval[QualifyingEncounters.start_date, QualifyingEncounters.end_date]
        )
        or (
          AdvIllness.claim_id = null
          and QualifyingEncounters.claim_id = null
          and QualifyingEncounters.stop_date = null
          and AdvIllness.start_date same day as QualifyingEncounters.start_date
        )
      where QualifyingEncounters.start_date during Period
        and AdvIllness.supplemental = false
        and AdvIllness.place_of_service != '81'
        and QualifyingEncounters.supplemental = false
        and QualifyingEncounters.place_of_service != '81'

/*
To identify a nonacute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Non-Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  (
    //nonacute inpatient discharges
    ((["Clinical Activity": "HEDIS; Inpatient Stay"])Inpatient
      with (["Clinical Activity": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
        such that Inpatient.claim_id = NonacuteIPFlag.claim_id
          where Inpatient.discharge_date during Period //NOTE: we're filtering by DISCHARGE DATE here
          and Inpatient.place_of_service != '81'
      )
  ) QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] AdvIllness
    such that AdvIllness.claim_id = QualifyingEncounters.claim_id
    or (
      AdvIllness.claim_id = null
      and QualifyingEncounters.claim_id = null
      and end of QualifyingEncounters.end_date != null
      and AdvIllness.start_date during Intetrval[QualifyingEncounters.start_date , QualifyingEncounters.end_date]
    )
    or (
      D.claim_id = null
      and QualifyingEncounters.claim_id = null
      and QualifyingEncounters.stop_date = null
      and AdvIllness.start_date same day as QualifyingEncounters.start_date
    )
  where DiagAdvIllness.supplemental = false
    and DiagAdvIllness.place_of_service != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.place_of_service != '81'

/*
–	At least one acute inpatient encounter (Acute Inpatient Value Set)
  with an advanced illness diagnosis (Advanced Illness Value Set).
*/
define function "Advanced Illness: Acute Inpatient Encounter During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; Acute Inpatient"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] AdvIllness
    such that AdvIllness.claim_id = QualifyingEncounters.claim_id
    or (
      AdvIllness.claim_id = null
      and QualifyingEncounters.claim_id = null
      and QualifyingEncounters.end_date != null
      and D.start_date during Interval[QualifyingEncounters.start_date, QualifyingEncounters.end_date]
    )
    or (
      AdvIllness.claim_id = null
      and QualifyingEncounters.claim_id = null
      and QualifyingEncounters.stop_date = null
      and AdvIllness.start_date same day as QualifyingEncounters.start_date
    )
  where
    AdvIllness.supplemental = false
    and AdvIllness.place_of_service != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.start_date during Period
    and QualifyingEncounters.place_of_service != '81'

/*
//–	Acute inpatient DISCHARGE with an advanced illness diagnosis (Advanced Illness Value Set)
–	At least one acute inpatient discharge with an advanced illness diagnosis (Advanced Illness Value Set).
To identify an acute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Exclude nonacute inpatient stays (Nonacute Inpatient Stay Value Set).
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; Inpatient Stay"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] AdvIllness
    such that AdvIllness.claim_id = QualifyingEncounters.claim_id
    or (
      AdvIllness.claim_id = null
      and QualifyingEncounters.claim_id = null
      and QualifyingEncounters.end_date != null
      and AdvIllness.start_date during Interval[QualifyingEncounters.start_date,QualifyingEncounters.end_date]
    )
    or (
      AdvIllness.claim_id = null
      and QualifyingEncounters.claim_id = null
      and QualifyingEncounters.stop_date = null
      and AdvIllness.start_date same day as QualifyingEncounters.start_date
    )
  where
    AdvIllness.supplemental = false
    and AdvIllness.place_of_service != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.discharge_date during Period
    and QualifyingEncounters.place_of_service != '81'
    and not exists (
      //There will be secondary non-acute inpatient Encounters
      //we have find ONLY the encounters where there is NOT
      //a related non-acute stay on the same claim
      ["Clinical Activity": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that QualifyingEncounters.claim_id = Nonacute.claim_id
    )

/*
–	At least two outpatient visits ...
  on different dates of service, with an advanced illness diagnosis
*/
define function "Advanced Illness: Count of Distinct Visit Dates During Period"(Period Interval<DateTime>): //returns Integer:
  Count(distinct((((
       "Advanced Illness: Visit During Period"(Period)
  ).start_date)))

// A dispensed dementia medication (Dementia Medications List).
define function "Advanced Illness: Dementia Medication During Period"(Period Interval<DateTime>):
  ["Medication, Dispensed": "NCQA; Dementia Medications"] DementiaMed
  where DementiaMed.start_date during Period
    and DementiaMed.supplemental = false

define function "Advanced Illness"(Period Interval<DateTime>) returns Boolean:
    // At least two outpatient visits...
    ("Advanced Illness: Count of Distinct Visit Dates During Period"(Period)) >= 2
    // At least one acute inpatient ENCOUNTER (Acute Inpatient Value Set) with an advanced illness diagnosis (Advanced Illness Value Set).
    or exists("Advanced Illness: Acute Inpatient Encounter During Period"(Period))
    //At least one acute inpatient DISCHARGE with an advanced illness diagnosis (Advanced Illness Value Set).
    or exists ("Advanced Illness: Acute Inpatient DISCHARGE During Period"(Period))
    // A dispensed dementia medication (Dementia Medications List).
    or exists("Advanced Illness: Dementia Medication During Period"(Period))


// The following function recieves a list of medication dispensed and a period interval (measurement period, index period, treatment period)
// and returns the cumlative duration a medication has been dispensed as an Integer
// sample use would be as follows "CumulativeDuration"(medlist, Peasurement Period)

define function "CumulativeDuration"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>) returns Integer:
  Sum((collapse ("Medications Dispensed Relevant Periods"(MedsListFromSpec , Period))) X
    return all duration in days of X)


//receives medication list and period from the Medications Dispensed Relevant Periods function
define function "Medication List in Measurement Period"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
  (MedsListFromSpec) MedicationDispensedList
    where MedicationDispensedList.start_date during Period

define function "Multiple Different Medication Same Day - Longest Supply Date"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist2
    where medlist1.code != medlist2.code
    and medlist1.start_date same day as medlist2.start_date
    and medlist1.end_date 1 day or more after medlist2.end_date
  return Interval [medlist1.start_date, medlist1.end_date]
          intersect Period

define function "Multiple Different Medications Diff Day - Overlapping Supply"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        (("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
        ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist2
        	where medlist1.code != medlist2.code
          	and interval[medlist1.start_date, medlist1.end_date] overlaps Interval[medlist2.start_date,medlist2.end_date) OverlapDiffMeds
        return all Interval[OverlapDiffMeds.start_date, OverlapDiffMeds.end_date]
					intersect Period
    )

define function "Same Medication - Overlapping Supply"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for the same medication are dispensed on the same day or different days with overlapping days supply, sum the days supply and use the total to calculate the number of days covered by a medication.
  from
  (("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period))) medlist2
    where medlist1.code ~ medlist2.code
    and Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date,medlist2.end_date])OverlapSameMeds
  return all Interval[OverlapSameMeds.start_date, OverlapSameMeds.end_date]
		intersect Period

define function "Non-overlapping Medications"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
// Identifies all intervals of medications, associated with the measurement period
  collapse (( "Medication List in Measurement Period"(MedsListFromSpec , Period)) medicationperiod
      return Interval[medicationperiod.start_date, medicationperiod.end_date]
      intersect Period
      )

define function "Medications Dispensed Relevant Periods"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
    "Multiple Different Medication Same Day - Longest Supply Date"(MedsListFromSpec , Period))
    union ("Multiple Different Medications Diff Day - Overlapping Supply"(MedsListFromSpec , Period))
    union ("Same Medication - Overlapping Supply"(MedsListFromSpec , Period))
    union ("Non-overlapping Medications"(MedsListFromSpec , Period))


//valueset functions for CMD

define function "Different Medications Dispensed Relevant Periods Valuesets"(specificMedList List<"Medication, Dispensed">,totalMedList List<"Medication, Dispensed">, Period Interval<DateTime>) returns Integer:
    collapse ("Same Day Different Meds Valuesets- Longest Supply Date Interval"(specificMedList, totalMedList, Period)
      union "Different Day Different Med Overlapping Supply Valuesets- Total of Period"(specificMedList, totalMedList, Period)
    return Interval[medicationperiod.start_date, medicationperiod.end_date]
        )

define function "Same Medications Dispensed Relevant Periods Valuesets"(specificMedList List<"Medication, Dispensed">, Period Interval<DateTime>) returns Integer:
    collapse (("Same Med- Multiple intervals"(specificMedList, Period)
    return Interval[medicationperiod.start_date, medicationperiod.end_date]
        ))

define function "Same Med- Multiple intervals"(specificMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
    from
    (("Medication List in Measurement Period Valuesets"(specificMedList, Period)) medlist1,
    ("Medication List in Measurement Period Valuesets"(specificMedList, Period))) medlist2
      where Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date,medlist2.end_date]) OverlapSameMeds
    return all Interval[OverlapSameMeds.start_date,end of OverlapSameMeds.end_date]
      intersect Period


define function "Same Day Different Meds Valuesets- Longest Supply Date Interval"(specificMedList List<"Medication, Dispensed">,totalMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
  ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
    where medlist1.start_date same day as medlist2.start_date
    and medlist1.end_date 1 day or more after medlist2.end_date
  return Interval[medlist1.start_date, medlist1.end_date]
          intersect Period

define function "Different Day Different Med Overlapping Supply Valuesets- Total of Period"(specificMedList List<"Medication, Dispensed">,totalMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        (("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
        ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
          	where Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date, medlist2.end_date]) OverlapDiffMeds //plcedit
        return all Interval[OverlapDiffMeds.start_date, OverlapDiffMeds.end_date]
					intersect Period
          )


define function "Denominator Exclusion: Palliative Care"(Period Interval<DateTime>):
  exists((["Clinical Activity": "HEDIS; PALLIATIVE_CARE_ASSESSMENT"]
          union ["Clinical Activity": "HEDIS; PALLIATIVE_CARE_ENCOUNTER"]
          union ["Clinical Activity": "HEDIS; PALLIATIVE_CARE_INTERVENTION"]) PalliativeCare
    where PalliativeCare.start_date on or before end of "Period"
      and PalliativeCare.place_of_service != '81')
