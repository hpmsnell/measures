library MIPS_414_2018 version '1'

/*
 * Source: MIPS
 * ID: 414
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 414 Encounter"
valueset "MIPS; Opiates Prescribed for Longer than Six Weeks"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9584"
valueset "MIPS; Performance Not Met: G9585"

// Able Value Sets

valueset "Able; Opioids Used for Pain Control": '1.3.6.1.4.1.6997.4.1.2.234.999.3.1'
valueset "Able; Opioid Risk Assessment"

// VSAC Value Sets

valueset "VSAC; Palliative Care"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 408 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "Opioid Exists":
  exists(["Procedure Performed": "MIPS; Opiates Prescribed for Longer than Six Weeks"] P
  where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "Able; Opioids Used for Pain Control"] M
    where M.relevantPeriod overlaps "Measurement Period"
      and days between start of M.relevantPeriod and end of M.relevantPeriod > 42
        or end of M.relevantPeriod = null
      and days between start of M.relevantPeriod and end of "Measurement Period" > 42
      and days between start of "Measurement Period" and end of M.relevantPeriod > 42)

define "Denominator":
  exists("Denominator Encounter")
  and "Opioid Exists"

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9584":
  /*
   * config_link_id: G9584
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9584"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Opioid Risk Assessment"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9585":
  /*
   * config_link_id: G9585
   */
  not "Numerator Performance Met: G9584"
