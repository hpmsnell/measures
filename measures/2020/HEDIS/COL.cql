library HEDIS_COL_2020

/*
 *
 * Source: HEDIS
 * ID: COL
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
 */

using ADM v1

include "../shared/hedis_shared" called HedisShared

// HEDIS value sets
valueset "HEDIS; FOBT_LAB_TEST": '2.16.840.1.113883.3.464.1004.1959'
valueset "HEDIS; FOBT_TEST_RESULT_OR_FINDING": '2.16.840.1.113883.3.464.1004.1960'
valueset "HEDIS; FLEXIBLE_SIGMOIDOSCOPY": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; HISTORY_OF_FLEXIBLE_SIGMOIDOSCOPY": '2.16.840.1.113883.3.464.1004.1911'
valueset "HEDIS; COLONOSCOPY": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; HISTORY_OF_COLONOSCOPY": '2.16.840.1.113883.3.464.1004.1910'
valueset "HEDIS; CT_COLONOGRAPHY": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT_DNA_LAB_TEST": '2.16.840.1.113883.3.464.1004.1749'
valueset "HEDIS; FIT_DNA_TEST_RESULT_OR_FINDING": '2.16.840.1.113883.3.464.1004.1750'
valueset "HEDIS; COLORECTAL_CANCER": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; TOTAL_COLECTOMY": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; HISTORY_OF_TOTAL_COLECTOMY": '2.16.840.1.113883.3.464.1004.1912'

parameter "Measurement Period" Interval<DateTime>

context Patient

/* POPULATIONS */

define "Initial Population":
AgeInYearsAt(end of "Measurement Period") >= 51
and AgeInYearsAt(end of "Measurement Period") < 76

define "Denominator":
  "Initial Population"

define "Denominator Exclusion: Colectomy or Cancer":
    /*
     * Option ID: exclusion_optional_colon
     */
    exists "Colorectal cancer"
      or exists "Total colectomy"

define "Exclusion: Hospice":
   /*
   * Option ID: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * Option ID: exclusion_required_frailty
   */
   AgeInYearsAt(end of "Measurement Period") >= 66
    and ("LTI During Period"("Measurement Period")
          or "SNP"("Measurement Period")
          or ("Advanced Illness"("Measurement Period and Year Prior")
              and "Frailty: Claim During Period"("Measurement Period")
            )
      )

define "Numerator Performance Met":
  /*
   * Option ID: performance_met
   */
   exists "Fecal occult blood test"
    or exists "Flexible sigmoidoscopy"
  	or exists "Colonoscopy"
  	or exists "CT colonography"
  	or exists "FIT-DNA test"


//Definitions

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

//Numerator Criteria
define "Fecal occult blood test":
  exists(["Laboratory Test Performed": "HEDIS; FOBT_LAB_TEST"]
    union ["Laboratory Test Performed": "HEDIS; FOBT_TEST_RESULT_OR_FINDING"]) FOBTLab
        where Interval[FOBTLab.start_date,FOBTLab.end_date] during "Measurement Period"
  or exists((["Clinical Activity": "HEDIS; FOBT_LAB_TEST"] FB
    union ["Clinical Activity": "HEDIS; FOBT_TEST_RESULT_OR_FINDING"] FBR
      where FBR.place_of_service != '81') FOBTProc
        where interval[FOBTProc.start_date,FOBTProc.end_date] during "Measurement Period")

define "Flexible sigmoidoscopy":
  exists(["Clinical Activity": "HEDIS; FLEXIBLE_SIGMOIDOSCOPY"] FlexSig
    where FlexSig.start_date 5 years or less before end of "Measurement Period"
      and FlexSig.place_of_service != '81')
  or exists(["Diagnosis": "HEDIS; HISTORY_OF_FLEXIBLE_SIGMOIDOSCOPY"] HistFlexSig
    where HistFlexSig.start_date 5 years or less before end of "Measurement Period"
      and HistFlexSig.place_of_service != '81')

define "Colonoscopy":
  exists(["Clinical Activity": "HEDIS; COLONOSCOPY"] Colonoscopy
    where Colonoscopy.start_date 10 years or less before end of "Measurement Period"
      and Colonoscopy.place_of_service != '81')
  or exists(["Diagnosis": "HEDIS; HISTORY_OF_COLONOSCOPY"] HistColonoscopy
    where HistColonoscopy.start_date 10 years or less before end of "Measurement Period"
      and HistColonoscopy.place_of_service != '81')

define "CT colonography":
  exists(["Clinical Activity": "HEDIS; CT_COLONOGRAPHY"] CTColo
    where CTColo.start_date 5 years or less before end of "Measurement Period")

define "FIT-DNA test":
  exists(["Laboratory Test Performed": "HEDIS; FIT_DNA_LAB_TEST"] FT
    union ["Laboratory Test Performed": "HEDIS; FIT_DNA_TEST_RESULT_OR_FINDING"]) FITLab
      where FITLab.end_date 3 years or less before end of "Measurement Period"
  or exists((["Clinical Activity": "HEDIS; FIT_DNA_LAB_TEST"] FT
    union ["Clinical Activity": "HEDIS; FIT_DNA_TEST_RESULT_OR_FINDING"] FTR
      where FTR.place_of_service != '81') FITLabResult
        where FITLabResult.end_date 3 years or less before end of "Measurement Period")

// Denominator Exclusion Criteria
define "Colorectal cancer":
  exists(["Clinical Activity": "HEDIS; COLORECTAL_CANCER"] ColoCancer
    where ColoCancer.start_date on or before end of "Measurement Period"
      and ColoCancer.place_of_service != '81')
  or exists(["Diagnosis": "HEDIS; COLORECTAL_CANCER"] DiagColoCancer
    where DiagColoCancer.start_date on or before end of "Measurement Period"
      and DiagColoCancer.place_of_service != '81')

define "Total colectomy":
  exists(["Clinical Activity": "HEDIS; TOTAL_COLECTOMY"]
    union ["Clinical Activity": "HEDIS; HISTORY_OF_TOTAL_COLECTOMY"]) P
      where P.start_date on or before end of "Measurement Period"
        and P.place_of_service != '81'
  or exists["Diagnosis": "HEDIS; HISTORY_OF_TOTAL_COLECTOMY"] DiagHistColectomy
    where DiagHistColectomy.start_date on or before end of "Measurement Period"
      and DiagHistColectomy.place_of_service != '81'
