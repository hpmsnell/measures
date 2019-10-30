library HEDIS_DSF2_2020 version '1'

/*
 * Source: HEDIS
 * ID: DSF2
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Depression"
valueset "HEDIS; Bipolar Disorder"
valueset "HEDIS; Beck Depression Inventory Fast Screen total score [BDI]"
valueset "HEDIS; Beck Depression Inventory II total score [BDI]"
valueset "HEDIS; Center for Epidemiologic Studies Depression Scale-Revised total score [CESD-R]"
valueset "HEDIS; Edinburgh Postnatal Depression Scale [EPDS]"
valueset "HEDIS; Geriatric depression scale (GDS) short version total"
valueset "HEDIS; Geriatric depression scale (GDS) total"
valueset "HEDIS; Patient Health Questionnaire 2 item (PHQ-2) total score [Reported]"
valueset "HEDIS; Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"
valueset "HEDIS; Patient Health Questionnaire 9: Modified for Teens total score [Reported.PHQ.Teen]"
valueset "HEDIS; PROMIS 29 Depression score T score"
valueset "HEDIS; My Mood Monitor Total score [M3]"
valueset "HEDIS; Follow-Up Visit"
valueset "HEDIS; Depression or Other Behavioral Health Condition"
valueset "HEDIS; Depression"
valueset "HEDIS; Symptoms of Depression"
valueset "HEDIS; Depression Case Management Encounter"
valueset "HEDIS; Behavioral Health Encounter"
valueset "HEDIS; Antidepressant Medications"

// NCQA value sets

valueset "NCQA; Antidepressant Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Excluded Diagnosis":
  ["Diagnosis": "HEDIS; Depression"]
  union ["Diagnosis": "HEDIS; Bipolar Disorder"]

define "Positive Depression Screening":
  union ["Assessment, Performed"]: "HEDIS; Beck Depression Inventory Fast Screen total score [BDI]"] A
    where A.result >=4
  union ["Assessment, Performed"]: "HEDIS; Beck Depression Inventory II total score [BDI]"] A
    where A.result >=14
  union ["Assessment, Performed"]: "HEDIS; Center for Epidemiologic Studies Depression Scale-Revised total score [CESD-R]"] A
    where A.result >=10
  union ["Assessment, Performed"]: "HEDIS; Edinburgh Postnatal Depression Scale [EPDS]"] A
    where A.result >=9
  union ["Assessment, Performed"]: "HEDIS; Geriatric depression scale (GDS) short version total"] A
    where A.result >=5
  union ["Assessment, Performed"]: "HEDIS; Geriatric depression scale (GDS) total"] A
    where A.result >=10
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 2 item (PHQ-2) total score [Reported]"] A
    where A.result >=3
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"] A
    where A.result >=5
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 9: Modified for Teens total score [Reported.PHQ.Teen]"] A
    where A.result >=5
  union ["Assessment, Performed"]: "HEDIS; PROMIS 29 Depression score T score"] A
    where A.result >=52.5
  union ["Assessment, Performed"]: "HEDIS; My Mood Monitor Total score [M3]"] A
    where A.result >=5

define "Negative Depression Screening":
  union ["Assessment, Performed"]: "HEDIS; Beck Depression Inventory Fast Screen total score [BDI]"] A
    where A.result <4
  union ["Assessment, Performed"]: "HEDIS; Beck Depression Inventory II total score [BDI]"] A
    where A.result <14
  union ["Assessment, Performed"]: "HEDIS; Center for Epidemiologic Studies Depression Scale-Revised total score [CESD-R]"] A
    where A.result <10
  union ["Assessment, Performed"]: "HEDIS; Edinburgh Postnatal Depression Scale [EPDS]"] A
    where A.result <9
  union ["Assessment, Performed"]: "HEDIS; Geriatric depression scale (GDS) short version total"] A
    where A.result <5
  union ["Assessment, Performed"]: "HEDIS; Geriatric depression scale (GDS) total"] A
    where A.result <10
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 2 item (PHQ-2) total score [Reported]"] A
    where A.result <3
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"] A
    where A.result <5
  union ["Assessment, Performed"]: "HEDIS; Patient Health Questionnaire 9: Modified for Teens total score [Reported.PHQ.Teen]"] A
    where A.result <5
  union ["Assessment, Performed"]: "HEDIS; PROMIS 29 Depression score T score"] A
    where A.result <52.5
  union ["Assessment, Performed"]: "HEDIS; My Mood Monitor Total score [M3]"] A
    where A.result <5

define "Earliest Positive Screening":
  First("Positive Depression Screening" A
    where A.authorDateTime during "Measurement Period"
    sort by A.authorDateTime asc)

define "Follow-Up Visit":
  ["Encounter, Performed": "HEDIS; Follow-Up Visit"] E
    with ["Diagnosis": "HEDIS; Depression or Other Behavioral Health Condition"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Depression":
  ["Diagnosis": "HEDIS; Depression"]
  union ["Diagnosis": "HEDIS; Symptoms of Depression"]

define "Depression Case Management Encounter":
  ["Encounter, Performed": "HEDIS; Depression Case Management Encounter"] E
    with "Depression" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Behavioral Health Encounter":
  ["Encounter, Performed": "HEDIS; Behavioral Health Encounter"]

define "Antidepressant Medication":
  ["Medication, Order": "HEDIS; Antidepressant Medications"]
  union ["Medication, Order": "NCQA; Antidepressant Medications"]

define "Follow-Up":
  "Follow-Up Visit"
  union "Depression Case Management Encounter"
  union "Behavioral Health Encounter"
  union "Antidepressant Medication"
  union "Negative Depression Screening"

/* POPULATIONS */

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") > 12
  and exists ("Positive Screening" A
    where A.authorDateTime during "Measurement Period")

define "Denominator Exclusion: Mental Health":
  /*
   * config_link_id: exclusion_1
   */
  exists("Excluded Diagnosis" D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "HEDIS; Hospice"] P
      where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Follow-Up" P
    with "Earliest Positive Screening" A
      such that P.relevantPeriod starts on or 30 days or less after A.authorDateTime)

define "Numerator Performance Not Met: G8432":
  /*
   * config_link_id: G8432
   */
  not "Denominator Exclusion: Mental Health"
  and not "Denominator Exclusion: Hospice"
  and not "Numerator Performance Met"
