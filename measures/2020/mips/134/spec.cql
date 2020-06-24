library MIPS_134_2020 version '1'

/*
 * Source: MIPS
 * ID: 134
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 134 Encounter"
valueset "MIPS; Denominator Exclusion: G9717"
valueset "MIPS; Performance Met: G8431"
valueset "MIPS; Performance Met: G8510"
valueset "MIPS; Denominator Exception: G8433"
valueset "MIPS; Performance Not Met: G8511"
valueset "MIPS; Performance Not Met: G8432"

// VSAC Value Sets

valueset "VSAC; Depression Diagnosis": '2.16.840.1.113883.3.600.450'
valueset "VSAC; Bipolar Disorder": '2.16.840.1.113883.3.464.1003.105.12.1157'
valueset "VSAC; Adolescent Depression Screening": '2.16.840.1.113883.3.600.426'
valueset "VSAC; Adult Depression Screening": '2.16.840.1.113883.3.600.431'
valueset "VSAC; PHQ-9 Tool": '2.16.840.1.113883.3.67.1.101.11.723'
valueset "VSAC; Follow-up for depression - adolescent": '2.16.840.1.113883.3.600.467'
valueset "VSAC; Follow-up for depression - adult": '2.16.840.1.113883.3.600.468'
valueset "VSAC; Additional evaluation for depression - adolescent": '2.16.840.1.113883.3.600.1542'
valueset "VSAC; Additional evaluation for depression - adult": '2.16.840.1.113883.3.600.1545'
valueset "VSAC; Referral for Depression Adolescent": '2.16.840.1.113883.3.600.537'
valueset "VSAC; Referral for Depression Adult": '2.16.840.1.113883.3.600.538'
valueset "VSAC; Suicide Risk Assessment": '2.16.840.1.113883.3.526.3.1484'
valueset "VSAC; Depression medications - adolescent": '2.16.840.1.113883.3.600.469'
valueset "VSAC; Depression medications - adult": '2.16.840.1.113883.3.600.470'

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Definitions */

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 134 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier = "MIPS; Telehealth Modifier"
      and E.signingProvider.hasMeasureMembership = true

define "Excluded Diagnosis":
  ["Diagnosis": "VSAC; Depression Diagnosis"]
  union ["Diagnosis": "VSAC; Bipolar Disorder"]

define "Positive Adolescent Screening Exists":
  exists(["Assessment, Performed": "VSAC; Adolescent Depression Screening"] P
    where result = 'positive'
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))
  or exists(["Assessment, Performed": "VSAC; PHQ-9"] P
    where result >= 5
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))

define "Positive Adult Screening Exists":
  exists(["Assessment, Performed": "VSAC; Adult Depression Screening"] P
    where result = 'positive'
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))
  or exists(["Assessment, Performed": "VSAC; PHQ-9"] P
    where result >= 5
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))

define "Negative Adolescent Screening Exists":
  exists(["Assessment, Performed": "VSAC; Adolescent Depression Screening"] P
    where result = 'negative'
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))
  or exists(["Assessment, Performed": "VSAC; PHQ-9"] P
    where result < 5
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod < 18))

define "Negative Adult Screening Exists":
  exists(["Assessment, Performed": "VSAC; Adult Depression Screening"] P
    where result = 'negative'
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod >= 18))
  or exists(["Assessment, Performed": "VSAC; PHQ-9"] P
    where result < 5
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during [14 days before start of E.relevantPeriod, end of E.relevantPeriod]
        and AgeInYearsAt(start of E.relevantPeriod >= 18))

define "Adolescent Follow-Up Procedure":
  ["Procedure, Performed": "VSAC; Follow-up for depression - adolescent"]
  union ["Procedure, Performed": "VSAC; Additional evaluation for depression - adolescent"]
  union ["Procedure, Performed": "VSAC; Referral for Depression Adolescent"]
  union ["Procedure, Performed": "VSAC; Suicide Risk Assessment"]

define "Adolescent Follow-Up Medication"
  ["Medication": "VSAC; Depression medications - adolescent"]

define "Adult Follow-Up Procedure":
  ["Procedure, Performed": "VSAC; Follow-up for depression - adult"]
  union ["Procedure, Performed": "VSAC; Additional evaluation for depression - adult"]
  union ["Procedure, Performed": "VSAC; Referral for Depression Adult"]
  union ["Procedure, Performed": "VSAC; Suicide Risk Assessment"]

define "Adult Follow-Up Medication"
  ["Medication": "VSAC; Depression medications - adult"]

define "Adolescent Follow-Up Exists":
  exists("Adolescent Follow-Up Procedure" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Adolescent Follow-Up Medication" M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Adult Follow-Up Exists":
  exists("Adult Follow-Up Procedure" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Adult Follow-Up Medication" M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps E.relevantPeriod)

define "Positive Adolescent Screening and Follow-Up Exist":
  "Positive Adolescent Screening Exists"
  and "Adolescent Follow-Up Exists"

define "Positive Adult Screening and Follow-Up Exist":
  "Positive Adult Screening Exists"
  and "Adult Follow-Up Exists"
  and exists("Adult Follow-Up" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

/* Populations */

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") > 12
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Denomiantor Exception: G9717"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Excluded Diagnosis" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod
        and D.prevalencePeriod starts before start of E.relevantPeriod)

define "Numerator Performance Met: G8431":
  /*
   * config_link_id: G8431
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8431"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or "Positive Adolescent Screening and Follow-up Exist"
  or "Positive Adult Screening and Follow-up Exist"

 define "Numerator Performance Met: G8510":
   /*
    * config_link_id: G8510
    */
   exists(["Procedure, Performed": "MIPS; Performance Met: G8510"] P
     with "Denominator Encounter" E
       such that P.relevantPeriod starts during E.relevantPeriod)
   or "Negative Adolescent Screening Exist"
   or "Negative Adult Screening Exist"

define "Denominator Exception: G8433":
  /*
   * config_link_id: G8433
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8433"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8511":
  /*
   * config_link_id: G8511
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G8511"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or "Positive Adolescent Screening Exists"
  or "Positive Adult Screening Exists"

define "Numerator Performance Not Met: G8432":
  /*
   * config_link_id: G8432
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8431"
  and not "Numerator Performance Met: G8510"
  and not "Denominator Exception: G8433"
  and not "Numerator Performance Not Met: G8511"
