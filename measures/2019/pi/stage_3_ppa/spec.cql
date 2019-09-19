library STAGE_3_PPA_2019 version '1'

/*
 * Source: Stage 3
 * ID: PPA
 * Year: 2019
 * Version: 4
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Encounter":
  ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and E.provider_id = "Reporting Provider ID"

define "Denominator Encounter in Calendar Year":
  ["Encounter"] E
    where E.start_datetime same year as start of "Measurement Period"
      and E.provider_id = "Reporting Provider ID"

define "Portal Access":
  ["System Event"] S
    where S.type ="PORTAL_ACCESS"

define "API Access":
  union ["System Event"] S
    where S.type ="API_ACCESS_OPT_IN"

define "API Opt Out":
  union ["System Event"] S
    where S.type ="API_ACCESS_OPT_OUT"

define "Health Information Provisioning":
  ["System Event"] S
    where S.start_datetime same year as start of "Measurement Period"
      and S.type = "HEALTH_INFORMATION_PROVISIONING"
    with "Denominator Encounter" E
      such that S.encounter_id = E.external_id

define "Valid Health Information Provisioning With Portal Access":
  "Health Information Provisioning" S1
    where S1.stop_datetime 48 hours or less after S1.start_datetime
      and S1.stop_datetime same year as start of "Measurement Period"
    with "Portal Access" S2
      such that (
        S1.stop_date during [S2.start_datetime, S2.stop_datetime]
        or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
      )

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  (
    // The patient has at least one health information provisioning event
    // for the encounter where (1) information is available to the patient 48 hours
    // or less after the information is available to the provider
    // and (2) the patient has access to the portal or API at the time
    // that the information is made available to the patient
    (
      exists("Valid Health Information Provisioning With Portal Access" S1
        with "API Access" S2
          such that (
            S1.stop_date during [S2.start_datetime, S2.stop_datetime]
            or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
          )
      )
      or (
        exists("Valid Health Information Provisioning With Portal Access" S1
          with "API Opt Out" S2
            such that S2.start_datetime starts on or before 48 hours after S1.start_datetime)
    )
    // ...AND none of the other encounters lack valid provisioning events
    and not exists("Denominator Encounter in Calendar Year" E
        without ["System Event"] S
          such that S.start_datetime same year as start of "Measurement Period"
            and S.stop_datetime same year as start of "Measurement Period"
            and S.type = "HEALTH_INFORMATION_PROVISIONING"
            and S.stop_datetime 48 hours or less after S.start_datetime
            and S.encounter_id = E.external_id)
    // ...AND none of the other encounters have invalid provisioning events
    and not exists("Denominator Encounter in Calendar Year" E
        with ["System Event"] S
          such that S.start_datetime same year as start of "Measurement Period"
            and S.type = "HEALTH_INFORMATION_PROVISIONING"
            and S.encounter_id = E.external_id
            and (
                S.stop_datetime == null
                or S.stop_datetime after 48 hours after S.start_datetime
                or S.stop_datetime after end of "Measurement Period"
            ))
    // ...AND none of the other encounters have no portal access
    and not exists("Denominator Encounter in Calendar Year" E
        with ["System Event"] S1
          such that S1.start_datetime same year as start of "Measurement Period"
            and S1.stop_datetime same year as start of "Measurement Period"
            and S1.type = "HEALTH_INFORMATION_PROVISIONING"
            and S1.stop_datetime 48 hours or less after S1.start_datetime
            and S1.encounter_id = E.external_id
        without "Portal Access" S2
          such that (
            S1.stop_date during [S2.start_datetime, S2.stop_datetime]
            or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
          ))
  // ...AND none of the other encounters have no API access or API opt out
  and not exists("Denominator Encounter in Calendar Year" E
      with ["System Event"] S1
        such that S1.start_datetime same year as start of "Measurement Period"
          and S1.stop_datetime same year as start of "Measurement Period"
          and S1.type = "HEALTH_INFORMATION_PROVISIONING"
          and S1.stop_datetime 48 hours or less after S1.start_datetime
          and S1.encounter_id = E.external_id
      without "API Access" S2
        such that (
          S1.stop_date during [S2.start_datetime, S2.stop_datetime]
          or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
        )
      without "API Opt Out" S3
        such that S3.start_datetime starts on or before 48 hours after S1.start_datetime)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
