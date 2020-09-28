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
  - ADVANCED_ILLNESS
*/

using ADM v1

valueset "HEDIS; OUTPATIENT": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; NONACUTE_INPATIENT": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; ACUTE_INPATIENT": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; OBSERVATION": '2.16.840.1.113883.3.464.1004.1191'

valueset "HEDIS; INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; NONACUTE_INPATIENT_STAY": '2.16.840.1.113883.3.464.1004.1398'

valueset "HEDIS; HOSPICE_ENCOUNTER": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; HOSPICE_INTERVENTION": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; WELL_CARE": '2.16.840.1.113883.3.464.1004.1262'
valueset "HEDIS; TELEHEALTH_POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; TELEHEALTH_MODIFIER": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; TELEPHONE_VISITS": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; ADVANCED_ILLNESS": '2.16.840.1.113883.3.464.1004.1465'

valueset "NCQA; DEMENTIA_MEDICATIONS": '2.16.840.1.113883.3.464.1004.1729'

valueset "HEDIS; FRAILTY_DEVICE": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; FRAILTY_DIAGNOSIS": '2.16.840.1.113883.3.464.1004.1531'
valueset "HEDIS; FRAILTY_ENCOUNTER": '2.16.840.1.113883.3.464.1004.1532'
valueset "HEDIS; FRAILTY_SYMPTOM": '2.16.840.1.113883.3.464.1004.1533'
valueset "HEDIS; PALLIATIVE_CARE_ASSESSMENT": ''
valueset "HEDIS; PALLIATIVE_CARE_ENCOUNTER": ''
valueset "HEDIS; PALLIATIVE_CARE_INTERVENTION": ''

valueset "Able; MMDF_LTI": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

/*--------------------------------------------------
HOSPICE
----------------------------------------------------*/
define "Hospice":
  (["Clinical Activity": "HEDIS; HOSPICE_INTERVENTION"]
  union ["Clinical Activity": "HEDIS; HOSPICE_ENCOUNTER"]) Hospice
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
    ["Payer"] payer //ALL payers, don't restrict by value set
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
    ["Clinical Activity": "Able; MMDF_LTI"] LTI
      where LTI.start_date during Period
  )


/*--------------------------------------------------
FRAILTY
----------------------------------------------------*/

define function "Frailty: Diagnosis or Symptoms During Period"(Period Interval<DateTime>):
  ((["Diagnosis": "HEDIS; FRAILTY_DIAGNOSIS"]
  union ["Diagnosis": "HEDIS; FRAILTY_SYMPTOM"]
  union ["Clinical Activity": "HEDIS; FRAILTY_SYMPTOM"])FrailDxSx
    where FrailDxSx.start_date during Period)
      and FrailDxSx.supplemental = false
      and FrailDxSx.place_of_service != '81'


define function "Frailty: Encounter During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; FRAILTY_ENCOUNTER"]FrailEnc
    where Interval[FrailEnc.start_date,FrailEnc.end_date] starts during Period
      and FrailEnc.supplemental = false
      and FrailEnc.place_of_service != '81'

define function "Frailty: Device During Period"(Period Interval<DateTime>):
  (["Device, Applied": "HEDIS; FRAILTY_DEVICE"]
  union ["Device, Order": "HEDIS; FRAILTY_DEVICE"]
  union ["Device, Recommended": "HEDIS; FRAILTY_DEVICE"])FrailDevice
    where FrailDevice.start_date during Period
      and FrailDevice.supplemental = false
      and FrailDevice.place_of_service != '81'

/*
  At least one claim/encounter for frailty (FRAILTY_DEVICE Value Set; FRAILTY_DIAGNOSIS Value Set; FRAILTY_ENCOUNTER Value Set; FRAILTY_SYMPTOM Value Set)
  during specified period
*/
define function "Frailty: Claim During Period"(Period Interval<DateTime>) returns Boolean:
    exists "Frailty: Diagnosis or Symptoms During Period"(Period)
    or exists "Frailty: Encounter During Period"(Period)
    or exists "Frailty: Device During Period"(Period)



/*--------------------------------------------------
ADVANCED_ILLNESS
--------------------------------------------------*/

/*
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonACUTE_INPATIENT encounters (NonACUTE_INPATIENT Value Set)
- or nonACUTE_INPATIENT discharges (instructions below)
... with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set)...

To identify a nonACUTE_INPATIENT discharge:
1.	Identify all acute and NONACUTE_INPATIENT_STAYs (INPATIENT_STAY Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (NONACUTE_INPATIENT_STAY Value Set) on the claim.
3.	Identify the discharge date for the stay.
----------------------------------------------------*/
define function "Advanced Illness: Visit During Period"(Period Interval<DateTime>):
    ("Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acute Inpatient Encounters"(Period))Visits
    union ("Advanced Illness: Non-Acute Inpatient Discharge During Period"(Period))Visits

/*
most visits - EXCLUDING non-ACUTE_INPATIENT DISCHARGES
–	outpatient visits (Outpatient Value Set), observation visits (Observation Value Set),
- ED visits (ED Value Set),
- nonACUTE_INPATIENT encounters (NonACUTE_INPATIENT Value Set)
... with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set)...
*/
define function "Advanced Illness: Visit During Period - Outpatient, Obs, ED, Non-Acure Inpatient Encounters"(Period Interval<DateTime>):
    //outpatient visits (Outpatient Value Set)
    //observation visits (Observation Value Set)
    //ED visits (ED Value Set)
    //nonACUTE_INPATIENT encounters (NonACUTE_INPATIENT Value Set)
    (["Clinical Activity": "HEDIS; OUTPATIENT"]
      union ["Clinical Activity": "HEDIS; OBSERVATION"]
      union ["Clinical Activity": "HEDIS; ED"]
      union ["Clinical Activity": "HEDIS; NONACUTE_INPATIENT"]
    ) QualifyingEncounters
      with ["Diagnosis": "HEDIS; ADVANCED_ILLNESS"] AdvIllness
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
To identify a nonACUTE_INPATIENT discharge:
1.	Identify all acute and NONACUTE_INPATIENT_STAYs (INPATIENT_STAY Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (NONACUTE_INPATIENT_STAY Value Set) on the claim.
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Non-Acute Inpatient Discharge During Period"(Period Interval<DateTime>):
  (
    //nonACUTE_INPATIENT discharges
    ((["Clinical Activity": "HEDIS; INPATIENT_STAY"])Inpatient
      with (["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"])NonacuteIPFlag
        such that Inpatient.claim_id = NonacuteIPFlag.claim_id
          where Inpatient.discharge_date during Period //NOTE: we're filtering by DISCHARGE DATE here
          and Inpatient.place_of_service != '81'
      )
  ) QualifyingEncounters
  with ["Diagnosis": "HEDIS; ADVANCED_ILLNESS"] AdvIllness
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
–	At least one ACUTE_INPATIENT encounter (ACUTE_INPATIENT Value Set)
  with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set).
*/
define function "Advanced Illness: Acute Inpatient Encounter During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; ACUTE_INPATIENT"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; ADVANCED_ILLNESS"] AdvIllness
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
//–	ACUTE_INPATIENT DISCHARGE with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set)
–	At least one ACUTE_INPATIENT discharge with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set).
To identify an ACUTE_INPATIENT discharge:
1.	Identify all acute and NONACUTE_INPATIENT_STAYs (INPATIENT_STAY Value Set).
2.	Exclude NONACUTE_INPATIENT_STAYs (NONACUTE_INPATIENT_STAY Value Set).
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Acute Inpatient Discharge During Period"(Period Interval<DateTime>):
  ["Clinical Activity": "HEDIS; INPATIENT_STAY"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; ADVANCED_ILLNESS"] AdvIllness
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
      //There will be secondary non-ACUTE_INPATIENT Encounters
      //we have find ONLY the encounters where there is NOT
      //a related non-acute stay on the same claim
      ["Clinical Activity": "HEDIS; NONACUTE_INPATIENT_STAY"] Nonacute
      such that QualifyingEncounters.claim_id = Nonacute.claim_id
    )

/*
–	At least two outpatient visits ...
  on different dates of service, with an ADVANCED_ILLNESS diagnosis
*/
define function "Advanced Illness: Count of Distinct Visit Dates During Period"(Period Interval<DateTime>): //returns Integer:
  Count(distinct((((
       "Advanced Illness: Visit During Period"(Period)
  ).start_date)))

// A dispensed dementia medication (DEMENTIA_MEDICATIONS List).
define function "Advanced Illness: Dementia Medication During Period"(Period Interval<DateTime>):
  ["Medication": "NCQA; DEMENTIA_MEDICATIONS"] DementiaMed
  where DementiaMed.start_date during Period
    and DementiaMed.supplemental = false
    and DementiaMed.dispensed = true

define function "Advanced Illness"(Period Interval<DateTime>) returns Boolean:
    // At least two outpatient visits...
    ("Advanced Illness: Count of Distinct Visit Dates During Period"(Period)) >= 2
    // At least one ACUTE_INPATIENT ENCOUNTER (ACUTE_INPATIENT Value Set) with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set).
    or exists("Advanced Illness: ACUTE_INPATIENT Encounter During Period"(Period))
    //At least one ACUTE_INPATIENT DISCHARGE with an ADVANCED_ILLNESS diagnosis (ADVANCED_ILLNESS Value Set).
    or exists ("Advanced Illness: ACUTE_INPATIENT DISCHARGE During Period"(Period))
    // A dispensed dementia medication (DEMENTIA_MEDICATIONS List).
    or exists("Advanced Illness: Dementia Medication During Period"(Period))


// The following function recieves a list of medication dispensed and a period interval (measurement period, index period, treatment period)
// and returns the cumlative duration a medication has been dispensed as an Integer
// sample use would be as follows "CumulativeDuration"(medlist, Peasurement Period)

define function "CumulativeDuration"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>) returns Integer:
  Sum((collapse ("Medications Dispensed Relevant Periods"(MedsListFromSpec , Period))) X
    return all duration in days of X)


//receives medication list and period from the Medications Dispensed Relevant Periods function
define function "Medication List in Measurement Period"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
  (MedsListFromSpec) MedicationDispensedList
    where MedicationDispensedList.start_date during Period
    and MedicationDispensedList.dispensed = true

define function "Multiple Different Medication Same Day - Longest Supply Date"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist2
    where medlist1.code != medlist2.code
    and medlist1.start_date same day as medlist2.start_date
    and medlist1.end_date 1 day or more after medlist2.end_date
    and me
  return Interval [medlist1.start_date, medlist1.end_date]
          intersect Period

define function "Multiple Different Medications Diff Day - Overlapping Supply"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
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

define function "Same Medication - Overlapping Supply"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
//If multiple prescriptions for the same medication are dispensed on the same day or different days with overlapping days supply, sum the days supply and use the total to calculate the number of days covered by a medication.
  from
  (("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period))) medlist2
    where medlist1.code ~ medlist2.code
    and Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date,medlist2.end_date])OverlapSameMeds
  return all Interval[OverlapSameMeds.start_date, OverlapSameMeds.end_date]
		intersect Period

define function "Non-overlapping Medications"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
// Identifies all intervals of medications, associated with the measurement period
  collapse (( "Medication List in Measurement Period"(MedsListFromSpec , Period)) medicationperiod
      return Interval[medicationperiod.start_date, medicationperiod.end_date]
      intersect Period
      )

define function "Medications Dispensed Relevant Periods"(MedsListFromSpec List<"Medication">, Period Interval<DateTime>):
    "Multiple Different Medication Same Day - Longest Supply Date"(MedsListFromSpec , Period))
    union ("Multiple Different Medications Diff Day - Overlapping Supply"(MedsListFromSpec , Period))
    union ("Same Medication - Overlapping Supply"(MedsListFromSpec , Period))
    union ("Non-overlapping Medications"(MedsListFromSpec , Period))


//valueset functions for CMD

define function "Different Medications Dispensed Relevant Periods Valuesets"(specificMedList List<"Medication">,totalMedList List<"Medication">, Period Interval<DateTime>) returns Integer:
    collapse ("Same Day Different Meds Valuesets- Longest Supply Date Interval"(specificMedList, totalMedList, Period)
      union "Different Day Different Med Overlapping Supply Valuesets- Total of Period"(specificMedList, totalMedList, Period)
    return Interval[medicationperiod.start_date, medicationperiod.end_date]
        )

define function "Same Medications Dispensed Relevant Periods Valuesets"(specificMedList List<"Medication">, Period Interval<DateTime>) returns Integer:
    collapse (("Same Med- Multiple intervals"(specificMedList, Period)
    return Interval[medicationperiod.start_date, medicationperiod.end_date]
        ))

define function "Same Med- Multiple intervals"(specificMedList List<"Medication">, Period Interval<DateTime>):
    from
    (("Medication List in Measurement Period Valuesets"(specificMedList, Period)) medlist1,
    ("Medication List in Measurement Period Valuesets"(specificMedList, Period))) medlist2
      where Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date,medlist2.end_date]) OverlapSameMeds
    return all Interval[OverlapSameMeds.start_date,end of OverlapSameMeds.end_date]
      intersect Period


define function "Same Day Different Meds Valuesets- Longest Supply Date Interval"(specificMedList List<"Medication">,totalMedList List<"Medication">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
  ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
    where medlist1.start_date same day as medlist2.start_date
    and medlist1.end_date 1 day or more after medlist2.end_date
  return Interval[medlist1.start_date, medlist1.end_date]
          intersect Period

define function "Different Day Different Med Overlapping Supply Valuesets- Total of Period"(specificMedList List<"Medication">,totalMedList List<"Medication">, Period Interval<DateTime>):
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        (("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
        ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
          	where Interval[medlist1.start_date,medlist1.end_date] overlaps Interval[medlist2.start_date, medlist2.end_date]) OverlapDiffMeds
        return all Interval[OverlapDiffMeds.start_date, OverlapDiffMeds.end_date]
					intersect Period
          )


define function "Palliative Care"(Period Interval<DateTime>):
  exists((["Clinical Activity": "HEDIS; PALLIATIVE_CARE_ASSESSMENT"]
          union ["Clinical Activity": "HEDIS; PALLIATIVE_CARE_ENCOUNTER"]
          union ["Clinical Activity": "HEDIS; PALLIATIVE_CARE_INTERVENTION"]) PalliativeCare
    where PalliativeCare.start_date on or before end of "Period"
      and PalliativeCare.place_of_service != '81')
