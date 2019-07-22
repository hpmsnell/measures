library MIPS_217_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 217
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 217-223 Physical Therapy Evaluation Encounter"
valueset "MIPS; MIPS 217-223 Occupational Therapy Evaluation Encounter"
valueset "MIPS; MIPS 217-223 Physical Therapy Discharge Encounter"
valueset "MIPS; MIPS 217-223 Occupational Therapy Discharge Encounter"
valueset "MIPS; MIPS 217-223 Physician Encounter"
valueset "MIPS; MIPS 217-223 Chiropractic Encounter"
valueset "MIPS; MIPS 217-223 Treatment Complete"
valueset "MIPS; MIPS 217-223 Patient Refused"
valueset "MIPS; MIPS 217-223 Patient Inability"
valueset "MIPS; Performance Met: G8647"
valueset "MIPS; Performance Met: G8648"
valueset "MIPS; Denominator Exception: G8649"
valueset "MIPS; Performance Not Met: G8650"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Functional Deficit":
  ["Procedure, Performed": "MIPS 217-223 Patient Refused"]
  union ["Procedure, Performed": "MIPS 217-223 Patient Inability"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8647"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8648"]
  union ["Procedure, Performed": "MIPS; Denominator Exception: G8649"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8650"]

define "Physical Therapy Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 217-223 Physical Therapy Discharge Encounter"] E1 // Assuming every discharge indicates an episode, and that there cannot be multiple discharges in an episode
    where E1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E1.relevantPeriod) >= 14
      and E1.signingProvider.hasMeasureMembership = true
    with ["Encounter, Performed": "MIPS; MIPS 217-223 Physical Therapy Evaluation Encounter"] E2
      such that E2.relevantPeriod starts on or before before start of E1.relevantPeriod // Assuming episode must end during MP but can start earlier. Also assuming patient can have eval + discharge on same day.
    with "Functional Deficit" P
      such that P.relevantPeriod starts during E1.relevantPeriod // Assuming G-code is documented at discharge

define "Occupational Therapy Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 217-223 Occupational Therapy Discharge Encounter"] E1 // Assuming every discharge indicates an episode, and that there cannot be multiple discharges in an episode
    where E1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E1.relevantPeriod) >= 14
      and E1.signingProvider.hasMeasureMembership = true
    with ["Encounter, Performed": "MIPS; MIPS 217-223 Occupational Therapy Evaluation Encounter"] E2
      such that E2.relevantPeriod starts on or before before start of E1.relevantPeriod // Assuming episode must end during MP but can start earlier. Also assuming patient can have eval + discharge on same day.
    with "Functional Deficit" P
      such that P.relevantPeriod starts during E1.relevantPeriod // Assuming G-code is documented at discharge

define "Physician Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 217-223 Physician Encounter"] E1 // Assuming every discharge indicates an episode, and that there cannot be multiple discharges in an episode
    where E1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E1.relevantPeriod) >= 14
      and E1.signingProvider.hasMeasureMembership = true
    with ["Encounter, Performed": "MIPS; MIPS 217-223 Treatment Complete"] E2
      such that E2.relevantPeriod starts on or before before start of E1.relevantPeriod // Assuming episode must end during MP but can start earlier. Also assuming patient can have eval + discharge on same day.
    with "Functional Deficit" P
      such that P.relevantPeriod starts during E1.relevantPeriod // Assuming G-code is documented at discharge

define "Chiropractic Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 217-223 Chiropractic Encounter"] E1 // Assuming every discharge indicates an episode, and that there cannot be multiple discharges in an episode
    where E1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E1.relevantPeriod) >= 14
      and E1.signingProvider.hasMeasureMembership = true
    with ["Encounter, Performed": "MIPS; MIPS 217-223 Treatment Complete"] E2
      such that E2.relevantPeriod starts on or before before start of E1.relevantPeriod // Assuming episode must end during MP but can start earlier. Also assuming patient can have eval + discharge on same day.
    with "Functional Deficit" P
      such that P.relevantPeriod starts during E1.relevantPeriod // Assuming G-code is documented at discharge

// Populations

define "Denominator":
  "Physical Therapy Denominator Encounter"
  union "Occupational Therapy Denominator Encounter"
  union "Physician Therapy Denominator Encounter"
  union "Chiropractic Therapy Denominator Encounter"

define "Denominator Exclusion: Patient Refused":
  // config_link_id: exclusion_1
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS 217-223 Patient Refused"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exclusion: Patient Inability":
  // config_link_id: exclusion_1
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS 217-223 Patient Inability"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G8647":
  // config_link_id: G8647
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8647"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G8648":
  // config_link_id: G8648
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8648"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G8649":
  // config_link_id: G8649
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8649"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8650":
  // config_link_id: G8650
  not "Denominator Exclusion: Patient Refused"
  and not "Denominator Exclusion: Patient Inability"
  and not "Numerator Performance Met: G8647"
  and not "Numerator Performance Met: G8648"
  and not "Denominator Exception: G8649"
