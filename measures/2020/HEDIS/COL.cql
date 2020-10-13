library HEDIS_COL_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: COL
 * Year: 2019
 * Version: 1
 * Author: Merrill Tingey
 *
 */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets
valueset "HEDIS; FOBT Lab Test": '2.16.840.1.113883.3.464.1004.1959'
valueset "HEDIS; FOBT Test Result or Finding": '2.16.840.1.113883.3.464.1004.1960'
valueset "HEDIS; Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1102'
valueset "HEDIS; History of Flexible Sigmoidoscopy": '2.16.840.1.113883.3.464.1004.1911'
valueset "HEDIS; Colonoscopy": '2.16.840.1.113883.3.464.1004.1064'
valueset "HEDIS; History of Colonoscopy": '2.16.840.1.113883.3.464.1004.1910'
valueset "HEDIS; CT Colonography": '2.16.840.1.113883.3.464.1004.1421'
valueset "HEDIS; FIT-DNA Lab Test": '2.16.840.1.113883.3.464.1004.1749'
valueset "HEDIS; FIT-DNA Test Result or Finding": '2.16.840.1.113883.3.464.1004.1750'
valueset "HEDIS; Colorectal Cancer": '2.16.840.1.113883.3.464.1004.1065'
valueset "HEDIS; Total Colectomy": '2.16.840.1.113883.3.464.1004.1250'
valueset "HEDIS; History of Total Colectomy": '2.16.840.1.113883.3.464.1004.1912'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Measurement Period and Year Prior":
  Interval[start of "Measurement Period" - 1 years, end of "Measurement Period"]

// Numerator Criteria
define "Fecal occult blood test":
  exists(["Laboratory Test, Performed": "HEDIS; FOBT Lab Test"]
    union ["Laboratory Test, Performed": "HEDIS; FOBT Test Result or Finding"]) FOBTLab
        where FOBTLab.relevantPeriod during "Measurement Period"
  or exists((["Procedure, Performed": "HEDIS; FOBT Lab Test"] FB
    union ["Procedure, Performed": "HEDIS; FOBT Test Result or Finding"] FBR
      where FBR.placeOfService != '81') FOBTProc
        where FOBTProc.relevantPeriod during "Measurement Period")

define "Flexible sigmoidoscopy":
  exists(["Procedure, Performed": "HEDIS; Flexible Sigmoidoscopy"] FS
    where FS.relevantPeriod starts 5 years or less before end of "Measurement Period"
      and FS.placeOfService != '81')
  or exists(["Diagnosis": "HEDIS; History of Flexible Sigmoidoscopy"] HFS
    where HFS.prevalencePeriod starts 5 years or less before end of "Measurement Period"
      and HFS.placeOfService != '81')

define "Colonoscopy":
  exists(["Procedure, Performed": "HEDIS; Colonoscopy"] COLO
    where COLO.relevantPeriod starts 10 years or less before end of "Measurement Period"
      and COLO.placeOfService != '81')
  or exists(["Diagnosis": "HEDIS; History of Colonoscopy"] HistCOLO
    where HistCOLO.prevalencePeriod starts 10 years or less before end of "Measurement Period"
      and HistCOLO.placeOfService != '81')

define "CT colonography":
  exists(["Procedure, Performed": "HEDIS; CT Colonography"] CTColo
    where CTColo.relevantPeriod starts 5 years or less before end of "Measurement Period")

define "FIT-DNA test":
  exists(["Laboratory Test, Performed": "HEDIS; FIT-DNA Lab Test"] FT
    union ["Laboratory Test, Performed": "HEDIS; FIT-DNA Test Result or Finding"]) FITLab
      where FITLab.relevantPeriod 3 years or less before end of "Measurement Period"
  or exists((["Procedure, Performed": "HEDIS; FIT-DNA Lab Test"] FT
    union ["Procedure, Performed": "HEDIS; FIT-DNA Test Result or Finding"] FTR
      where FTR.placeOfService != '81') FITLabResult
        where FITLabResult.relevantPeriod 3 years or less before end of "Measurement Period")

// Denominator Exclusion Criteria
define "Colorectal cancer":
  exists(["Procedure, Performed": "HEDIS; Colorectal Cancer"] P
    where P.relevantPeriod starts on or before end of "Measurement Period"
      and P.placeOfService != '81')
  or exists(["Diagnosis": "HEDIS; Colorectal Cancer"] D
    where D.prevalencePeriod starts on or before end of "Measurement Period"
      and D.placeOfService != '81')

define "Total colectomy":
  exists(["Procedure, Performed": "HEDIS; Total Colectomy"]
    union ["Procedure, Performed": "HEDIS; History of Total Colectomy"]) P
      where P.relevantPeriod starts on or before end of "Measurement Period"
        and P.placeOfService != '81'
  or exists["Diagnosis": "HEDIS; History of Total Colectomy"] D
    where D.prevalencePeriod starts on or before end of "Measurement Period"
      and D.placeOfService != '81'


/* POPULATIONS */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 51
  and AgeInYearsAt(end of "Measurement Period") < 76

define "Denominator Exclusion: Colectomy or Cancer":
    /*
     * config_link_id: exclusion_optional_colon
     */
    exists "Colorectal cancer"
      or exists "Total colectomy"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Denominator Exclusion: Frailty or Advanced Illness":
  /*
   * config_link_id: exclusion_required_frailty
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
   * config_link_id: performance_met
   */
   exists "Fecal occult blood test"
    or exists "Flexible sigmoidoscopy"
  	or exists "Colonoscopy"
  	or exists "CT colonography"
  	or exists "FIT-DNA test"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Colectomy or Cancer"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
