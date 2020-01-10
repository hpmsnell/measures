library HEDIS_DSF1_2020 version '1'

/*
 * Source: HEDIS
 * ID: DSF1
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

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Excluded Diagnosis":
  ["Diagnosis": "HEDIS; Depression"]
  union ["Diagnosis": "HEDIS; Bipolar Disorder"]

define "Adolescent Screening":
  ["Assessment, Performed": "HEDIS; Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"]
  union ["Assessment, Performed": "HEDIS; Center for Epidemiologic Studies Depression Scale-Revised total score [CESD-R]"]
  union ["Assessment, Performed": "HEDIS; Patient Health Questionnaire 2 item (PHQ-2) total score [Reported]"]
  union ["Assessment, Performed": "HEDIS; Patient Health Questionnaire 9: Modified for Teens total score [Reported.PHQ.Teen]"]
  union ["Assessment, Performed": "HEDIS; Beck Depression Inventory Fast Screen total score [BDI]"]
  union ["Assessment, Performed": "HEDIS; PROMIS 29 Depression score T score"]

define "Adult Screening":
  ["Assessment, Performed": "HEDIS; Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"]
  union ["Assessment, Performed": "HEDIS; Patient Health Questionnaire 2 item (PHQ-2) total score [Reported]"]
  union ["Assessment, Performed": "HEDIS; Beck Depression Inventory Fast Screen total score [BDI]"]
  union ["Assessment, Performed": "HEDIS; Beck Depression Inventory II total score [BDI]"]
  union ["Assessment, Performed": "HEDIS; Center for Epidemiologic Studies Depression Scale-Revised total score [CESD-R]"]
  union ["Assessment, Performed": "HEDIS; Edinburgh Postnatal Depression Scale [EPDS]"]
  union ["Assessment, Performed": "HEDIS; Geriatric depression scale (GDS) short version total"]
  union ["Assessment, Performed": "HEDIS; Geriatric depression scale (GDS) total"]
  union ["Assessment, Performed": "HEDIS; PROMIS 29 Depression score T score"]
  union ["Assessment, Performed": "HEDIS; My Mood Monitor Total score [M3]"]

define "Adolescent Screening Exists":
  AgeInYearsAt(start of E.relevantPeriod < 18))
  and exists("Adolescent Screening" A
    where A.authorDateTime during "Measurement Period")

define "Adult Screening Exists":
  AgeInYearsAt(start of E.relevantPeriod >= 18))
  and exists("Adult Screening" A
    where A.authorDateTime during "Measurement Period")

/* POPULATIONS */

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") > 12

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
  "Adolescent Screening Exists"
  or "Adult Screening Exists"

define "Numerator Performance Not Met: G8432":
  /*
   * config_link_id: G8432
   */
  not "Denominator Exclusion: Mental Health"
  and not "Denominator Exclusion: Hospice"
  and not "Numerator Performance Met"
