library hedis_shared version '1'

/*
 *
 * Source: HEDIS
 * ID:
 * Year: 2019
 * Version: 1
 * Author: Eric Whitley
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

using QDM

valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'

valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Well-Care": '2.16.840.1.113883.3.464.1004.1262'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'

valueset "NCQA; Dementia Medications": '' //FIXME: add OID

valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1531'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1532'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1533'

valueset "Able; MMDF LTI": ''
valueset "Able; MMDF Hospice": ''

parameter "Measurement Period" Interval<DateTime>

context Patient

/*--------------------------------------------------
HOSPICE
----------------------------------------------------*/
define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Intervention, Performed": "Able; MMDF Hospice"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]) Hospice
  where Hospice.placeOfService != '81'

define function "Hospice During Period"(Period Interval<DateTime>):
  exists(
    "Hospice" H
      where H.relevantPeriod starts during Period
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
      and payer.startDate <= end of Period
      and (
          payer.endDate >= start of Period
          or payer.endDate is null
        )

/*--------------------------------------------------
LTI
–	Living long-term in an institution ... as identified by the LTI flag in the Monthly Membership Detail Data File.
  Use the run date of the file to determine if a member had an LTI flag (during requested period)
----------------------------------------------------*/
define function "LTI During Period"(Period Interval<DateTime>):
  exists(
    ["Intervention, Performed": "Able; MMDF LTI"] LTI
      where LTI.relevantPeriod starts during Period
  )


/*--------------------------------------------------
FRAILTY
----------------------------------------------------*/

define function "Frailty: Diagnosis or Symptoms During Period"(Period Interval<DateTime>):
  ((["Diagnosis": "HEDIS; Frailty Diagnosis"]
  union ["Diagnosis": "HEDIS; Frailty Symptom"]
  union ["Procedure, Performed": "HEDIS; Frailty Symptom"])FrailDxSx
    where FrailDxSx.prevalencePeriod starts during Period)
      and FrailDxSx.supplemental = false
      and FrailDxSx.placeOfService != '81'


define function "Frailty: Encounter During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Frailty Encounter"]FrailEnc
    where FrailEnc.relevantPeriod starts during Period
      and FrailEnc.supplemental = false
      and FrailEnc.placeOfService != '81'

define function "Frailty: Device During Period"(Period Interval<DateTime>):
  (["Device, Applied": "HEDIS; Frailty Device"]
  union ["Device, Order": "HEDIS; Frailty Device"]
  union ["Device, Recommended": "HEDIS; Frailty Device"])FrailDevice
    where FrailDevice.relevantPeriod starts during Period
      and FrailDevice.supplemental = false
      and FrailDevice.placeOfService != '81'

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
    (["Encounter, Performed": "HEDIS; Outpatient"]
      union ["Encounter, Performed": "HEDIS; Observation"]
      union ["Encounter, Performed": "HEDIS; ED"]
      union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]
    ) QualifyingEncounters
      with ["Diagnosis": "HEDIS; Advanced Illness"] D
        such that D.claimId = QualifyingEncounters.claimId
        or (
          D.claimId = null
          and QualifyingEncounters.claimId = null
          and end of QualifyingEncounters.relevantPeriod != null
          and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
        )
        or (
          D.claimId = null
          and QualifyingEncounters.claimId = null
          and QualifyingEncounters.stopDate = null
          and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
        )
      where QualifyingEncounters.relevantPeriod starts during Period
        and Diagnosis.supplemental = false
        and Diagnosis.placeOfService != '81'
        and QualifyingEncounters.supplemental = false
        and QualifyingEncounters.placeOfService != '81'

/*
To identify a nonacute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Confirm the stay was for nonacute care based on the presence of a nonacute code (Nonacute Inpatient Stay Value Set) on the claim.
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Non-Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  (
    //nonacute inpatient discharges
    ((["Encounter, Performed": "HEDIS; Inpatient Stay"])Inpatient
      with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPFlag
        such that Inpatient.claimId = NonacuteIPFlag.claimId
          where Inpatient.dischargeDate during Period //NOTE: we're filtering by DISCHARGE DATE here
          and Inpatient.placeOfService != '81'
      )
  ) QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.placeOfService != '81'

/*
–	At least one acute inpatient encounter (Acute Inpatient Value Set)
  with an advanced illness diagnosis (Advanced Illness Value Set).
*/
define function "Advanced Illness: Acute Inpatient Encounter During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Acute Inpatient"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where
    Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.relevantPeriod starts during Period
    and QualifyingEncounters.placeOfService != '81'

/*
//–	Acute inpatient DISCHARGE with an advanced illness diagnosis (Advanced Illness Value Set)
–	At least one acute inpatient discharge with an advanced illness diagnosis (Advanced Illness Value Set).
To identify an acute inpatient discharge:
1.	Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2.	Exclude nonacute inpatient stays (Nonacute Inpatient Stay Value Set).
3.	Identify the discharge date for the stay.
*/
define function "Advanced Illness: Acute Inpatient DISCHARGE During Period"(Period Interval<DateTime>):
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] QualifyingEncounters
  with ["Diagnosis": "HEDIS; Advanced Illness"] D
    such that D.claimId = QualifyingEncounters.claimId
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and end of QualifyingEncounters.relevantPeriod != null
      and start of D.prevalencePeriod during QualifyingEncounters.relevantPeriod
    )
    or (
      D.claimId = null
      and QualifyingEncounters.claimId = null
      and QualifyingEncounters.stopDate = null
      and start of D.prevalencePeriod same day as start of QualifyingEncounters.relevantPeriod
    )
  where
    Diagnosis.supplemental = false
    and Diagnosis.placeOfService != '81'
    and QualifyingEncounters.supplemental = false
    and QualifyingEncounters.dischargeDate during Period
    and QualifyingEncounters.placeOfService != '81'
    and not exists (
      //There will be secondary non-acute inpatient Encounters
      //we have find ONLY the encounters where there is NOT
      //a related non-acute stay on the same claim
      ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] Nonacute
      such that QualifyingEncounters.claimId = Nonacute.claimId
    )

/*
–	At least two outpatient visits ...
  on different dates of service, with an advanced illness diagnosis
*/
define function "Advanced Illness: Count of Distinct Visit Dates During Period"(Period Interval<DateTime>): //returns Integer:
  Count(distinct((((
       "Advanced Illness: Visit During Period"(Period)
  ).relevantPeriod) start) date))

// A dispensed dementia medication (Dementia Medications List).
define function "Advanced Illness: Dementia Medication During Period"(Period Interval<DateTime>):
  ["Medication, Dispensed": "NCQA; Dementia Medications"] M
  where M.relevantPeriod starts during Period
    and M.supplemental = false

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
    where MedicationDispensedList.relevantPeriod starts during Period

define function "Multiple Different Medication Same Day - Longest Supply Date"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist2
    where medlist1.code != medlist2.code
    and medlist1.relevantPeriod starts same day as start of medlist2.relevantPeriod
    and medlist1.relevantPeriod ends 1 day or more after end of medlist2.relevantPeriod
  return medlist1.relevantPeriod
          intersect Period

define function "Multiple Different Medications Diff Day - Overlapping Supply"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        (("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
        ("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist2
        	where medlist1.code != medlist2.code
          	and medlist1.relevantPeriod overlaps medlist2.relevantPeriod) OverlapDiffMeds
        return all Interval[start of OverlapDiffMeds.relevantPeriod, end of OverlapDiffMeds.relevantPeriod]
					intersect Period
    )

define function "Same Medication - Overlapping Supply"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for the same medication are dispensed on the same day or different days with overlapping days supply, sum the days supply and use the total to calculate the number of days covered by a medication.
  from
  (("Medication List in Measurement Period"(MedsListFromSpec , Period)) medlist1,
  ("Medication List in Measurement Period"(MedsListFromSpec , Period))) medlist2
    where medlist1.code ~ medlist2.code
    and medlist1.relevantPeriod overlaps medlist2.relevantPeriod)OverlapSameMeds
  return all Interval[start of OverlapSameMeds.relevantPeriod, end of OverlapSameMeds.relevantPeriod]
		intersect Period

define function "Non-overlapping Medications"(MedsListFromSpec List<"Medication, Dispensed">, Period Interval<DateTime>):
// Identifies all intervals of medications, associated with the measurement period
  collapse (( "Medication List in Measurement Period"(MedsListFromSpec , Period)) medicationperiod
      return medicationperiod.relevantPeriod
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
    return medicationperiod.relevantPeriod
        )

define function "Same Medications Dispensed Relevant Periods Valuesets"(specificMedList List<"Medication, Dispensed">, Period Interval<DateTime>) returns Integer:
    collapse (("Same Med- Multiple intervals"(specificMedList, Period)
    return medicationperiod.relevantPeriod
        ))

define function "Same Med- Multiple intervals"(specificMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
    from
    (("Medication List in Measurement Period Valuesets"(specificMedList, Period)) medlist1,
    ("Medication List in Measurement Period Valuesets"(specificMedList, Period))) medlist2
      where medlist1.relevantPeriod overlaps medlist2.relevantPeriod)OverlapSameMeds
    return all Interval[start of OverlapSameMeds.relevantPeriod, end of OverlapSameMeds.relevantPeriod]
      intersect Period


define function "Same Day Different Meds Valuesets- Longest Supply Date Interval"(specificMedList List<"Medication, Dispensed">,totalMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
//If multiple prescriptions for different medications are dispensed on the same day, calculate the number of days covered by a medication using the prescriptions with the longest days supply.
  from
  ("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
  ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
    where medlist1.relevantPeriod starts same day as start of medlist2.relevantPeriod
    and medlist1.relevantPeriod ends 1 day or more after end of medlist2.relevantPeriod
  return medlist1.relevantPeriod
          intersect Period

define function "Different Day Different Med Overlapping Supply Valuesets- Total of Period"(specificMedList List<"Medication, Dispensed">,totalMedList List<"Medication, Dispensed">, Period Interval<DateTime>):
//For multiple different prescriptions dispensed on different days with overlapping days supply, count each day in the measurement year only once toward the denominator
//distinct is intended to eliminate duplicate days in measurement period
  distinct (from
        (("Medication List in Measurement Period"(specificMedList , Period)) medlist1,
        ("Medication List in Measurement Period"(totalMedList , Period)) medlist2
          	where medlist1.relevantPeriod overlaps medlist2.relevantPeriod) OverlapDiffMeds
        return all Interval[start of OverlapDiffMeds.relevantPeriod, end of OverlapDiffMeds.relevantPeriod]
					intersect Period
          )
