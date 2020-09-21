library HEDIS_UOD_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: UOD
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice"
valueset "NCQA; UOD Opioid Medications"
valueset "NCQA; UOD Opioid Medications: Butorphanol"
valueset "NCQA; UOD Opioid Medications: Codeine"
valueset "NCQA; UOD Opioid Medications: Dihydrocodeine"
valueset "NCQA; UOD Opioid Medications: Fentanyl buccal, SL tablets or lozenge/troche (mcg)"
valueset "NCQA; UOD Opioid Medications: Fentanyl film or oral spray (mcg)"
valueset "NCQA; UOD Opioid Medications: Fentanyl nasal spray (mcg)"
valueset "NCQA; UOD Opioid Medications: Fentanyl transdermal patch (mcg/hr)"
valueset "NCQA; UOD Opioid Medications: Hydrocodone"
valueset "NCQA; UOD Opioid Medications: Hydromorphone"
valueset "NCQA; UOD Opioid Medications: Levomethadyl acetate"
valueset "NCQA; UOD Opioid Medications: Levorphanol tartrate"
valueset "NCQA; UOD Opioid Medications: Meperidine hydrochloride"
valueset "NCQA; UOD Opioid Medications: Methadone"
valueset "NCQA; UOD Opioid Medications: Morphine"
valueset "NCQA; UOD Opioid Medications: Opium"
valueset "NCQA; UOD Opioid Medications: Oxycodone"
valueset "NCQA; UOD Opioid Medications: Oxymorphone"
valueset "NCQA; UOD Opioid Medications: Pentazocine"
valueset "NCQA; UOD Opioid Medications: Tapentadol"
valueset "NCQA; UOD Opioid Medications: Tramadol"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Opioid":
  ["Medication, Order": "HEDIS; Opioid Medication"] M
    where M.relevantPeriod starts during "Measurement Period"

define "Opioid Start Date":
  "Opioid" M
    return start of M.relevantPeriod

define "Opioid Stop Date":
  "Opioid" M
    return end of M.relevantPeriod

define "Opioid Period End Date":
  Min(["Opioid Stop Date", end of "Measurement Period"])

define "Opioid Days Supplied":
  "Opioid Period End Date" - "Opioid Start Date"

define "Total Days Supplied":
  sum("Opioid Days Supplied")

define "Butorphanol MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: butorphanol"] M
    return (7 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Codeine MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: codeine"] M
    return (0.15 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Dihydrocodeine MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Dihydrocodeine"] M
    return (0.25 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Fentanyl buccal MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Fentanyl buccal, SL tablets or lozenge/troche (mcg)"] M
    return (0.13 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Fentanyl film MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Fentanyl film or oral spray (mcg)"] M
    return (0.18 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Fentanyl nasal spray MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Fentanyl nasal spray (mcg)"] M
    return (0.16 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Fentanyl transdermal patch MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Fentanyl transdermal patch (mcg/hr)"] M
    return (7.2 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Hydrocodone MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Hydrocodone"] M
    return (1 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Hydromorphone MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Hydromorphone"] M
    return (4 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Levomethadyl MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Levomethadyl acetate"] M
    return (8 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Levorphanol MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Levorphanol tartrate"] M
    return (11 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Meperidine MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Meperidine hydrochloride"] M
    return (0.1 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Methadone MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Methadone"] M
    return (3 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Morphine MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Morphine"] M
    return (1 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Opium MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Opium"] M
    return (1 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Oxycodone MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Oxycodone"] M
    return (1.5 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Oxymorphone MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Oxymorphone"] M
    return (3 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Pentazocine MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Pentazocine"] M
    return (0.37 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Tapentadol MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Tapentadol"] M
    return (0.4 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Tramadol MME Daily Dose":
  ["Medication, Order": "NCQA; UOD Opioid Medications: Tramadol"] M
    return (0.1 * M.quantity / (end of M.relevantPeriod - start of M.relevantPeriod) * M.dose)

define "Total MME Daily Dose":
  sum("Butorphano MME Daily Dose") +
  sum("Codein MME Daily Dose") +
  sum("Dihydrocodein MME Daily Dose") +
  sum("Fentanyl buccal MME Daily Dose") +
  sum("Fentanyl film MME Daily Dose") +
  sum("Fentanyl nasal spray MME Daily Dose") +
  sum("Fentanyl transdermal patch MME Daily Dose") +
  sum("Hydrocodon MME Daily Dose") +
  sum("Hydromorphon MME Daily Dose") +
  sum("Levomethadyl MME Daily Dose") +
  sum("Levorphanol MME Daily Dose") +
  sum("Meperidine MME Daily Dose") +
  sum("Methadon MME Daily Dose") +
  sum("Morphin MME Daily Dose") +
  sum("Opiu MME Daily Dose") +
  sum("Oxycodon MME Daily Dose") +
  sum("Oxymorphon MME Daily Dose") +
  sum("Pentazocin MME Daily Dose") +
  sum("Tapentado MME Daily Dose") +
  sum("Tramado MME Daily Dose")

define "Number of Medications":
  count("Opioid")

define "Average MME Daily Dose":
  "Total MME Daily Dose" / "Number of Medications"

/* Populations */

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and "Total Days Supplied" >= 15
  and not exists(["Intervention, Performed": "HEDIS; Hospice"] I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Average MME Daily Dose" > 120

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
